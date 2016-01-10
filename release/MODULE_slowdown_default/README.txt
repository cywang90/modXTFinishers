==============================
MODULE slowdown_default README
==============================

Author: aznricepuff

-------
VERSION
-------

This README is for v2.3.1.

------------
REQUIREMENTS
------------

- The Witcher 3: Wild Hunt Patch 1.11 or later
- BASE eXTensible Finishers v4.2.1 or later

------------
INSTALLATION
------------

1. Copy the "content" folder in the MODULE_slowdown_default directory into your <The Witcher 3 Path>\mods\modXTFinishers directory. Accept any folder merge requests from your OS/file system.
2. Open <The Witcher 3 Path>\mods\modXTFinishers\content\scripts\local\base\xtFinishersManager.ws ...
	a. Copy the following line into the file beneath where it says DEFINE MODULE VARS HERE:
		
		public var slowdownModule : XTFinishersDefaultSlowdownModule;
		
	b. Copy the following lines into the file beneath where it says LOAD MODULES HERE:
	
		// load slowdown module
		slowdownModule = new XTFinishersDefaultSlowdownModule in this;
		slowdownModule.Init();

-------------
CONFIGURATION
-------------

All user-modifiable config options for this module is located in:
	
	modXTFinishers\content\scripts\local\slowdown_default\xtFinishersDefaultSlowdownParams.ws
	
Descriptions of what the individual settings do can be found in the comments in the code.

-------------
DOCUMENTATION
-------------

This module adds the ability to control how slow-motion sequences are triggered.

The following terms are used by the module's documentation and related material when discussing slow-motion:
	- Slow-motion SESSION: A single instance of a period of slow-motion with a fixed time-factor and duration.
		- Time factor is defined the ratio: delta(game time) : delta(real time). In other words, it is how many seconds of game (simulation) time will pass in one second of real time.
		- Duration is always expressed in game (simulation) time. To convert to real time, simply divide by the time factor. For example, a session of time-factor 0.5 and duration 0.1 will last 0.1/0.5 = 0.2 seconds in real time.
	- Slow-motion SEQUENCE: A structured, linked group of one or more slow-motion SESSIONS. The SESSIONS contained in a SEQUENCE may or may not be continuous (i.e. there may be delays between one SESSION and the next). Once a SEQUENCE is triggered, it will always play through all of its SESSIONS unless interrupted.

Only one slow-motion sequence can be active at a time. If a new sequence attempts to activate while an earlier one is still active, the new sequence will fail to activate, and the earlier one will continue playing.

If slow-motion can be triggered under more than one condition (e.g. on an attack that is both a critical hit and a dismemberment), the module will select one condition as the "primary" condition on which to trigger the slow-motion. This will determine which specific slow-motion sequence gets played. The order of precedence for the different conditions is as follows:

	1. On finishers.
	2. On dismemberments.
	3. On critical hits.
	4. On fatal hits.

In a situation where both a slow-motion sequence AND a cinematic finisher is triggered, the cinematic finisher always takes precedent, and the slow-motion sequence will not be activated.

Configuration options provided by this module include:

	- Options to define chance to trigger slow-motion sequences under the following conditions:
		- Target hit by a critical hit.
		- Target killed.
		- Target killed by a dismemberment of type:
			- REGULAR
			- FROZEN
			- BOMB
			- BOLT
			- YRDEN
			- TOXIC CLOUD
			- AUTO
		- Target killed by a finisher of type:
			- REGULAR
			- AUTO
			- INSTANT KILL
			- KNOCKDOWN
	- Options to define duration, slowdown factor, and delay of slow-motion sequences for each of the above conditions.
	- Option to disable camera shake when a slow-motion sequence is triggered.
	
--------------
UNINSTALLATION
--------------
	
1. Delete the following folder from your <The Witcher 3 Path>\mods\ directory:

		modXTFinishers\content\scripts\local\slowdown_default\
		
2. Open <The Witcher 3 Path>\mods\modXTFinishers\content\scripts\local\base\xtFinishersManager.ws ...
	a. In the section marked "DEFINE MODULE VARS HERE", remove the following line:
	
		public var slowdownModule : XTFinishersDefaultSlowdownModule;
		
	b. In the section marked "LOAD MODULES HERE", remove the following lines:
		
		// load camshake module
		slowdownModule = new XTFinishersDefaultSlowdownModule in this;
		slowdownModule.Init();
		
-----------
PERMISSIONS
-----------

I give permission for anyone to use or modify the code contained in this mod. If you publish a work containing code from this mod, either in its original or an altered form, please give credit.

Please do NOT redistribute this mod in its entire, unmodified form without my express consent.