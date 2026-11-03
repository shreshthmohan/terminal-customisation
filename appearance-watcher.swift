// Switches Terminal between "Basic" (dark) and "Basic Light" when macOS appearance changes.
// Only tabs already using one of these two profiles are switched; other tabs are left alone.
import AppKit

let darkProfile = "Basic", lightProfile = "Basic Light"

func isDark() -> Bool {
    CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
    let v = CFPreferencesCopyAppValue("AppleInterfaceStyle" as CFString, kCFPreferencesAnyApplication) as? String
    return v == "Dark"
}

func apply() {
    let want = isDark() ? darkProfile : lightProfile
    let other = isDark() ? lightProfile : darkProfile
    let terminalRunning = !NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.Terminal").isEmpty

    if terminalRunning {
        let script = """
        tell application "Terminal"
          set default settings to settings set "\(want)"
          set startup settings to settings set "\(want)"
          repeat with w in windows
            repeat with t in tabs of w
              if name of current settings of t is "\(other)" then set current settings of t to settings set "\(want)"
            end repeat
          end repeat
        end tell
        """
        var err: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&err)
        if let err { NSLog("appearance-watcher: %@", err) }
    } else {
        // Terminal is closed: just update its prefs so it opens with the right profile.
        for key in ["Default Window Settings", "Startup Window Settings"] {
            CFPreferencesSetAppValue(key as CFString, want as CFString, "com.apple.Terminal" as CFString)
        }
        CFPreferencesAppSynchronize("com.apple.Terminal" as CFString)
    }
}

DistributedNotificationCenter.default().addObserver(
    forName: Notification.Name("AppleInterfaceThemeChangedNotification"), object: nil, queue: .main
) { _ in
    // Small delay so the new AppleInterfaceStyle value has been written.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { apply() }
}

apply()
RunLoop.main.run()
