
### CrashLanding ###

===========================================================================
DESCRIPTION:

Demonstrates how to do build a full OpenGL-based game with sound effects, and using the accelerometer as a game controller. Simply build the sample using Xcode and run it on the device. (This project hasn't yet been updated to run in the simulator.) Then follow the instructions to play the game. Tap on the screen at any time to start a new game immediately.

This sample also shows how to save game high-scores in the application's preferences.

===========================================================================
BUILD REQUIREMENTS:

Mac OS X 10.5.3, Xcode 3.1, iPhone OS 2.0

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X 10.5.3, iPhone OS 2.0

===========================================================================
PACKAGING LIST:

AppController.h
AppController.m
the UIApplication delegate class, which is the central controller of the application.

AudioSupport/SoundEngine.h
AudioSupport/SoundEngine.cpp
These functions use OpenAL to play background music tracks, multiple sound effects, and support stereo panning with a low-latency response.

OpenGLSupport/Texture2D.h
OpenGLSupport/Texture2D.m
Convenience class that allows to create OpenGL 2D textures from images, text or raw data.

main.m
The entry point for the application.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.7
- Updated for and tested with iPhone OS 2.0. First public release.

Version 1.6
- Fixed problem where lander sometimes moved in same direction as thrust
- Now use nib file for window definition and top-level connections.
- Replaced EAGLView class with MyEAGLView.
- Removed GameView, since MyEAGLView handles touches.

Version 1.5
- Simplified the Texture2D class.

Version 1.4
- Updated for Beta 6
- Renamed from LunarLander to CrashLanding
- Updated for changes in the EAGL API.

Version 1.3
- Updated for Beta 5

Version 1.2
- Updated for Beta 4
- Updated build settings
- Updated ReadMe file format

Version 1.1
- NA
===========================================================================
Copyright (C) 2008 Apple Inc. All rights reserved.