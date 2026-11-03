// Builds a Terminal profile file from a theme JSON (see themes/ for the format).
// Usage: swift apply-theme.swift <theme.json> <light|dark>
//   light -> writes "Basic Light.terminal", dark -> writes "Basic.terminal"
// Non-color settings (font, spacing, options) are copied from your "Basic" profile.
import AppKit

let args = CommandLine.arguments
guard args.count == 3, ["light", "dark"].contains(args[2]) else {
    fatalError("Usage: swift apply-theme.swift <theme.json> <light|dark>")
}
let mode = args[2]
let profileName = mode == "light" ? "Basic Light" : "Basic"

let json = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: args[1]))) as! [String: Any]
guard let theme = json[mode] as? [String: Any], let ansi = theme["ansi"] as? [String: String] else {
    fatalError("No '\(mode)' theme with an 'ansi' section in \(args[1])")
}
guard let all = UserDefaults(suiteName: "com.apple.Terminal")?.dictionary(forKey: "Window Settings"),
      var p = all["Basic"] as? [String: Any] else { fatalError("Profile Basic not found") }

func color(_ hex: String) -> Data {
    let v = Int(hex.dropFirst(), radix: 16)!
    let c = NSColor(srgbRed: CGFloat((v >> 16) & 0xFF) / 255, green: CGFloat((v >> 8) & 0xFF) / 255,
                    blue: CGFloat(v & 0xFF) / 255, alpha: 1)
    return try! NSKeyedArchiver.archivedData(withRootObject: c, requiringSecureCoding: false)
}

let base = ["background": "BackgroundColor", "text": "TextColor", "boldText": "TextBoldColor",
            "cursor": "CursorColor", "selection": "SelectionColor"]
for (k, plistKey) in base { p[plistKey] = color(theme[k] as! String) }

for (k, hex) in ansi {   // "brightRed" -> "ANSIBrightRedColor"
    p["ANSI\(k.prefix(1).uppercased())\(k.dropFirst())Color"] = color(hex)
}

p["name"] = profileName
let out = URL(fileURLWithPath: "\(profileName).terminal")
try! PropertyListSerialization.data(fromPropertyList: p, format: .xml, options: 0).write(to: out)
print("Wrote \(out.path)")
