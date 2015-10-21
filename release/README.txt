===========================
eXTensible Finishers README
===========================

Author: aznricepuff

-------
VERSION
-------

This README is for Release 09, which includes the following components:

BASE		eXTensible Finishers 		v4.1.0
MODULE		finisher_default 			v2.1.0
MODULE		dismember_default 			v2.1.0
MODULE		slowdown_default 			v2.2.0
MODULE		camshake_default			v3.1.0
MODULE		slowdown_tailoredfinishers	v2.0.1

------------
REQUIREMENTS
------------

- The Witcher 3: Wild Hunt Patch 1.10

------------
INSTALLATION
------------

eXTensible Finishers is organized into two main parts: 
	1. The BASE mod. This part of the mod contains the changes to existing script files that set up the framework for the mod to function as well as new script files that expose the API upon which all additional parts of the mod are based.
	2. Multiple optional modules. These modules require the BASE mod to function, but otherwise are completely self-sufficient. They define the behavior and functionality of the mod.
	
There are two ways to install this mod...

OPTION 1: NEXUS MOD MANAGER
---------------------------

OPTION 2: MANUAL INSTALLATION
-----------------------------

1. Create a folder named "mods" in your <The Witcher 3 Path>\ directory. Skip this step if such a folder already exists.
2. Create a new folder named "modXTFinishers" in your <The Witcher 3 Path>\mods\ directory.
3. Create a text file in your My Documents\The Witcher 3\ directory and name it "mods.settings". Skip this step if you already have a mods.settings file.
4. Add the following lines in your mods.settings file:

	[modXTFinishers]
	Enabled=1
	Priority=1

   NOTE: You can activate and deactivate this mod without doing a complete uninstallation by changing the following line in your mods.settings file under the "[modXTFinishers]" heading:

	Enabled=1	-> mod enabled
	-OR-
	Enabled=0	-> mod disabled
	
5. Choose either A, B, or C:
	A. TO INSTALL ONLY THE BASE MOD: Copy the "content" folder in the BASE_eXTensible_Finishers directory into your <The Witcher 3 Path>\mods\modXTFinishers directory.
	
	B. TO INSTALL ONE OF THE PREPACKAGED INSTALLATIONS: Copy the "content" folder in the PREPACKAGE_default or PREPACKAGE_default+tailoredfinishers directory into your <The Witcher 3 Path>\mods\modXTFinishers directory.
	
	C. TO INSTALL MODULES INDIVIDUALLY: Do step 5A. Then for each module you wish to install, follow the instructions in the README.txt file found in the module directory (named MODULE_[module name]).

-----
USAGE
-----

CONFIGURING THE INCLUDED MODULES
--------------------------------
All user-modifiable config options for the modules included in the mod are located in files:
	
	modXTFinishers\content\scripts\local\finisher_default\xtFinishersDefaultFinisherParams.ws
	modXTFinishers\content\scripts\local\dismember_default\xtFinishersDefaultDismemberParams.ws
	modXTFinishers\content\scripts\local\slowdown_default\xtFinishersDefaultSlowdownParams.ws
	modXTFinishers\content\scripts\local\camshake_default\xtFinishersDefaultCamShakeParams.ws
	
Descriptions of what the individual settings do can be found in the comments in the code.

ADDING CUSTOM MODULES
---------------------
Users can create or add modules that are not pre-packaged with the mod. The packaged modules can be used as examples of how to write modules for use with eXTensible Finishers. 

The process of installing custom modules will depend on how the module is written, but all modules must be loaded by the mod at run-time before they can take any effect. The recommended method to load a custom module is in the Init() function of XTFinishersManager (located in content\scripts\local\base\xtFinishersManager.ws).

-------------
DOCUMENTATION
-------------

BASE eXtensible Finishers
-------------------------
The BASE package contains the foundation and API of eXTensible Finishers. If no other modules are installed, the BASE package utilizes the vanilla module (included with BASE, not available as a separate module), which simply recapitulates the behavior of the vanilla (un-modded) game using the eXTensible Finishers API. To define custom behavior, users will need to replace the vanilla module by manually installing other modules.
		
MODULE finisher_default
-----------------------
This module changes the way finishers and cinematic finishers are triggered.

There are five types of finishers defined by the module:
	- REGULAR finishers: These are finishers that are triggered on fatal blows and by conditions defined by vanilla game code. In other words, these are the finishers that would have been triggered even if the mod had not been installed.
	- AUTOMATIC finishers: These are finishers that are triggered on fatal blows and by conditions specifically defined by the mod.
	- INSTANT-KILL finishers: These are finishers that are triggered on non-fatal blows but that lead to an instant-kill. Note that this does not include instant kills against knocked-down enemies, which have their own category (see below).
	- KNOCKDOWN finishers: These are finishers that are triggered specifically on enemies that are knocked down.
	- DEBUG finishers: These are finishers that are triggered by the debug console command ForceFinisher().

Finishers ONLY trigger on melee attacks against human enemies (none of the finisher animations support non-human targets). The ONE exception to this rule is the case of KNOCKDOWN finishers, which can be triggered on knocked-down humans as well as the following monster types: Nekkers, Drowners, Ghouls, Grave Hags, Wolves, Harpies, Sirens, and Boars. Additionally, finishers ONLY trigger when playing as Geralt (Ciri does not have finisher animations).

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
	
MODULE dismember_default
------------------------
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
		
MODULE slowdown_default
-----------------------
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

MODULE camshake_default
-----------------------
This module adds the ability to control how camera shakes are triggered.

If camera shake can be triggered under more than one condition (e.g. on an attack that is both a critical hit and a Rend attack), the module will select one condition as the "primary" condition on which to trigger the camera shake. This will determine the settings of the camera shake that gets played. The order of precedence for the different conditions is as follows:

	1. On dismemberments.
	2. On Rend attacks.
	3. On critical hits.
	4. On fatal hits.
	5. On regular fast/strong attacks.

Configuration options provided by this module include:
	
	- Options to define the chance to trigger camera shake under the following conditions:
		- Target hit by a fast attack.
		- Target hit by a strong attack.
		- Target hit by a Rend attack.
		- Target hit by a critical hit.
		- Target killed.
		- Target killed by a dismemberment.
	- Options to define strength of the camera shake for each of the above conditions.
	
MODULE slowdown_tailoredfinishers
---------------------------------
This module defines slowdown sequences specially tailored for and timed to specific finisher animations. These sequences are based on the timings of the cinematic finisher sequences present in the vanilla game.

This module also overrides the behavior of MODULE slowdown_default so that when a slowdown is triggered on a finisher, the appropriate tailored slowdown sequence will be played instead of the generic sequence defined by MODULE slowdown_default's params file. All other behavior defined by MODULE slowdown_default remains intact.

Use the configuration options provided by MODULE slowdown_default to customize behavior not specifically overridden by this module (see above paragraph). The following configuration options (and only these options) in MODULE slowdown_default are ignored when this module is installed:

	SLOWDOWN_FINISHER_A_FACTOR
	SLOWDOWN_FINISHER_A_DURATION
	SLOWDOWN_FINISHER_A_DELAY
	SLOWDOWN_FINISHER_B_FACTOR
	SLOWDOWN_FINISHER_B_DURATION
	SLOWDOWN_FINISHER_B_DELAY
	
Misc Notes
----------
	- For all the XX_CHANCE settings, if more than one setting applies, then a check is made independently against each applicable XX_CHANCE value, and if ANY check returns TRUE, then the condition is considered satisfied. For example, when checking to see if an AUTOMATIC dismemberment should be performed on a critical hit that is also a Rend attack, the actual chance of passing the check is:
		
		100 * (1 - (100 - DISMEMBER_AUTO_CHANCE_CRIT)/100 * (100 - DISMEMBER_AUTO_CHANCE_REND)/100)
		
	In general, if conditions X_0, X_1, ... , X_n are satisfied, and the defined chance for condition X_i is CHANCE_X_i, then the overall chance of passing the check is:
		
		100 * (1 - (100 - CHANCE_X_0)/100 * (100 - CHANCE_X_1)/100 * ... * (100 - CHANCE_X_n)/100)
		
	- Disabling the last enemy check for cinematic finishers (FINISHER_CAM_REQUIRE_LAST_ENEMY) WILL result in loss of camera control in combat if a cinematic finisher is triggered. Note that Geralt is invincible while you don't have camera control, so you can't die during this time, but there is a period of about two seconds after you regain camera control where the camera behaves weirdly - it seems to lock onto a target, possibly a randomly selected enemy, as if you had a hard target lock enabled. This can be disorienting and can cause you to get hit/die if you aren't used to it, so be warned.
	- Disabling the navigation checks (REQUIRE_NAV_CHECK) for finishers and cinematic finishers may result in animations bugging out in certain situations, for example if Geralt and his target are on stairs. As far as I know, it is a purely visual bug that won't break combat or cause out-of-bounds, but my testing has by no means been exhaustive, so disable these checks at your own risk!
	
-------------
COMPATIBILITY
-------------

This mod makes changes to the following script files:

	- damageManagerProcessor.ws
	- r4Game.ws
	- r4Player.ws
	- syncManager.ws
	
Other mods that change these files will not be compatible out-of-the-box with eXTensible Finishers. In certain cases, you may be able to force compatibility by copying the lines between the "// modXTFinishers" comment tags in the code into the conflicting script files of another mod.

This mod is not compatible with any other mod that changes the behavior of and/or relies on the detection of finishers and dismemberments.

--------------
UNINSTALLATION
--------------

1. Remove the relevant lines in your mods.settings file.
2. Delete the modXTFinishers folder in your "<The Witcher 3 Path>\mods\" directory.

-----------
PERMISSIONS
-----------

I give permission for anyone to use or modify the code contained in this mod. If you publish a work containing code from this mod, either in its original or an altered form, please give credit.

Please do NOT redistribute this mod in its entire, unmodified form without my express consent.