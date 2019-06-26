iMobileDevice
===========

iMobileDevice is an Objective-C framework that wraps [libimobiledevice](http://www.libimobiledevice.org).
libimobiledevice is an open source library for communicating with iOS device natively.

This project also contains a test application which showcases various features, and how to query properties, retrieve the devices wallpaper and take screenshots of the device.

Currently only the following features from libimobiledevice are supported:
* Finding basic device information (name, product type, color, height/width, scale factor)
* Querying Lockdownd key/domain properties
* Getting installed applications
* Retrieving the icon for an installed application
* Device screenshot
* Retrieving device wallpaper

![iMobileDevice test app](/Screenshot-testApp.png?raw=true)

## A small note about libimobiledevice
Compiling the libimobiledevice framework was a hassle... so the pragmatic solution was to install libimobiledevice via homebrew, and copy the frameworks and headers into the project. 
One day I'll invest some time into trying to sort this out, as it really isn't ideal. 

But for now, it works.

#### Steps to rebuild libimobiledevice:

**Install homebrew:**  
ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

**Install libimobiledevice:**  
brew install -v --devel --fresh  automake autoconf libtool wget libimobiledevice  
brew install -v --HEAD --fresh --build-from-source ideviceinstaller

Then the compiled frameworks will be located in the following directory:  
/usr/local/Cellar/
