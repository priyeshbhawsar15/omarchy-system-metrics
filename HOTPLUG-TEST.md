# Screen lifecycle regression test

Service.qml owns its desktop window through `Variants`, keyed by the selected
`Quickshell.screens` object, and explicitly assigns `screen: modelData`.
Do not replace this with one persistent PanelWindow: when an output disappears,
Hyprland sends layer-shell `closed` and Quickshell closes that window. A screen
binding alone does not recreate the closed surface on reconnect.

Manual integration test (active Omarchy session; save work first):

1. Record `pgrep -af 'quickshell -n'` and `hyprctl -i 0 layers`.
2. Briefly disable the widget's output using the current Hyprland Lua monitor
   API, e.g. `hyprctl -i 0 eval 'hl.monitor({output="DP-4", disabled=true})'`.
3. Verify the widget follows the existing fallback screen (second screen, else
   first); with no screens the Variants model must be empty.
4. Restore managed monitor configuration with `hyprctl -i 0 reload`.
5. Verify the widget returns to its target output with a fresh layer surface,
   the Quickshell PID is unchanged, and `hyprctl -i 0 configerrors` is empty.
6. Repeat for DP-6, then test a normal display sleep/wake cycle.
7. Verify pin/auto-hide preferences and data remain intact; disabling the plugin
   should remove its windows and re-enabling should recreate them.

Live validation on Hyprland 0.56.2 / Quickshell 0.3.1: DP-4 and DP-6 disable/restore
cycles passed on 2026-10-02, all five desktop widget namespaces present after
reconnect, unchanged Quickshell PID 337994. Physical sleep/wake and a zero-output
session still require interactive validation. No polling or restart recovery is
part of this lifecycle fix.
