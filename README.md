# Hyprland Dock

> Personal fork maintained by Raúl, based on [Nick Friedrich's Hyprland Dock](https://github.com/nick-friedrich/hyprland-dock). Original attribution and MIT license are preserved.
>
> This fork includes intelligent hiding, the lavender desktop appearance, and synchronous icon loading as a workaround for an observed Qt 6.11.2 image-loader crash. The workaround passed local startup checks; it is not a claim that every Qt crash is resolved.
>
> Installation and updates use this fork. Desktop-wide customization is maintained separately in [raulchiclano/omarchy](https://github.com/raulchiclano/omarchy). That installer includes a pinned revision of this fork by default, with the lavender preset, backups and autostart. See its [dock guide](https://github.com/raulchiclano/omarchy/blob/main/docs/dock.md).


A lightweight macOS-inspired application dock for Hyprland, built with Quickshell and Qt/QML.

![Hyprland Dock running at the bottom of a Hyprland desktop](preview_2.png)

## Features

- Spanish lavender menus, application picker and tooltips using Adwaita Sans
- Smooth pointer-distance magnification
- Freedesktop application icons and launching
- Workspace-aware clicks: focus the last-used local window or open a new one here
- Running applications appear after favorites with a subtle separator; one icon per application
- Pin running applications from their context menu
- Window chooser grouped by current and other workspaces, with titles and keyboard navigation
- Workspace-aware indicators: dim remote dot, local dot(s), and a brighter focused marker
- Drag-to-reorder with persistent pinned-app order
- Right-click actions to launch, close, pin, or unpin applications
- Fuzzy application search for adding dock items
- Configurable dock background transparency
- Optional reserved screen space
- Optional auto-hide with screen-edge reveal
- Live JSON configuration reload
- Multi-monitor support

## Requirements

- Hyprland
- Quickshell 0.3 or newer
- A working freedesktop icon theme

![Hyprland Dock running at the bottom of a Hyprland desktop](preview.png)

## Install

Make sure Quickshell is installed, then run:

```bash
curl -fsSL https://raw.githubusercontent.com/raulchiclano/hyprland-dock/master/install.sh | bash
```

The installer uses only user directories, requires no `sudo`, and creates an XDG autostart entry. To install without autostart:

```bash
curl -fsSL https://raw.githubusercontent.com/raulchiclano/hyprland-dock/master/install.sh | bash -s -- --no-autostart
```

Run the dock immediately with:

```bash
hyprland-dock --daemonize
```

Installed copies also appear as **Hyprland Dock** in application launchers. Selecting it safely starts or restarts the dock.

Manage autostart later from the CLI:

```bash
hyprland-dock autostart status
hyprland-dock autostart enable
hyprland-dock autostart disable
```

Run `hyprland-dock help` to see every available command.

If your Hyprland session does not process XDG autostart entries, add one of these manually:

```lua
-- Omarchy: ~/.config/hypr/autostart.lua
o.launch_on_start("hyprland-dock")
```

```ini
# Standard Hyprland: ~/.config/hypr/hyprland.conf
exec-once = hyprland-dock
```

### Update or remove

```bash
hyprland-dock update
hyprland-dock restart
hyprland-dock uninstall
```

The older `--update`, `--restart`, and `--uninstall` forms remain supported. Uninstalling preserves the configuration; remove it too with `hyprland-dock uninstall --purge`.

## Install as an Omarchy plugin

Omarchy Quattro users can run the dock inside the existing Omarchy shell instead of starting a second Quickshell process. If the standalone dock is already running, disable its autostart and stop it first:

```bash
hyprland-dock autostart disable
hyprland-dock stop
```

Then install and enable the plugin:

```bash
omarchy plugin add https://github.com/raulchiclano/hyprland-dock.git --enable
```

The plugin uses the same `~/.config/hyprland-dock/dock.json` configuration as the standalone version. On a plugin-only installation, create it from the bundled defaults:

```bash
mkdir -p ~/.config/hyprland-dock
cp ~/.config/omarchy/plugins/io.github.nick-friedrich.hyprland-dock/config/dock.json \
  ~/.config/hyprland-dock/dock.json
```

Update or remove the plugin with:

```bash
omarchy plugin update io.github.nick-friedrich.hyprland-dock
omarchy plugin remove io.github.nick-friedrich.hyprland-dock
```

Do not run the standalone and plugin versions together, or two docks will appear.

### Development

Clone the repository and run directly from it:

```bash
./scripts/run
```

Quickshell watches the QML files, so UI changes reload while developing.

## Configure

Installed copies use `~/.config/hyprland-dock/dock.json`. When running from the repository, edit [`config/dock.json`](config/dock.json):

```json
{
  "iconSize": 42,
  "magnification": 1.2,
  "magnificationRadius": 95,
  "margin": 10,
  "backgroundOpacity": 0.88,
  "position": "bottom",
  "fullLength": false,
  "reserveSpace": true,
  "autoHide": false,
  "clickAction": "focus-or-launch",
  "pinned": [
    "org.gnome.Nautilus",
    "com.mitchellh.ghostty",
    "chromium"
  ]
}
```

### Options

| Option | Description |
| --- | --- |
| `iconSize` | Base icon size in pixels |
| `magnification` | Maximum icon scale under the pointer |
| `magnificationRadius` | Distance over which nearby icons magnify |
| `margin` | Distance between the dock and screen edge |
| `backgroundOpacity` | Dock background opacity from `0.0` (transparent) to `1.0` (opaque) |
| `position` | Screen edge: `top`, `bottom`, `left`, or `right` |
| `fullLength` | Fill the screen width, or height for a vertical dock |
| `reserveSpace` | When `true`, tiled windows stop beside the dock |
| `autoHide` | Hide the dock until the pointer reaches its screen edge; can also be toggled from the right-click menu |
| `clickAction` | `focus-or-launch` focuses the last-used window in the current workspace, or opens one here; `launch` requests a new window. Unsupported requests show the menu instead of activating a window elsewhere. |
| `pinned` | Ordered desktop-entry IDs displayed in the dock |

Pinned values are desktop-entry filenames without the `.desktop` suffix. List available IDs with:

```bash
find /usr/share/applications ~/.local/share/applications \
  -type f -name '*.desktop' 2>/dev/null \
  | sed 's#.*/##; s/\.desktop$//' | sort -u
```

The configuration file is watched and updates automatically. Drag a dock icon to another slot to reorder it; the new `pinned` order is written back to this file. When auto-hide is enabled, the dock overlays windows instead of reserving screen space.

For a full-height vertical dock on the left, use:

```json
{
  "position": "left",
  "fullLength": true
}
```

### Disable cursor warping

Hyprland controls whether the pointer moves when focus switches to a window on another workspace. This is compositor-wide behavior and cannot be reliably overridden by the dock.

On Omarchy, add this override to `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  cursor = {
    warp_on_change_workspace = 0,
  },
})
```

Hyprland normally reloads after the file is saved. Validate the configuration with:

```bash
hyprctl reload
hyprctl configerrors
```

This disables cursor warping for all workspace changes, not only dock clicks.

## Roadmap

- Theme integration

## License

[MIT](LICENSE)



## Intelligent hiding

Set `autoHide: true` and `intelligentHide: true` to keep the dock visible unless a visible window overlaps its background. Hidden windows and inactive workspaces are ignored; pinned windows and visible special workspaces are included. Pointer reveal and menus still work. Geometry refreshes every 500 ms via Quickshell IPC, without external processes. Set `intelligentHide: false` for the original edge-only behavior.

## Local checks

Run `node tests/overlap.cjs` to check overlap detection for visible, hidden, pinned and special-workspace windows. The runtime and QML checks are listed in `AGENTS.md`.

## Running applications

Open windows from all workspaces appear after the pinned favorites. Multiple windows of the same recognized application share one temporary icon, which disappears after its last window closes. Pinned applications are never duplicated. Use **Fijar en el dock** on a temporary icon to keep it; unfixed running apps remain visible until closed. Only favorites can be reordered by dragging.

Applications are matched by desktop entry ID, startup class and the existing web-app identifier matching. Unrecognized applications can still be focused and closed, but use a generic icon and cannot be pinned until a valid desktop launcher is available. Background processes without windows are not included. Normal clicks focus the last-used local window; the context menu also offers a window chooser.

Run `node tests/applications.cjs` to check grouping, matching, pin/unpin transitions and applications without launchers.

### Workspace-aware clicks

The current workspace is the focused workspace (or its open special workspace).
Applications remain grouped globally, but a normal click never selects a window
from another workspace implicitly:

- If local windows exist, focus the most recently used one. Pinned windows visible
  on the focused monitor count as local. Window identities come from Hyprland's
  Wayland handles, not window titles.
- Otherwise request a new window using the desktop entry's `new-window` or
  `new-empty-window` action. Zen uses `new-blank-window`; Foot launches a new terminal.
- A running app with no known new-window action opens the menu. This includes
  singleton apps such as Spotify and unverified launchers: ordinary execution can
  activate their existing window on another workspace, so it is not used here.
- The menu offers **Nueva ventana aquí** when supported and **Ver ventanas (N)…**
  to choose a specific window. The chooser groups **Este escritorio** first and
  **Otros escritorios** second, with the window title and workspace on each row.
  Selecting a remote row explicitly switches to that window's workspace.
- **Cerrar ventana aquí** only closes the last-used local window.

The new-window action is supplied by each application; application-specific
workspace rules can still override where a newly created window is placed.
The current implementation uses the focused workspace on multi-monitor systems,
not necessarily the monitor containing the dock that was clicked.

Validation: `node tests/window-policy.cjs`, `node tests/applications.cjs` and
`node tests/overlap.cjs`. Local integration checks covered new Foot windows with
existing remote terminals, local focus history, Spotify without an implicit
workspace switch, and two new windows each for Zen, Nautilus and VS Code on an
empty workspace. Only test-created windows were closed afterward.

### Choosing a window

Right-click an application → **Ver ventanas (N)…**. The chooser stays inside the
same lavender popup, with **Volver** to return to its menu. It lists all matched
windows, including those of applications without a recognized desktop entry.
Titles are rendered as plain text, wrap to two lines and update while open.
Window numbers help distinguish identical titles and remain stable when focus
history changes. A small dot identifies the currently active window.

Long lists scroll within a bounded panel. Up/Down select a row, Enter activates
it, and Escape or Backspace returns to the menu. Groups without windows are
omitted; if the last window closes, the chooser shows an empty state. Activation
revalidates the selected window address against the application's live windows,
so it never falls back to a different window when the selected one has closed.
Normal left clicks and the current-workspace launch policy are unchanged.

Validation also includes `node tests/window-chooser.cjs` and a live QML check of
exact window selection, remote workspace activation, 25-window scrolling bounds,
an empty list and a visual check of the grouped layout and long titles.

### Application indicators

The subtle marker beside each icon reflects the current focused workspace:

- No windows: no marker.
- Windows only elsewhere: one dim lavender dot.
- One local window: one lavender dot.
- Multiple local windows: two lavender dots, regardless of their exact count.
- Application has focus: a brighter lavender bar, taking priority over the dots.

Markers follow the dock orientation, including vertical docks. Hover text gives
exact counts, for example **Foot · 2 aquí · 3 en otros escritorios**. Counts follow
the same workspace and visible pinned-window policy as window selection. The
hover label uses a non-focusing popup so it can extend past the dock's own bounds
and slide into view at screen edges. Click actions and window selection are unchanged.

Validation: `node tests/indicators.cjs`, live workspace counts and focus transitions,
and visual checks of all five states and hover text at a screen edge.
