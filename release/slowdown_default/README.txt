==============================
Default Slowdown Module README
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
	
	modXTFinishers\content\scripts\local\xtFinishersDefaultSlowdownParams.ws
	
Descriptions of what the individual settings do can be found in the comments in the code.

-------------
DOCUMENTATION
-------------

This module adds the ability to control how slow-motion sequences are triggered.

The following terms are used by the module's documentation and related material when discussing slow-motion:
	- Slow-motion SESSION: A single instance of a period of slow-motion with a fixed time-factor and duration.
	- Slow-motion SEQUENCE: A structured, linked group of one or more slow-motion SESSIONS. The SESSIONS contained in a SEQUENCE may or may not be continuous (i.e. there may be delays between one SESSION and the next). Once a SEQUENCE is triggered, it will always play through all of its SESSIONS unless interrupted.

Only one slow-motion sequence can be active at a time. If a new sequence attempts to activate while an earlier one is still active, the new sequence will fail to activate, and the earlier one will continue playing.

If slow-motion can be triggered under more than one condition (e.g. on an attack that is both a critical hit and a dismemberment), the module will select one condition as the "primary" condition on which to trigger the slow-motion. This will determine which specific slow-motion sequence gets played. The order of precedence for the different conditions is as follows:

	1. On finishers.
	2. On dismemberments.
	3. On critical hits.

In a situation where both a slow-motion sequence AND a cinematic finisher is triggered, the cinematic finisher always takes precedent, and the slow-motion sequence will not be activated.

Configuration options provided by this module include:

	- Options to define chance to trigger slow-motion sequences under the following conditions:
		- Target hit by a critical hit.
		- Target killed by a dismemberment.
		- Target killed by a finisher.
	- Options to define duration, slowdown factor, and delay of slow-motion sequences for each of the above conditions.
	- Option to disable camera shake when a slow-motion sequence is triggered.