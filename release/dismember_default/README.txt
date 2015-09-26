===============================
Default Dismember Module README
===============================

Author: aznricepuff

------------
INSTALLATION
------------

This module requires the base eXTensible Finishers mod. After installing the base mod, refer to INSTALLATION.txt for instructions on how to install this module.

-------------
CONFIGURATION
-------------

All user-modifiable config options for this module is located in:
	
	modXTFinishers\content\scripts\local\xtFinishersDefaultDismemberParams.ws
	
Descriptions of what the individual settings do can be found in the comments in the code.

-------------
DOCUMENTATION
-------------

This module changes the way dismemberments are triggered. There are two types of dismemberments defined by the module:
	- REGULAR dismemberments: These are dismemberments that are triggered by conditions defined by vanilla game code. In other words, these are the finishers that would have been triggered even if the mod had not been installed.
	- AUTOMATIC dismemberments: These are dismemberments triggered specifically by the mod.

Dismemberments can trigger on any human or non-human enemy that supports the dismemberment animation - this means most (all?) human enemies and a small subset of monsters such as nekkers and drowners. REGULAR finishers can trigger when playing as Geralt or as Ciri. AUTOMATIC finishers can only trigger when playing as Geralt.

In a situation where both a finisher AND a dismemberment is triggered on the same enemy, the finisher always takes precedent, and the dismemberment will not be activated.

Configuration options provided by this module include:

	- Options to define chance to trigger AUTOMATIC dismemberments under the following conditions:
		- Target killed by a critical hit.
		- Target killed by a strong attack.
		- Target killed by a fast attack.
		- Target killed by a Rend attack (special strong attack).
		- Target killed by a Whirl attack (special fast attack).
		- Target is the last enemy to be killed in combat.
	- Options to define chance to trigger dismemberment explosions.