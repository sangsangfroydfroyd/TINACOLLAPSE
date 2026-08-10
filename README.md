# TINACOLLAPSE

Collapse all top-level devices on the selected Bitwig Studio track with one command or keyboard shortcut.

No MIDI controller or IAC Driver is required. TINACOLLAPSE currently supports macOS.

## Install

Double-click **Install collapse**.

The installer adds the Bitwig controller script, the `bitwig` terminal command, and the optional native keyboard-shortcut helper for the current user. It does not need `sudo`.

## Set up Bitwig

1. Save your work and fully quit Bitwig Studio with `Command-Q`.
2. Reopen Bitwig Studio.
3. Open **Dashboard > Settings > Controllers**.
4. Add **sillytina > Collapse Visible Devices**.
5. Make sure its power icon is orange. This controller does not need a MIDI input.

Test it in Terminal:

```sh
bitwig collapse all devices
```

The devices on the selected track should collapse. The command works from any folder.

## Set up a Bitwig-only keyboard shortcut

1. Double-click [`Set Keyboard Shortcut.command`](Set%20Keyboard%20Shortcut.command).
2. A Terminal window opens and asks for a shortcut. Enter modifiers and one key separated by `+`.

   ```text
   control+option+command+=
   ```

3. Press Return. The shortcut is saved and starts automatically when you log in.
4. Reopen **Set Keyboard Shortcut.command** whenever you want to replace it with a different combination.

The helper registers the combination only while **Bitwig Studio is the active application**. When another app is active, the combination is released and behaves normally. It does not require Accessibility or Input Monitoring permission.

Use at least two modifiers. Supported modifier names are `control`, `option`, `shift`, and `command`. If the setup says a combination is already in use, choose another one or remove its previous assignment.

You can also reopen the setup from Terminal:

```sh
tinacollapse-set-hotkey
```

## Apple Shortcut alternative

1. Double-click [`Shortcuts/Collapse All Trigger.shortcut`](Shortcuts/Collapse%20All%20Trigger.shortcut).
2. Choose **Add Shortcut** to save it in the Shortcuts app.
3. In Shortcuts, double-click **Collapse All Trigger** to open it.
4. Click the **Details** button (`i`) at the top right.
5. Click **Add Keyboard Shortcut**.
6. Press the key combination you want to use. For example: `⌃⌥⌘=`.
7. With Bitwig open, press that combination to collapse the selected track's devices.

Choose a combination that is not already assigned in Bitwig or reserved by macOS. The native setup above is recommended because it releases the combination whenever Bitwig is not active.

## Troubleshooting

If Terminal says the controller is not listening:

1. Confirm **sillytina > Collapse Visible Devices** is enabled and orange.
2. Remove any duplicate copies of the controller from Bitwig's Controllers list.
3. Fully quit and reopen Bitwig Studio.

If Terminal cannot find the `bitwig` command, open a new Terminal window and try again.

If the keyboard setup reports that a combination is in use, remove that combination from the Apple Shortcut or choose a different one.

If your Bitwig Controller Scripts folder is in a custom location, install with:

```sh
BITWIG_CONTROLLER_SCRIPTS_DIR="/full/path/to/Controller Scripts" "./Install collapse"
```
