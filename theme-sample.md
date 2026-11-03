# Heading 1
## Heading 2
### Heading 3

**Bold**, *italic*, ***bold italic***, ~~strikethrough~~, `inline code`, and a [link](https://example.com).

> A blockquote with **bold** and `code` inside it.

- A bulleted item
- Another one, with `apply-theme.sh`
  - A nested item

1. First step
2. Second step, with `NSApp.effectiveAppearance`
3. Third step

| File | Purpose | Example |
|---|---|---|
| `apply-theme.sh` | Applies a theme | `./apply-theme.sh x.json light` |
| `install.sh` | Installs the watcher | `launchctl list` |

```swift
import AppKit

// Watch for appearance changes
final class Watcher: NSObject {
    let threshold: Double = 0.5
    var count = 42

    func isDark() -> Bool {
        return NSApp.effectiveAppearance.name == .darkAqua
    }

    func log(_ message: String) {
        print("Mode: \(isDark() ? "dark" : "light") (\(count))")
    }
}
```

```bash
#!/bin/zsh
# Apply a theme and report the result
set -euo pipefail
theme="${1:-themes/rose-pine-dawn-custom.json}"
if [[ -f "$theme" ]]; then
  ./apply-theme.sh "$theme" light && echo "Applied $theme"
else
  echo "Missing: $theme" >&2; exit 1
fi
```

```typescript
type Mode = "light" | "dark";

interface Palette {
  name: string;
  contrast: number;
}

const MIN_CONTRAST = 4.5; // WCAG AA

export async function load(mode: Mode): Promise<Palette | null> {
  const res = await fetch(`/themes/${mode}.json`);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const data: Palette = await res.json();
  return data.contrast >= MIN_CONTRAST ? data : null;
}
```

```json
{
  "light": {
    "background": "#FAF4ED",
    "contrast": 5.5,
    "enabled": true,
    "parent": null
  }
}
```

```diff
--- a/themes/rose-pine-dawn.json
+++ b/themes/rose-pine-dawn-custom.json
@@ -10,1 +10,1 @@
-      "blue": "#56949F", "magenta": "#907AA9",
+      "blue": "#2F6F7A", "magenta": "#907AA9",
```
