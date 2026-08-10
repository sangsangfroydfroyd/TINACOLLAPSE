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
4. Add hardware vendor **sillytina > Collapse Visible Devices**.
5. Make sure its power icon is orange. This controller does not need a MIDI input.

Test it in Terminal:

```sh
bitwig collapse all devices
```

The devices on the selected track should collapse. The command works from any folder.

## Set up a Bitwig-only keyboard shortcut

1. Double-click [`Set Keyboard Shortcut.command`](Set%20Keyboard%20Shortcut.command).
2. A Terminal window opens and asks for a shortcut. Copy the exact command below and paste it into the Terminal prompt.

   ```text
   control+command+shift+c
   ```

3. Press Return. The shortcut is saved and starts automatically when you log in.
4. Reopen **Set Keyboard Shortcut.command** whenever you want to replace it with a different combination.

The helper registers the combination only while **Bitwig Studio is the active application**. When another app is active, the combination is released and behaves normally. It does not require Accessibility or Input Monitoring permission.

Use at least two modifiers. Supported modifier names are `control`, `option`, `shift`, and `command`. If the setup says a combination is already in use, choose another one or remove its previous assignment.

The same keyboard-command setup can be opened from Terminal:

```sh
tinacollapse-set-hotkey
```

## Troubleshooting

If Terminal says the controller is not listening:

1. Confirm **sillytina > Collapse Visible Devices** is enabled and orange.
2. Remove any duplicate copies of the controller from Bitwig's Controllers list.
3. Fully quit and reopen Bitwig Studio.

If Terminal cannot find the `bitwig` command, open a new Terminal window and try again.

If the keyboard setup reports that a combination is in use, choose another combination or remove the existing macOS or Bitwig assignment.

If your Bitwig Controller Scripts folder is in a custom location, install with:

```sh
BITWIG_CONTROLLER_SCRIPTS_DIR="/full/path/to/Controller Scripts" "./Install collapse"
```
