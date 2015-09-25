===========================
eXTensible Finishers README
===========================

Author: aznricepuff

------------
INSTALLATION
------------

1. Copy the modXTFinishers folder into your "<The Witcher 3 Path>\mods\" directory. If you don't have a folder called "mods" in your witcher 3 path, go ahead and create one.
2. Create a text file in your "My Documents\The Witcher 3\" directory and name it "mods.settings". Skip this step if you already have a mods.settings file.
3. Add the following lines in your "mods.settings" file:

[modXTFinishers]
Enabled=1
Priority=1

-----
USAGE
-----

All user-modifiable config options are located in file:
	
	modXTFinishers\content\scripts\local\xtFinishersParams.ws
	
Descriptions of what the individual settings do can be found in the comments in the code.


DOCUMENTATION
-------------

eXTensible Finishers performs three basic functions by default:

	- Controls when finishers and dismemberments are triggered.
	- Controls when cinematic finishers and slow-motion sequences are triggered in response to finishers and dismemberments.
	- Exposes an API based on the Observer Pattern that allows code to listen for the following events:
		- A finisher is triggered.
		- A dismemberment is triggered.
		- A cinematic finisher is triggered.
		- A slow-motion sequence is triggered.
		
Default Functionality
---------------------

eXTensible Finishers is set up to provide a certain functionality "out of the box". This functionality is activated by default when the mod is installed. What follows is a high-level description of this default functionality...

	*Finishers*
		This mod changes the way finishers are triggered. There are four types of finishers defined by the mod:
			- REGULAR finishers: These are finishers that are triggered on fatal blows and by conditions defined by vanilla game code. In other words, these are the finishers that would have been triggered even if the mod had not been installed.
			- AUTOMATIC finishers: These are finishers that are triggered on fatal blows and by conditions specifically defined by the mod.
			- INSTANT-KILL finishers: These are finishers that are triggered on non-fatal blows but that lead to an instant-kill.
			- FORCED finishers: This is a special type of finisher that only happens when the target has a specific 'ForceFinisher' tag applied to them.
			
		Finishers ONLY trigger on human enemies (this is a condition imposed by the base game, as none of the finisher animations support non-human targets) and ONLY trigger when playing as Geralt (again, a condition imposed by the base game, as Ciri does not have finisher animations).
	
	*Dismemberments*
		This mod changes the way dismemberments are triggered. There are two types of dismemberments defined by the mod:
			- REGULAR dismemberments: These are dismemberments that are triggered by conditions defined by vanilla game code. In other words, these are the finishers that would have been triggered even if the mod had not been installed.
			- AUTOMATIC dismemberments: These are dismemberments triggered specifically by the mod.
		
		Dismemberments can trigger on any human or non-human enemy that supports the dismemberment animation - this means most (all?) human enemies and a small subset of monsters such as nekkers and drowners. REGULAR finishers can trigger when playing as Geralt or as Ciri. AUTOMATIC finishers can only trigger when playing as Geralt.
		
		In a situation where both a finisher AND a dismemberment is triggered on the same enemy, the finisher always takes precedent, and the dismemberment will not be activated.
		
	*Cinematic Finishers*
		This mod changes the way cinematic finishers are triggered. Cinematic finishers are simply finishers that also activate a cinematic camera mode and an associated slow-motion sequence. Any finisher (REGULAR, AUTOMATIC, INSTANT-KILL, or FORCED) can potentially be turned into a cinematic finisher.
		
	*Slow-motion*
		This mod adds the ability for finishers and dismemberments to trigger slow-motion. The following terms are used by the mod's documentation and related material when discussing slow-motion:
			- Slow-motion SESSION: A single instance of a period of slow-motion with a fixed time-factor and duration.
			- Slow-motion SEQUENCE: A structured, linked group of one or more slow-motion SESSIONS. The SESSIONS contained in a SEQUENCE may or may not be continuous (i.e. there may be gaps between one SESSION and the next). Once a SEQUENCE is triggered, it will always play through all of its SESSIONS unless interrupted.
		
		Only one slow-motion sequence can be active at a time. If a new sequence attempts to activate while an earlier one is still active, the new sequence will fail to activate, and the earlier one will continue playing.
		
		In a situation where both a slow-motion sequence AND a cinematic finisher is triggered, the cinematic finisher always takes precedent, and the slow-motion sequence will not be activated.
		
Configuring the Default Functionality
-------------------------------------

The default functionality of the mod can be configured to suit the preferences of the individual user. All configuration options are located in:
	
	modXTFinishers\content\scripts\local\xtFinishersParams.ws

Configuration is accomplished through changing the values of the const variables defined in the file or in some cases commenting and un-commenting certain lines. The file contains comments with detailed descriptions of what each option does. What follows is a summary of the configurable features supported by default:

	*Finishers*
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
	
	*Dismemberments*
		- Options to define chance to trigger AUTOMATIC dismemberments under the following conditions:
			- Target killed by a critical hit.
			- Target killed by a strong attack.
			- Target killed by a fast attack.
			- Target killed by a Rend attack (special strong attack).
			- Target killed by a Whirl attack (special fast attack).
			- Target is the last enemy to be killed in combat.
		- Options to define chance to trigger dismemberment explosions.
	
	*Cinematic Finishers*
		- Options to define chance to trigger cinematic finishers.
		- Options to disable certain checks that often block cinematic finishers from triggering in the vanilla game:
			- Target must be the last enemy in combat.
			- Geralt must be clear of terrain/object obstacles within a certain distance.
			
	*Slow-motion*
		- Options to define chance to trigger slow-motion sequences during finishers and dismemberments.
		
	*Misc Notes*
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