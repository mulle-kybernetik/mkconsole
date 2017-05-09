# MkConsole

### Changes in version 1.13

This version of MkConsole requires Mac OS X 10.6 (Snow Leopard) or above.

* MkConsole is now built only as an application that runs as a menu bar item.


### Changes in version 1.12

This version of MkConsole requires Mac OS X 10.5 (Leopard) or above.

* Text can be displayed without anti-aliasing.


### Changes in version 1.11

* The element now displays an entry in the status item area in the menu bar. This means it can be configured without launching the app, which got messy in Leopard anyway, and it can  be quit directly from the menu.
* The element now also supports the system configuration watcher introduced in version 1.10.

	
### Changes in version 1.10

This version will recognize network configuration changes which comes in handy when you're observing logfiles on attached network file systems. It will work with Mac OS X 10.4 (Tiger) or above. It will also work with Mac OS X 10.3 (Panther), but needs to be built from source using the "Deployment 10.3" build style.

* Can be deployed on Mac OS X 10.3 once again.
* Added new boolean NSUserDefault <b>NoAlertOnOpenFailure</b> which will log an error if a logfile couldn't be opened rather than raising an alert panel.
* Logwindows will realize if the screen, they are intended to be displayed on, has gone after a restart or wake from sleep and try to find a place where they are visible once again.
* Does recognize network configuration changes
* Will wait 5 seconds before reopening logfiles after system wakeup or network configuration change


### Changes in version 1.9

This version of MkConsole requires Mac OS X 10.4 (Tiger) or above. It will not work with earlier versions.

* Application and the element are now universal binaries.


### Changes in version 1.8

This version of MkConsole requires Mac OS X 10.3 (Panther) or above. It will not work with earlier versions.

* Logfiles are reopened when the computer wakes up from sleep. This should solve even the most persistent NFS issues.


### Changes in version 1.7

This version of MkConsole requires Mac OS X 10.2 (Jaguar) or above. It will not work with earlier versions.

* New preference to keep the MkConsole window on the desktop when using Expose. Thanks to Manfred Lippert for the patch!


### Changes in version 1.6

* New UI element that allows you to run the console without having an icon in your dock.


### Changes in version 1.5

* Click-through to desktop icons. The window is completely transparent, even the pixels covered by the actual text now ignore mouse-clicks.

* Window level option. In previous versions the console text was on the same level as the desktop icons which meant that it was displayed above some icons and below others and this setup would change depending on what you did. Now, you can choose whether the text is always below the icons (default) or always above them. 

* File creation date check on reopen. The entire contents of a given file are redisplayed if MkConsole discovers that its creation date has changed. This should solve the issue with the Folding at Home files.

* Link to the website from Help menu.


Please see <a href="http://www.mulle-kybernetik.com/software/MkConsole">http://www.mulle-kybernetik.com/software/MkConsole</a> for more details.
