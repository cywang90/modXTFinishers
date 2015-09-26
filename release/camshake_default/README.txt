==============================
Default CamShake Module README
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
	
	modXTFinishers\content\scripts\local\xtFinishersDefaultCamShakeParams.ws
	
Descriptions of what the individual settings do can be found in the comments in the code.

-------------
DOCUMENTATION
-------------

This module adds the ability to control how camera shakes are triggered.

If camera shake can be triggered under more than one condition (e.g. on an attack that is both a critical hit and a Rend attack), the module will select one condition as the "primary" condition on which to trigger the camera shake. This will determine the settings of the camera shake that gets played. The order of precedence for the different conditions is as follows:

	1. On dismemberments.
	2. On Rend attacks.
	3. On critical hits.

Configuration options provided by this module include:
	
	- Options to define whether to trigger camera shake under the following conditions:
		- Target hit by a Rend attack.
		- Target hit by a critical hit.
		- Target killed by a dismemberment.
	- Options to define strength of the camera shake for each of the above conditions.