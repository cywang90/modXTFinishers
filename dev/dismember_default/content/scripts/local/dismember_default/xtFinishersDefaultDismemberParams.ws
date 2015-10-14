class XTFinishersDefaultDismemberParams {
	//=============================
	// AUTOMATIC DISMEMBER SETTINGS
	//=============================
	
	public const var DISMEMBER_AUTO_CHANCE_EFFECTS, DISMEMBER_AUTO_CHANCE_CRIT, DISMEMBER_AUTO_CHANCE_STRONG, DISMEMBER_AUTO_CHANCE_FAST, DISMEMBER_AUTO_CHANCE_REND, DISMEMBER_AUTO_CHANCE_WHIRL, DISMEMBER_AUTO_CHANCE_LAST_ENEMY : float;
		default DISMEMBER_AUTO_CHANCE_EFFECTS = 0.0;				// Chance to perform an AUTOMATIC dismember when target has certain effects. Use the Init() function to define which effects.
		default DISMEMBER_AUTO_CHANCE_CRIT = 100.0;					// Chance to perform an AUTOMATIC dismember on a critical hit.
		default DISMEMBER_AUTO_CHANCE_STRONG = 0.0;					// Chance to perform an AUTOMATIC dismember on a strong attack.
		default DISMEMBER_AUTO_CHANCE_FAST = 0.0;					// Chance to perform an AUTOMATIC dismember on a fast attack.
		default DISMEMBER_AUTO_CHANCE_REND = 100.0;					// Chance to perform an AUTOMATIC dismember on a Rend attack.
		default DISMEMBER_AUTO_CHANCE_WHIRL = 100.0;				// Chance to perform an AUTOMATIC dismember on a Whirl attack.
		default DISMEMBER_AUTO_CHANCE_LAST_ENEMY = 100.0;			// Chance to perform an AUTOMATIC dismember when the LAST enemy in combat is killed.
	
	//=======================================
	// AUTOMATIC DISMEMBER EXPLOSION SETTINGS
	//=======================================
	
	public const var DISMEMBER_AUTO_EXPLOSION_CHANCE_EFFECTS, DISMEMBER_AUTO_EXPLOSION_CHANCE_CRIT, DISMEMBER_AUTO_EXPLOSION_CHANCE_STRONG, DISMEMBER_AUTO_EXPLOSION_CHANCE_FAST, DISMEMBER_AUTO_EXPLOSION_CHANCE_REND, DISMEMBER_AUTO_EXPLOSION_CHANCE_WHIRL, DISMEMBER_AUTO_EXPLOSION_CHANCE_LAST_ENEMY : float;
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_EFFECTS = 0.0;		// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a target with certain effects.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_CRIT = 0.0;			// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a critical hit.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_STRONG = 0.0;		// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a strong attack.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_FAST = 0.0;			// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a fast attack.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_REND = 100.0;		// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a Rend attack.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_WHIRL = 50.0;		// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a Whirl attack.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_LAST_ENEMY = 0.0;	// Chance to cause an explosion when an AUTOMATIC dismember is triggered on the LAST enemy in combat.
		
	public var autoDismemberEffectTypes : array<EEffectType>;
	
	public function Init() {
		//====================================
		// AUTOMATIC DISMEMBER EFFECT TRIGGERS
		//====================================
		
		// load effect types that allow AUTOMATIC dismembers (comment to disable, uncomment to enable)
		//autoDismemberEffectTypes.PushBack(EET_Confusion);				// Axii stun
		//autoDismemberEffectTypes.PushBack(EET_AxiiGuardMe);			// Axii mind control
		//autoDismemberEffectTypes.PushBack(EET_Blindness);				// Blindness
		//autoDismemberEffectTypes.PushBack(EET_Burning);				// Burning
		//autoDismemberEffectTypes.PushBack(EET_Bleeding);				// Bleeding
		//autoDismemberEffectTypes.PushBack(EET_Poison);				// Poison
	}
}