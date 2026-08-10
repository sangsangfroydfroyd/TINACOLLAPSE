# TINACOLLAPSE
collapse all devices command for bitwig

## Script Install
Download this: https://github.com/sangsangfroydfroyd/TINACOLLAPSE
- Inside folder is an executable command. Double click to install.
- After install relaunch bitwig and go to the controllers page in settings.
	- click + add controller on the very bottom of page
	- in the "Hardware Vendor" dropdown select "sillytina"
	- select the product: "Collapse Visible Devices"
	- once added make sure its power button toggle is armed
	
### Once this is set up you are all good to go on the bitwig side :)
---
## Keyboard shortcut setup

The "collapse all" is triggered by a terminal command that triggers the bitwig controller.

to turn this into a keyboard shortcut:

Download this shortcut command and save to your shortcuts:
https://www.icloud.com/shortcuts/846ddb0fb03f40aebf32ad509b3430fd

- Open shortcut and edit
- Press the ( i ) at the top right of the shortcut
	- on the bottom of the info screen will be a "create keyboard shortcut"
	- create your chosen command (MAKE SURE ITS NOT AN ACTIVE COMMAND IN BITWIG OR BOTH WILL TRIGGER)
		- I used: ⌥⌘c

the terminal command to trigger the collapse devices is below if youd prefer to make the shortcut yourself:
```
"$HOME/.local/bin/bitwig" collapse all devices
```
