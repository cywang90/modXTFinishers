==============================
MODULE finisher_default README
==============================

Author: aznricepuff

-------
VERSION
-------

This README is for v1.04.

------------
REQUIREMENTS
------------

- The Witcher 3: Wild Hunt Patch 1.08 (or hotfix)
- BASE eXTensible Finishers v2.03 or later

------------
INSTALLATION
------------

This module requires the base eXTensible Finishers mod (BASE eXTensible Finishers v2.03 or later).

1. Copy the "content" folder in the modXTFinishers\finisher_default directory located in the download package into your <The Witcher 3 Path>\mods\modXTFinishers directory. Accept any folder merge requests from your OS/file system.
2. Open modXTFinishers\content\scripts\local\base\xtFinishersManager.ws ...
	a. Copy the following line into the file beneath where it says DEFINE MODULE VARS HERE:
		
		public var finisherModule : XTFinishersDefaultFinisherModule;
		
	b. Copy the following lines into the file beneath where it says LOAD MODULES HERE:
	
		// load finisher module
		finisherModule = new XTFinishersDefaultFinisherModule in this;
		finisherModule.Init();
		
	c. In the section marked "COMMENT LINES BELOW TO SELECTIVELY DISABLE VANILLA FUNCTIONALITY", comment out the following line:
		
		vanillaModule.InitFinisherComponents();
		
	   The line should look like this when you are done:
	   
		//vanillaModule.InitFinisherComponents();

-------------
CONFIGURATION
-------------

All user-modifiable config options for this module is located in:
	
	modXTFinishers\content\scripts\local\finisher_default\xtFinishersDefaultFinisherParams.ws
	
Descriptions of what the individual settings do can be found in the comments in the code.

-------------
DOCUMENTATION
-------------

This module changes the way finishers and cinematic finishers are triggered.

There are four types of finishers defined by the module:
	- REGULAR finishers: These are finishers that are triggered on fatal blows and by conditions defined by vanilla game code. In other words, these are the finishers that would have been triggered even if the mod had not been installed.
	- AUTOMATIC finishers: These are finishers that are triggered on fatal blows and by conditions specifically defined by the mod.
	- INSTANT-KILL finishers: These are finishers that are triggered on non-fatal blows but that lead to an instant-kill.
	- FORCED finishers: This is a special type of finisher that only happens when the target has a specific 'ForceFinisher' tag applied to them.

Finishers ONLY trigger on human enemies (this is a condition imposed by the base game, as none of the finisher animations support non-human targets) and ONLY trigger when playing as Geralt (again, a condition imposed by the base game, as Ciri does not have finisher animations).

In a situation where both a finisher AND a dismemberment is triggered on the same enemy, the finisher always takes precedent, and the dismemberment will not be activated.

Cinematic finishers are finishers that also activate a cinematic camera mode and an associated slow-motion sequence. Any finisher (REGULAR, AUTOMATIC, INSTANT-KILL, or FORCED) can potentially be turned into a cinematic finisher.

Configuration options provided by this module include:

	- Option to override vanilla game calculations for determining chance to trigger REGULAR finishers.
	- Options to define chance to trigger AUTOMATIC finishers under the following conditions:
		- Target has certain effects/debuffs.
		- Target killed by a critical hit.
		- Target is the last enemy to be killed in combat.
	- Options to define chance to trigger INSTANT-KILL finishers under the following conditions:
		- Target has certain effects/debuffs.
		- Target struck by a critical hit.
		- Target is the last enemy in combat.
	- Options to disable certain checks that often block finishers from triggering in the vanilla game:
		- Geralt must not be under attack by enemies other than the target.
		- Geralt must be clear of terrain/object obstacles within a certain distance.
	- Options to choose which finisher animations the game is allowed to play.
	- Options to define chance to trigger cinematic finishers.
	- Options to disable certain checks that often block cinematic finishers from triggering in the vanilla game:
		- Target must be the last enemy in combat.
		- Geralt must be clear of terrain/object obstacles within a certain distance.
		
--------------
UNINSTALLATION
--------------

1. Delete the following folder from your <The Witcher 3 Path>\mods\ directory:

		modXTFinishers\content\scripts\local\finisher_default\
		
2. Open modXTFinishers\content\scripts\local\base\xtFinishersManager.ws ...
	a. In the section marked "DEFINE MODULE VARS HERE", remove the following line:
	
		public var finisherModule : XTFinishersDefaultFinisherModule;
		
	b. In the section marked "LOAD MODULES HERE", remove the following lines:
		
		// load camshake module
		finisherModule = new XTFinishersDefaultFinisherModule in this;
		finisherModule.Init();
		
	c. If you wish to restore vanilla behavior for finishers, in the section marked "COMMENT LINES BELOW TO SELECTIVELY DISABLE VANILLA FUNCTIONALITY", uncomment the following line:

		//vanillaModule.InitFinisherComponents();
		
	   The line should look like this when you are done:
	   
		vanillaModule.InitFinisherComponents();
		
-----------
PERMISSIONS
-----------

I give permission for anyone to use or modify the code contained in this mod. If you publish a work containing code from this mod, either in its original or an altered form, please give credit.

Please do NOT redistribute this mod in its entire, unmodified form without my express consent.