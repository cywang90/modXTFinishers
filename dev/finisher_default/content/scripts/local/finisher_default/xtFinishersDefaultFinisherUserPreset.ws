class XTFinishersDefaultFinisherUserPreset extends XTFinishersObject {
	private function DefineUserCustomParams() {
		//=====================================
		// USER-MODIFIABLE CONFIG SETTINGS HERE
		//=====================================
		
		//==================
		// FINISHER SETTINGS
		//==================
		
		// REGULAR finishers
		AddParamBool("FINISHER_REQUIRE_NO_AGGRO", true);					// if TRUE -> REGULAR finishers will not trigger if Geralt has aggro.
		AddParamBool("FINISHER_REQUIRE_NAV_CHECK", true);					// if TRUE -> REGULAR finishers will not trigger if there are obstacles (walls, cliffs, objects, etc.) near Geralt.
		AddParamBool("FINISHER_CHANCE_OVERRIDE", false);					// if TRUE -> the mod will override the vanilla game's formula for calculating the chance to perform REGULAR finishers.

		AddParamFloat("FINISHER_CHANCE_BASE", 0.0);							// Base chance to perform a REGULAR finisher.
		AddParamFloat("FINISHER_CHANCE_LEVEL_BONUS", 0.0);					// Bonus chance to perform a REGULAR finisher for every level Geralt is above the enemy.
		AddParamFloat("FINISHER_CHANCE_LEVEL_PENALTY", 0.0);				// Penalty to chance to perform a REGULAR finisher for every level Geralt is below the enemy.
		
		// AUTOMATIC finishers
		AddParamFloat("FINISHER_AUTO_CHANCE_EFFECTS", 100.0);				// Chance to perform an AUTOMATIC finisher when target has certain effects. Use the Init() function to define which effects.
		AddParamFloat("FINISHER_AUTO_CHANCE_CRIT", 0.0);					// Chance to perform an AUTOMATIC finisher on critical hits.
		AddParamFloat("FINISHER_AUTO_CHANCE_REND", 0.0);					// Chance to perform an AUTOMATIC dismember on a Rend attack.
		AddParamFloat("FINISHER_AUTO_CHANCE_LAST_ENEMY", 100.0);			// Chance to perform an AUTOMATIC finisher when the LAST enemy in combat is killed.
		
		AddParamBool("FINISHER_AUTO_REQUIRE_NO_AGGRO", false);				// if TRUE -> AUTOMATIC finishers will not trigger if Geralt has aggro.
		AddParamBool("FINISHER_AUTO_REQUIRE_NAV_CHECK", false);				// if TRUE -> AUTOMATIC finishers will not trigger if there are obstacles (walls, cliffs, objects, etc.) near Geralt.
		
		// INSTANT-KILL finishers
		AddParamFloat("FINISHER_INSTANTKILL_CHANCE_EFFECTS", 100.0);		// Chance to perform an INSTANT-KILL finisher when target has certain effects. Use the Init() function to define which effects.
		AddParamFloat("FINISHER_INSTANTKILL_CHANCE_CRIT", 0.0);				// Chance to perform an INSTANT-KILL finisher on critical hits.
		AddParamFloat("FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY", 0.0);		// Chance to perform an INSTANT-KILL finisher when the LAST enemy in combat is killed.
		
		AddParamBool("FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO", false);		// if TRUE -> INSTANT-KILL finishers will not trigger if Geralt has aggro.
		AddParamBool("FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK", false);		// if TRUE -> INSTANT-KILL finishers will not trigger if there are obstacles (walls, cliffs, objects, etc.) near Geralt.
		
		//======================
		// FINISHER CAM SETTINGS
		//======================
		
		AddParamBool("FINISHER_CAM_DISABLE_CAMERA_SHAKE", true);			// If TRUE -> prevents camera shake when cinematic finisher camera is activated.
		
		AddParamFloat("FINISHER_CAM_CHANCE", 0.0);							// Chance to activate cinematic finisher camera when a finisher is triggered.
		AddParamFloat("FINISHER_CAM_CHANCE_LAST_ENEMY", 100.0);				// Chance to activate cinematic finisher camera when a finisher is triggered on the LAST enemy in combat.
		
		AddParamBool("FINISHER_CAM_REQUIRE_NAV_CHECK", false);				// if TRUE -> cinematic finisher camera will not activate if there are obstacles (walls, cliffs, objects, etc.) near Geralt.
		
		//===================================
		// AUTOMATIC FINISHER EFFECT TRIGGERS
		//===================================
		
		// load effect types that allow AUTOMATIC finishers (comment to disable, uncomment to enable)
		autoFinisherEffectTypes.PushBack(EET_Confusion);					// Axii stun
		autoFinisherEffectTypes.PushBack(EET_AxiiGuardMe);					// Axii mind control
		autoFinisherEffectTypes.PushBack(EET_Blindness);					// Blindness
		autoFinisherEffectTypes.PushBack(EET_Burning);						// Burning
		//autoFinisherEffectTypes.PushBack(EET_Bleeding);					// Bleeding
		//autoFinisherEffectTypes.PushBack(EET_Poison);						// Poison
		
		//======================================
		// INSTANT-KILL FINISHER EFFECT TRIGGERS
		//======================================
		
		// load effect types that allow instant-kill finishers (comment to disable, uncomment to enable)
		instantKillFinisherEffectTypes.PushBack(EET_Confusion);				// Axii stun
		instantKillFinisherEffectTypes.PushBack(EET_AxiiGuardMe);			// Axii mind control
		//instantKillFinisherEffectTypes.PushBack(EET_Blindness);			// Blindness
		//instantKillFinisherEffectTypes.PushBack(EET_Burning);				// Burning
		//instantKillFinisherEffectTypes.PushBack(EET_Bleeding);			// Bleeding
		//instantKillFinisherEffectTypes.PushBack(EET_Poison);				// Poison
		
		//====================
		// FINISHER ANIMATIONS
		//====================
		
		// load allowed finisher animations (comment to disable, uncomment to enable)
		
		allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_HEAD_ONE);
		allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_HEAD_TWO);
		allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_NECK);
		allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_THRUST_ONE);
		allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_THRUST_TWO);
		
		allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_RIGHT_HEAD);
		allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_RIGHT_THRUST_ONE);
		allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_RIGHT_THRUST_TWO);
		
		//========================
		// DLC FINISHER ANIMATIONS
		//========================
		
		// load allowed DLC finisher animations (comment to disable, uncomment to enable)
		
		dlcFinishers = theGame.GetSyncAnimManager().dlcFinishersRightSide;
		if (dlcFinishers.Size() > 0) {
			allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_LEFT_ARM);
			allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_LEFT_LEGS);
			allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_LEFT_TORSO);
			
			allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_ARM);
			allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_LEGS);
			allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_TORSO);
			allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_HEAD);
			allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_NECK);
		}
	}
	
	// DO NOT CHANGE ---------------------------------------------
	public var preset : XTFinishersParamsPreset;
	
	private var autoFinisherEffectTypes, instantKillFinisherEffectTypes : array<EEffectType>;
	private var allowedLeftSideFinisherAnimNames, allowedRightSideFinisherAnimNames : array<name>;
	private var dlcFinishers : array<CR4FinisherDLC>;
	// DO NOT CHANGE ---------------------------------------------
	
	public function Init() {
		// DO NOT CHANGE ---------------------------------------------
		preset = new XTFinishersParamsPreset in this;
		
		DefineUserCustomParams();
		
		preset.AddParam(CreateXTFinishersParamDefDefaultFinisherEffectTypeArray(this, "autoFinisherEffectTypes", autoFinisherEffectTypes));
		preset.AddParam(CreateXTFinishersParamDefDefaultFinisherEffectTypeArray(this, "instantKillFinisherEffectTypes", instantKillFinisherEffectTypes));
		preset.AddParam(CreateXTFinishersParamDefDefaultFinisherNameArray(this, "allowedLeftSideFinisherAnimNames", allowedLeftSideFinisherAnimNames));
		preset.AddParam(CreateXTFinishersParamDefDefaultFinisherNameArray(this, "allowedRightSideFinisherAnimNames", allowedRightSideFinisherAnimNames));
		// DO NOT CHANGE ---------------------------------------------
	}
	
	// convenience functions
	
	// DO NOT CHANGE ---------------------------------------------
	public function AddParamFloat(id : string, value : float) {
		preset.AddParam(CreateXTFinishersParamDefFloat(this, id, value));
	}
	
	public function AddParamBool(id : string, value : bool) {
		preset.AddParam(CreateXTFinishersParamDefBool(this, id, value));
	}
	// DO NOT CHANGE ---------------------------------------------
}