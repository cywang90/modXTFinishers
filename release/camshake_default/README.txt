==============================
Default CamShake Module README
==============================

Author: aznricepuff

------------
INSTALLATION
------------

This module requires the base eXTensible Finishers mod.

1. Copy the "content" folder in the "modXTFinishers\camshake_default" directory into your "<The Witcher 3 Path>\mods\" directory. Accept any folder merge requests from your OS/file system.
2. Open modXTFinishers\content\scripts\local\xtFinishersManager.ws ...
	a. Copy the following line into the file beneath where it says DEFINE MODULE VARS HERE:
		
		public var camshakeModule : XTFinishersDefaultCamShakeModule;
		
	b. Copy the following lines into the file beneath where it says LOAD MODULES HERE:
	
		// load camshake module
		camshakeModule = new XTFinishersDefaultCamShakeModule in this;
		camshakeModule.Init();
		
3. Open modXTFinishers\content\scripts\local\xtFinishersConsts.ws ...
	a. Copy the following lines into the file beneath where it says MODULE CONSTS GO HERE:
		
		public const var DEFAULT_CAMSHAKE_HANDLER_PRIORITY : int;
			default DEFAULT_CAMSHAKE_HANDLER_PRIORITY = 10;

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