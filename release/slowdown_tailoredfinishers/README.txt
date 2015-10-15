========================================
MODULE slowdown_tailoredfinishers README
========================================

Author: aznricepuff

-------
VERSION
-------

This README is for v2.0.1.

------------
REQUIREMENTS
------------

- The Witcher 3: Wild Hunt Patch 1.08 or later
- BASE eXTensible Finishers v2.03 or later
- MODULE slowdown_default v1.03 or later

------------
INSTALLATION
------------

1. Make sure MODULE slowdown_default is already installed.
2. Copy the "content" folder in the modXTFinishers\slowdown_tailoredfinishers directory located in the download package into your <The Witcher 3 Path>\mods\modXTFinishers directory. Accept any folder merge requests from your OS/file system.
3. Open modXTFinishers\content\scripts\local\base\xtFinishersManager.ws ...
	a. Find the following lines in the section labeled LOAD MODULES HERE:
	
		// load slowdown module
		slowdownModule = new XTFinishersDefaultSlowdownModule in this;
		slowdownModule.Init();
		
	   ... and change them to this:
	   
		// load slowdown module
		slowdownModule = new XTFinishersTailoredFinishersSlowdownModule in this;
		slowdownModule.Init();

-------------
CONFIGURATION
-------------

This module has no configuration options specific to it. Use the configuration options provided by MODULE slowdown_default instead.

-------------
DOCUMENTATION
-------------

This module defines slowdown sequences specially tailored for and timed to specific finisher animations. These sequences are based on the timings of the cinematic finisher sequences present in the vanilla game.

This module also overrides the behavior of MODULE slowdown_default so that when a slowdown is triggered on a finisher, the appropriate tailored slowdown sequence will be played instead of the generic sequence defined by MODULE slowdown_default's params file. All other behavior defined by MODULE slowdown_default remains intact.

Use the configuration options provided by MODULE slowdown_default to customize behavior not specifically overridden by this module (see above paragraph). The following configuration options (and only these options) in MODULE slowdown_default are ignored when this module is installed:

	SLOWDOWN_FINISHER_A_FACTOR
	SLOWDOWN_FINISHER_A_DURATION
	SLOWDOWN_FINISHER_A_DELAY
	SLOWDOWN_FINISHER_B_FACTOR
	SLOWDOWN_FINISHER_B_DURATION
	SLOWDOWN_FINISHER_B_DELAY
	
--------------
UNINSTALLATION
--------------
	
1. Delete the following folder from your <The Witcher 3 Path>\mods\ directory:

		modXTFinishers\content\scripts\local\slowdown_tailoredfinishers\
		
2. Open modXTFinishers\content\scripts\local\base\xtFinishersManager.ws ...
	a. Find the following lines in the section labeled LOAD MODULES HERE:
	
		// load slowdown module
		slowdownModule = new XTFinishersTailoredFinishersSlowdownModule in this;
		slowdownModule.Init();
		
	   ... and change them to this:
	   
		// load slowdown module
		slowdownModule = new XTFinishersDefaultSlowdownModule in this;
		slowdownModule.Init();
		
-----------
PERMISSIONS
-----------

I give permission for anyone to use or modify the code contained in this mod. If you publish a work containing code from this mod, either in its original or an altered form, please give credit.

Please do NOT redistribute this mod in its entire, unmodified form without my express consent.