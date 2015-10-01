==============================
MODULE camshake_default README
==============================

Author: aznricepuff

------------
INSTALLATION
------------

This module requires the base eXTensible Finishers mod.

1. Copy the "content" folder in the modXTFinishers\camshake_default directory located in the download package into your <The Witcher 3 Path>\mods\modXTFinishers directory. Accept any folder merge requests from your OS/file system.
2. Open modXTFinishers\content\scripts\local\base\xtFinishersManager.ws ...
	a. Copy the following line into the file beneath where it says DEFINE MODULE VARS HERE:
		
		public var camshakeModule : XTFinishersDefaultCamShakeModule;
		
	b. Copy the following lines into the file beneath where it says LOAD MODULES HERE:
	
		// load camshake module
		camshakeModule = new XTFinishersDefaultCamShakeModule in this;
		camshakeModule.Init();
		
	c. In the section marked "COMMENT LINES BELOW TO SELECTIVELY DISABLE VANILLA FUNCTIONALITY", comment out the following line:
		
		vanillaModule.InitCamShakeComponents();
		
	   The line should look like this when you are done:
	   
		//vanillaModule.InitCamShakeComponents();
		
3. Open modXTFinishers\content\scripts\local\base\xtFinishersConsts.ws ...
	a. Copy the following lines into the file beneath where it says MODULE CONSTS GO HERE:
		
		public const var DEFAULT_CAMSHAKE_HANDLER_PRIORITY : int;
			default DEFAULT_CAMSHAKE_HANDLER_PRIORITY = 10;

-------------
CONFIGURATION
-------------

All user-modifiable config options for this module is located in:
	
	modXTFinishers\content\scripts\local\camshake_default\xtFinishersDefaultCamShakeParams.ws
	
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
	
--------------
UNINSTALLATION
--------------

1. Delete the following folder from your <The Witcher 3 Path>\mods\ directory:

		modXTFinishers\content\scripts\local\camshake_default\
		
2. Open modXTFinishers\content\scripts\local\base\xtFinishersManager.ws ...
	a. In the section marked "DEFINE MODULE VARS HERE", remove the following line:
	
		public var camshakeModule : XTFinishersDefaultCamShakeModule;
		
	b. In the section marked "LOAD MODULES HERE", remove the following lines:
		
		// load camshake module
		camshakeModule = new XTFinishersDefaultCamShakeModule in this;
		camshakeModule.Init();
		
	c. If you wish to restore vanilla behavior for finishers, in the section marked "COMMENT LINES BELOW TO SELECTIVELY DISABLE VANILLA FUNCTIONALITY", uncomment the following line:

		//vanillaModule.InitCamShakeComponents();
		
	   The line should look like this when you are done:
	   
		vanillaModule.InitCamShakeComponents();
		
3. Open modXTFinishers\content\scripts\local\base\xtFinishersConsts.ws ...
	a. In the section marked "MODULE CONSTS GO HERE", remove the following lines:
		
		public const var DEFAULT_CAMSHAKE_HANDLER_PRIORITY : int;
			default DEFAULT_CAMSHAKE_HANDLER_PRIORITY = 10;