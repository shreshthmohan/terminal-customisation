# Terminal customisation

Light and dark color themes for macOS Terminal.app. The theme switches automatically with the macOS appearance, and the colors are tuned to work with Claude Code.

## How it works

- Terminal has two profiles:
  - **Basic**: dark mode.
  - **Basic Light**: light mode. It currently uses `themes/rose-pine-dawn-custom.json`.
- `appearance-watcher` is a small background program that macOS starts at login. When the macOS appearance changes, it moves every tab using one of the two profiles to the other profile. It also sets the profile Terminal uses for new windows.
- `apply-theme.sh` writes the colors from a theme JSON into one of the profiles.

## Files

| File | Purpose |
|---|---|
| `apply-theme.sh` | Applies a theme JSON to a profile and updates all open tabs |
| `apply-theme.swift` | Called by `apply-theme.sh`. Builds the `.terminal` profile file from the JSON |
| `appearance-watcher.swift` | Source of the appearance watcher |
| `appearance-watcher` | Compiled watcher. The LaunchAgent runs this file, so don't delete or move it |
| `install.sh` | Compiles the watcher and installs it as a LaunchAgent |
| `themes/` | Theme JSON files |
| `theme-sample.md` | Fixed markdown sample used to check colors in Claude Code |

## Setup

```bash
./install.sh
```

This compiles the watcher and installs it as a LaunchAgent with the label `com.user.terminal-appearance-watcher`. Logs go to `/tmp/com.user.terminal-appearance-watcher.log`.

To uninstall:

```bash
launchctl bootout gui/$UID ~/Library/LaunchAgents/com.user.terminal-appearance-watcher.plist
rm ~/Library/LaunchAgents/com.user.terminal-appearance-watcher.plist
```

If you move this folder, run `./install.sh` again. The LaunchAgent stores the full path to the binary.

## Applying a theme

```bash
./apply-theme.sh themes/rose-pine-dawn-custom.json light   # updates "Basic Light"
./apply-theme.sh themes/<file>.json dark                   # updates "Basic"
```

The changes appear right away in all open tabs, including text that is already on screen. You don't need to restart Terminal or Claude Code.

Notes:

- Terminal imports a profile by opening its `.terminal` file, and the import always opens a new window. The script closes that window. It also deletes the old profile, renames the imported one, and moves your tabs to it.
- Non-color settings (font, spacing, options) are copied from the **Basic** profile.

## Theme JSON format

```json
{
  "light": {
    "background": "#FAF4ED",
    "text": "#575279",
    "boldText": "#575279",
    "cursor": "#575279",
    "selection": "#DFDAD9",
    "ansi": {
      "black": "#575279", "red": "#B4637A", "green": "#286983", "yellow": "#9A6215",
      "blue": "#29646E", "magenta": "#907AA9", "cyan": "#3B1F1D", "white": "#F2E9E1",
      "brightBlack": "#9893A5", "brightRed": "#B4637A", "brightGreen": "#286983", "brightYellow": "#9A6215",
      "brightBlue": "#29646E", "brightMagenta": "#907AA9", "brightCyan": "#A0544F", "brightWhite": "#FFFAF3"
    }
  }
}
```

The top-level key (`light` or `dark`) must match the mode you pass to `apply-theme.sh`. A file can contain both.

Keep **black** dark and **white** light, also in a light theme. Some themes (Rosé Pine Dawn, for example) swap them for light mode. Programs that print in "black" then become invisible, and that includes Claude Code's main text.

## Themes

| File | Notes |
|---|---|
| `rose-pine-dawn.json` | Original Rosé Pine Dawn (light). Unchanged, for reference |
| `rose-pine-dawn-custom.json` | Rosé Pine Dawn, adjusted for contrast. **Currently applied to Basic Light** |
| `github-light.json` | GitHub light |

There is no dark theme JSON yet. The **Basic** profile keeps its own colors.

## Claude Code

### Use an ANSI theme

Terminal.app has no truecolor support. Claude Code's normal themes, including **Auto (match terminal)**, use fixed RGB colors. Terminal rounds them to its fixed 256-color palette, and the theme JSON cannot change those colors.

In Claude Code, run `/theme` and select **Light mode (ANSI colors only)**. Claude Code then uses only the 16 ANSI colors, which come from the Terminal profile. Claude Code stays on this theme when macOS switches to dark mode, but the colors come from the **Basic** profile, so they still change.

### Which ANSI color is used where (light-ansi)

| Element | ANSI color |
|---|---|
| Main text | `black` |
| Inline code | `blue` |
| Your messages' background | `white` |
| Subtle or inactive text | `brightBlack` |
| Syntax: keywords, literals | `blue` |
| Syntax: types (`Bool`, `Double`) | `cyan`, dimmed. Dim fades it toward the background, so `cyan` must be very dark |
| Syntax: built-ins (`NSApp`) | `cyan` |
| Syntax: function and class names | `yellow` |
| Syntax: strings | `red` |
| Syntax: numbers, comments | `green` |

This table comes from the Claude Code 2.1.317 code, plus testing. It can change in later versions.

### Adjusting colors

1. Ask Claude Code to show the sample:
   ```
   Read theme-sample.md and reply with its exact contents as markdown, with no changes and nothing before or after it.
   ```
2. Say what to change by line and word, for example: "`theme-sample.md:30` `Bool` is too light".
3. Claude edits `themes/rose-pine-dawn-custom.json` and runs `apply-theme.sh`.

If it isn't clear which ANSI color an element uses, set a suspected color to an extreme value (for example `#000000`) and check whether the element changes.
