# xdg-desktop-portal-kde-env — why this package exists

## The problem

`xdg-desktop-portal.service` is D-Bus-activated (`Type=dbus`), so it is
pulled in on demand and often starts *before* Plasma exports
`XDG_CURRENT_DESKTOP` to the systemd user manager. With a bare environment the
portal matches no `UseIn=KDE` backend and falls back to gtk for every
interface "as a last-resort fallback". Because of that,
`org.freedesktop.portal.GlobalShortcuts` is never exposed on
`/org/freedesktop/portal/desktop`.

Apps like ghostty bind `global:` keybinds (e.g. `keybind = global:super+grave_accent=toggle_quick_terminal`)
through that portal interface exactly once at startup. When the interface is
missing they fail with:

```
warning(gtk_ghostty_global_shortcuts): request failed=...No such interface
"org.freedesktop.portal.GlobalShortcuts" on object at path /org/freedesktop/portal/desktop
```

and their global shortcuts silently do nothing until the app is restarted
after the portal is fixed.

Sanity checks:

- `journalctl --user -u xdg-desktop-portal.service -b` — look for
  "Choosing gtk.portal for ... as a last-resort fallback".
- Introspect `/org/freedesktop/portal/desktop` and confirm whether
  `org.freedesktop.portal.GlobalShortcuts` is advertised.

Note: this is a startup-ordering race, not a systemd ordering bug — adding
`After=`/`Wants=` cannot fix it, because an on-demand D-Bus activation is not
part of the graphical-session transaction.

## What this package does

Ships a user-unit drop-in that pins `XDG_CURRENT_DESKTOP=KDE` into the portal
service's spawn environment (`Environment=` is applied at every process
spawn, regardless of boot order). Backend selection then deterministically
picks `xdg-desktop-portal-kde`, the backend that actually implements
`GlobalShortcuts`, and ghostty-style one-shot binds succeed.

## Maintenance notes

- KDE/Plasma-specific by design. Wrong for multi-DE installs — consider
  dropping or guarding the package there.
- Per-user overrides belong in `/etc/systemd/user/xdg-desktop-portal.service.d/`,
  which wins over this package's `/usr/lib` drop-in.
- The env takes effect for the portal after relog, or immediately via
  `systemctl --user restart xdg-desktop-portal.service`. The target app
  (e.g. ghostty) must then (re)start to run its bind.
- Depends on `xdg-desktop-portal-kde` being installed — it is the backend
  providing GlobalShortcuts. Do not drop that dependency.