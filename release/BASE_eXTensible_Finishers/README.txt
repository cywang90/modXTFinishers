================================
BASE eXTensible Finishers README
================================

Author: aznricepuff

-------
VERSION
-------

This README is for v4.1.1.

------------
REQUIREMENTS
------------

- The Witcher 3: Wild Hunt Patch 1.11

------------
INSTALLATION
------------

1. Create a folder named "mods" in your <The Witcher 3 Path>\ directory. Skip this step if such a folder already exists.
2. Create a new folder named "modXTFinishers" in your <The Witcher 3 Path>\mods\ directory.
3. Copy the "content" folder in the modXTFinishers\BASE_eXTensible_Finishers directory located in the download package into your <The Witcher 3 Path>\mods\modXTFinishers directory.
4. Create a text file in your "My Documents\The Witcher 3\" directory and name it "mods.settings". Skip this step if you already have a mods.settings file.
5. Add the following lines in your mods.settings file:

[modXTFinishers]
Enabled=1
Priority=1

You can activate and deactivate this mod without doing a complete uninstallation by changing the following line in your mods.settings file under the "[modXTFinishers]" heading:

Enabled=1	-> mod enabled
-OR-
Enabled=0	-> mod disabled

ADDING CUSTOM MODULES
---------------------
Users can create or add modules that can be loaded on top of the base mod. 

The process of installing custom modules will depend on how the module is written, but all modules must be loaded by the mod at run-time before they can take any effect. The recommended method to load a custom module is in the Init() function of XTFinishersManager (located in content\scripts\local\base\xtFinishersManager.ws).

-------------
DOCUMENTATION
-------------

BASE eXtensible Finishers
-------------------------
The BASE package contains the foundation and API of eXTensible Finishers. If no other modules are installed, the BASE package utilizes the vanilla module (included with BASE, not available as a separate module), which simply recapitulates the behavior of the vanilla (un-modded) game using the eXTensible Finishers API. To define custom behavior, users will need to replace the vanilla module by manually installing other modules.
	
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