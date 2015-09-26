==============================
Default Finisher Module README
==============================

Author: aznricepuff

------------
INSTALLATION
------------

This module requires the base eXTensible Finishers mod. After installing the base mod, refer to INSTALLATION.txt for instructions on how to install this module.

-------------
CONFIGURATION
-------------

All user-modifiable config options for this module is located in:
	
	modXTFinishers\content\scripts\local\xtFinishersDefaultFinisherParams.ws
	
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
	- Options to define chance to trigger cinematic finishers.
	- Options to disable certain checks that often block cinematic finishers from triggering in the vanilla game:
		- Target must be the last enemy in combat.
		- Geralt must be clear of terrain/object obstacles within a certain distance.