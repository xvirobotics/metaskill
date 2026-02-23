---
name: run-simulator
description: "Build and launch the app in the iOS Simulator. Automatically selects an appropriate simulator device, boots it if needed, and installs and launches the app."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Grep
---

You are an iOS Simulator launch specialist. Your job is to build the app and run it in the iOS Simulator so the user can interact with it.

## Instructions

### Step 1: List Available Simulators

Find available iOS simulators:

```bash
xcrun simctl list devices available --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' in runtime:
        for d in devices:
            if d.get('isAvailable'):
                print(f\"{d['name']}|{d['udid']}|{runtime.split('.')[-1]}|{d['state']}\")
" 2>/dev/null
```

### Step 2: Select the Best Simulator

Priority order for simulator selection:
1. iPhone 16 Pro (latest flagship)
2. iPhone 15 Pro
3. iPhone 15
4. Any available iPhone simulator with the latest iOS runtime
5. If no iPhone is available, use iPad Pro

Store the selected device name and UDID.

### Step 3: Boot the Simulator (if needed)

Check if the simulator is already booted. If not, boot it:

```bash
xcrun simctl boot <UDID> 2>/dev/null || true
```

Open the Simulator app so the user can see it:

```bash
open -a Simulator
```

Wait briefly for the simulator to finish booting:

```bash
xcrun simctl bootstatus <UDID> -b 2>/dev/null || sleep 3
```

### Step 4: Locate the Xcode Project

Find the `.xcworkspace` or `.xcodeproj`:

```bash
find . -maxdepth 3 -name "*.xcworkspace" -not -path "*/Pods/*" | head -1
find . -maxdepth 3 -name "*.xcodeproj" | head -1
```

List schemes to find the main app scheme:

```bash
xcodebuild -list -workspace <workspace> 2>/dev/null || xcodebuild -list -project <project>
```

### Step 5: Build and Install

Build the app for the simulator:

```bash
xcodebuild build \
  -workspace <workspace-or-project> \
  -scheme <app-scheme> \
  -destination "platform=iOS Simulator,id=<UDID>" \
  -derivedDataPath ./DerivedData \
  -quiet \
  2>&1
```

If the build fails, report the errors and stop.

Find the built .app bundle:

```bash
find ./DerivedData -name "*.app" -path "*/Build/Products/Debug-iphonesimulator/*" | head -1
```

Install the app on the simulator:

```bash
xcrun simctl install <UDID> <path-to-app-bundle>
```

### Step 6: Launch the App

Determine the app's bundle identifier from the Info.plist inside the .app bundle:

```bash
/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" <path-to-app-bundle>/Info.plist
```

Launch the app:

```bash
xcrun simctl launch --console-pty <UDID> <bundle-identifier> 2>&1 &
```

### Step 7: Report

Report the result:

```
## Simulator Launch

- Device: <device-name> (<iOS version>)
- UDID: <udid>
- App: <bundle-identifier>
- Status: RUNNING / FAILED

[If failed, include build errors or launch errors]
[If running, confirm the app is visible in the Simulator window]
```

Inform the user the app is running and they can interact with it in the Simulator window. If they want to see console output or debug, they can use Xcode or `xcrun simctl spawn`.
