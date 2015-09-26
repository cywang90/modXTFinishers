class XTFinishersDefaultParams {
	// finisher settings
	public const var FINISHER_REQUIRE_NO_AGGRO, FINISHER_REQUIRE_NAV_CHECK : bool;
		default FINISHER_REQUIRE_NO_AGGRO = true;					// if TRUE -> REGULAR finishers will not trigger if Geralt has aggro.
		default FINISHER_REQUIRE_NAV_CHECK = true;					// if TRUE -> REGULAR finishers will not trigger if there are obstacles (walls, cliffs, objects, etc.) near Geralt.
	public const var FINISHER_CHANCE_OVERRIDE : bool;
		default FINISHER_CHANCE_OVERRIDE = false;					// if TRUE -> the mod will override the vanilla game's formula for calculating the chance to perform REGULAR finishers.
	public const var FINISHER_CHANCE_BASE, FINISHER_CHANCE_LEVEL_BONUS, FINISHER_CHANCE_LEVEL_PENALTY : float;
		default FINISHER_CHANCE_BASE = 0.0;							// Base chance to perform a REGULAR finisher.
		default FINISHER_CHANCE_LEVEL_BONUS = 0.0;					// Bonus chance to perform a REGULAR finisher for every level Geralt is above the enemy.
		default FINISHER_CHANCE_LEVEL_PENALTY = 0.0;				// Penalty to chance to perform a REGULAR finisher for every level Geralt is below the enemy.
	public const var FINISHER_AUTO_CHANCE_EFFECTS, FINISHER_AUTO_CHANCE_CRIT, FINISHER_AUTO_CHANCE_REND, FINISHER_AUTO_CHANCE_LAST_ENEMY : float;
		default FINISHER_AUTO_CHANCE_EFFECTS = 100.0;				// Chance to perform an AUTOMATIC finisher when target has certain effects. Use the Init() function to define which effects.
		default FINISHER_AUTO_CHANCE_CRIT = 0.0;					// Chance to perform an AUTOMATIC finisher on critical hits.
		default FINISHER_AUTO_CHANCE_REND = 0.0;					// Chance to perform an AUTOMATIC dismember on a Rend attack.
		default FINISHER_AUTO_CHANCE_LAST_ENEMY = 100.0;			// Chance to perform an AUTOMATIC finisher when the LAST enemy in combat is killed.
	public const var FINISHER_AUTO_REQUIRE_NO_AGGRO, FINISHER_AUTO_REQUIRE_NAV_CHECK : bool;
		default FINISHER_AUTO_REQUIRE_NO_AGGRO = false;				// if TRUE -> AUTOMATIC finishers will not trigger if Geralt has aggro.
		default FINISHER_AUTO_REQUIRE_NAV_CHECK = false;			// if TRUE -> AUTOMATIC finishers will not trigger if there are obstacles (walls, cliffs, objects, etc.) near Geralt.
	public const var FINISHER_INSTANTKILL_CHANCE_EFFECTS, FINISHER_INSTANTKILL_CHANCE_CRIT, FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY : float;
		default FINISHER_INSTANTKILL_CHANCE_EFFECTS = 100.0;		// Chance to perform an INSTANT-KILL finisher when target has certain effects. Use the Init() function to define which effects.
		default FINISHER_INSTANTKILL_CHANCE_CRIT = 0.0;				// Chance to perform an INSTANT-KILL finisher on critical hits.
		default FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY = 0.0;		// Chance to perform an INSTANT-KILL finisher when the LAST enemy in combat is killed.
	public const var FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO, FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK : bool;
		default FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO = false;		// if TRUE -> INSTANT-KILL finishers will not trigger if Geralt has aggro.
		default FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK = false;		// if TRUE -> INSTANT-KILL finishers will not trigger if there are obstacles (walls, cliffs, objects, etc.) near Geralt.
	
	// dismember settings
	public const var DISMEMBER_AUTO_CHANCE_EFFECTS, DISMEMBER_AUTO_CHANCE_CRIT, DISMEMBER_AUTO_CHANCE_STRONG, DISMEMBER_AUTO_CHANCE_FAST, DISMEMBER_AUTO_CHANCE_REND, DISMEMBER_AUTO_CHANCE_WHIRL, DISMEMBER_AUTO_CHANCE_LAST_ENEMY : float;
		default DISMEMBER_AUTO_CHANCE_EFFECTS = 0.0;				// Chance to perfrom an AUTOMATIC dismember when target has certain effects. Use the Init() function to define which effects.
		default DISMEMBER_AUTO_CHANCE_CRIT = 100.0;					// Chance to perform an AUTOMATIC dismember on a critical hit.
		default DISMEMBER_AUTO_CHANCE_STRONG = 0.0;					// Chance to perform an AUTOMATIC dismember on a strong attack.
		default DISMEMBER_AUTO_CHANCE_FAST = 0.0;					// Chance to perform an AUTOMATIC dismember on a fast attack.
		default DISMEMBER_AUTO_CHANCE_REND = 100.0;					// Chance to perform an AUTOMATIC dismember on a Rend attack.
		default DISMEMBER_AUTO_CHANCE_WHIRL = 100.0;				// Chance to perform an AUTOMATIC dismember on a Whirl attack.
		default DISMEMBER_AUTO_CHANCE_LAST_ENEMY = 100.0;			// Chance to perform an AUTOMATIC dismember when the LAST enemy in combat is killed.
	public const var DISMEMBER_AUTO_EXPLOSION_CHANCE_EFFECTS, DISMEMBER_AUTO_EXPLOSION_CHANCE_CRIT, DISMEMBER_AUTO_EXPLOSION_CHANCE_STRONG, DISMEMBER_AUTO_EXPLOSION_CHANCE_FAST, DISMEMBER_AUTO_EXPLOSION_CHANCE_REND, DISMEMBER_AUTO_EXPLOSION_CHANCE_WHIRL, DISMEMBER_AUTO_EXPLOSION_CHANCE_LAST_ENEMY : float;
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_EFFECTS = 0.0;		// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a target with certain effects.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_CRIT = 0.0;			// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a critical hit.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_STRONG = 0.0;		// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a strong attack.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_FAST = 0.0;			// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a fast attack.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_REND = 100.0;		// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a Rend attack.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_WHIRL = 50.0;		// Chance to cause an explosion when an AUTOMATIC dismember is triggered on a Whirl attack.
		default DISMEMBER_AUTO_EXPLOSION_CHANCE_LAST_ENEMY = 0.0;	// Chance to cause an explosion when an AUTOMATIC dismember is triggered on the LAST enemy in combat.
	public const var DISMEMBER_CAMERA_SHAKE : bool;
		default DISMEMBER_CAMERA_SHAKE = true;						// If TRUE -> Triggers camera shake when a dismember is triggered.
	
	// finisher cam settings
	public const var FINISHER_CAM_CHANCE : float;
		default FINISHER_CAM_CHANCE = 0.0;							// Chance to activate cinematic finisher camera when a finisher is triggered.
	public const var FINISHER_CAM_CHANCE_LAST_ENEMY : float;
		default FINISHER_CAM_CHANCE_LAST_ENEMY = 100.0;				// Chance to activate cinematic finisher camera when a finisher is triggered on the LAST enemy in combat.
	public const var FINISHER_CAM_REQUIRE_NAV_CHECK : bool;
		default FINISHER_CAM_REQUIRE_NAV_CHECK = false;				// if TRUE -> cinematic finisher camera will not activate if there are obstacles (walls, cliffs, objects, etc.) near Geralt.
	
	public var autoFinisherEffectTypes, instantKillFinisherEffectTypes : array<EEffectType>;
	
	public function Init() {
		// load effect types that allow AUTOMATIC finishers (comment to disable, uncomment to enable)
		autoFinisherEffectTypes.PushBack(EET_Confusion);				// Axii stun
		autoFinisherEffectTypes.PushBack(EET_AxiiGuardMe);				// Axii mind control
		autoFinisherEffectTypes.PushBack(EET_Blindness);				// Blindness
		autoFinisherEffectTypes.PushBack(EET_Burning);					// Burning
		//autoFinisherEffectTypes.PushBack(EET_Bleeding);				// Bleeding
		//autoFinisherEffectTypes.PushBack(EET_Poison);					// Poison
		
		// load effect types that allow instant-kill finishers (comment to disable, uncomment to enable)
		instantKillFinisherEffectTypes.PushBack(EET_Confusion);			// Axii stun
		instantKillFinisherEffectTypes.PushBack(EET_AxiiGuardMe);		// Axii mind control
		//instantKillFinisherEffectTypes.PushBack(EET_Blindness);		// Blindness
		//instantKillFinisherEffectTypes.PushBack(EET_Burning);			// Burning
		//instantKillFinisherEffectTypes.PushBack(EET_Bleeding);		// Bleeding
		//instantKillFinisherEffectTypes.PushBack(EET_Poison);			// Poison
	}
}