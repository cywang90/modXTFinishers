===============================
MODULE dismember_default README
===============================

Author: aznricepuff

-------
VERSION
-------

This README is for v2.1.0.

------------
REQUIREMENTS
------------

- The Witcher 3: Wild Hunt Patch 1.10 or later
- BASE eXTensible Finishers v4.0.0 or later

------------
INSTALLATION
------------

1. Copy the "content" folder in the MODULE_dismember_default directory into your <The Witcher 3 Path>\mods\modXTFinishers directory. Accept any folder merge requests from your OS/file system.
2. Open <The Witcher 3 Path>\mods\modXTFinishers\content\scripts\local\base\xtFinishersManager.ws ...
	a. Copy the following line into the file beneath where it says DEFINE MODULE VARS HERE:
		
		public var dismemberModule : XTFinishersDefaultDismemberModule;
		
	b. Copy the following lines into the file beneath where it says LOAD MODULES HERE:
	
		// load dismember module
		dismemberModule = new XTFinishersDefaultDismemberModule in this;
		dismemberModule.Init();
		
	c. In the section marked "COMMENT LINES BELOW TO SELECTIVELY DISABLE VANILLA FUNCTIONALITY", comment out the following line:
		
		vanillaModule.InitDismemberComponents();
		
	   The line should look like this when you are done:
	   
		//vanillaModule.InitDismemberComponents();

-------------
CONFIGURATION
-------------

All user-modifiable config options for this module is located in:
	
	modXTFinishers\content\scripts\local\dismember_default\xtFinishersDefaultDismemberParams.ws
	
Descriptions of what the individual settings do can be found in the comments in the code.

-------------
DOCUMENTATION
-------------

This module changes the way dismemberments are triggered. There are two types of dismemberments defined by the module:
	- REGULAR dismembers: These are dismemberments that are triggered by conditions defined by vanilla game code. In other words, these are the finishers that would have been triggered even if the mod had not been installed.
	- FROZEN dismembers: These are dismemberments that are triggered specifically on frozen enemies. They never cause dismember explosions.
	- BOMB dismembers: These are dismemberments caused by certain bombs. They never cause dismember explosions.
	- BOLT dismembers: These are dismemberments caused by certain crossbow bolts. They never cause dismember explosions.
	- YRDEN dismembers: These are dismemberments caused by Yrden upgraded with Supercharged Glyphs. They always cause dismember explosions.
	- TOXIC CLOUD dismembers: These are dismemberments caused by explosions triggered by lighting gas clouds on fire. They always cause dismember explosions.
	- AUTOMATIC dismembers: These are dismemberments triggered specifically by the mod. They can only be triggered on melee attacks.
	- DEBUG dismembers: These are dismemberments that are triggered by the debug console command ForceDismember().

Dismemberments can trigger on any human or non-human enemy that supports the dismemberment animation - this means most (all?) human enemies and a subset of monsters such as nekkers and drowners. REGULAR and AUTOMATIC dismemberments can trigger when playing as Geralt or as Ciri. The other types of dismemberments generally can only be triggered when playing as Geralt (due to the specific nature of their triggers).

In a situation where both a finisher AND a dismemberment is triggered on the same enemy, the finisher always takes precedent, and the dismemberment will not be activated.

Configuration options provided by this module include:

	- Options to define chance to trigger AUTOMATIC dismemberments under the following conditions:
		- Target has certain effects/debuffs.
		- Target killed by a critical hit.
		- Target killed by a strong attack.
		- Target killed by a fast attack.
		- Target killed by a Rend attack (special strong attack).
		- Target killed by a Whirl attack (special fast attack).
		- Target is the last enemy to be killed in combat.
	- Options to define chance to trigger dismemberment explosions.
	
--------------
UNINSTALLATION
--------------

1. Delete the following folder from your <The Witcher 3 Path>\mods\ directory:

		modXTFinishers\content\scripts\local\dismember_default\
		
2. Open <The Witcher 3 Path>\mods\modXTFinishers\content\scripts\local\base\xtFinishersManager.ws ...
	a. In the section marked "DEFINE MODULE VARS HERE", remove the following line:
	
		public var dismemberModule : XTFinishersDefaultDismemberModule;
		
	b. In the section marked "LOAD MODULES HERE", remove the following lines:
		
		// load camshake module
		dismemberModule = new XTFinishersDefaultDismemberModule in this;
		dismemberModule.Init();
		
	c. If you wish to restore vanilla behavior for dismemberments, in the section marked "COMMENT LINES BELOW TO SELECTIVELY DISABLE VANILLA FUNCTIONALITY", uncomment the following line:

		//vanillaModule.InitDismemberComponents();
		
	   The line should look like this when you are done:
	   
		vanillaModule.InitDismemberComponents();
		
-----------
PERMISSIONS
-----------

I give permission for anyone to use or modify the code contained in this mod. If you publish a work containing code from this mod, either in its original or an altered form, please give credit.

Please do NOT redistribute this mod in its entire, unmodified form without my express consent.