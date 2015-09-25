class XTFinishersParams {
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
	
	// finisher slowdown settings
	public const var SLOWDOWN_FINISHER_CHANCE, SLOWDOWN_FINISHER_AUTO_CHANCE : float;
		default SLOWDOWN_FINISHER_CHANCE = 100.0;					// Chance to activate slow motion when a REGULAR finisher is triggered.
		default SLOWDOWN_FINISHER_AUTO_CHANCE = 100.0;				// Chance to activate slow motion when an AUTOMATIC finisher is triggered.
	public const var SLOWDOWN_FINISHER_CHANCE_LAST_ENEMY, SLOWDOWN_FINISHER_AUTO_CHANCE_LAST_ENEMY : float;
		default SLOWDOWN_FINISHER_CHANCE_LAST_ENEMY = 100.0;		// Chance to activate slow motion when a REGULAR finisher is triggered on the LAST enemy in combat.
		default SLOWDOWN_FINISHER_AUTO_CHANCE_LAST_ENEMY = 100.0;	// Chance to activate slow motion when an AUTOMATIC finisher is triggered on the LAST enemy in combat.
	public const var SLOWDOWN_FINISHER_A_FACTOR, SLOWDOWN_FINISHER_A_DURATION, SLOWDOWN_FINISHER_A_DELAY : float;
		default SLOWDOWN_FINISHER_A_FACTOR = 0.3;					// Time factor for first slow motion section during a finisher (smaller number = more slowdown).
		default SLOWDOWN_FINISHER_A_DURATION = 0.3;					// Duration of first slow motion section during a finisher (seconds in game time).
		default SLOWDOWN_FINISHER_A_DELAY = 0.0;					// Delay after finisher is triggered before first slow motion section activates (seconds in game time).
	public const var SLOWDOWN_FINISHER_B_FACTOR, SLOWDOWN_FINISHER_B_DURATION, SLOWDOWN_FINISHER_B_DELAY : float;
		default SLOWDOWN_FINISHER_B_FACTOR = 0.3;					// Time factor for second slow motion section during a finisher (smaller number = more slowdown).
		default SLOWDOWN_FINISHER_B_DURATION = 0.3;					// Duration of second slow motion section during a finisher (seconds in game time).
		default SLOWDOWN_FINISHER_B_DELAY = 1.15;					// Delay after first slow motion section finishes before second slow motion section activates (seconds in game time).
	
	// dismember slowdown settings
	public const var SLOWDOWN_DISMEMBER_CHANCE, SLOWDOWN_DISMEMBER_AUTO_CHANCE, SLOWDOWN_DISMEMBER_CHANCE_LAST_ENEMY, SLOWDOWN_DISMEMBER_AUTO_CHANCE_LAST_ENEMY : float;
		default SLOWDOWN_DISMEMBER_CHANCE = 0.0;					// Chance to activate slow motion when a dismember is triggered.
		default SLOWDOWN_DISMEMBER_AUTO_CHANCE = 100.0;				// Chance to activate slow motion when an AUTOMATIC dismember is triggered.
		default SLOWDOWN_DISMEMBER_CHANCE_LAST_ENEMY = 100.0;		// Chance to activate slow motion when a dismember is triggered on the LAST enemy in combat.
		default SLOWDOWN_DISMEMBER_AUTO_CHANCE_LAST_ENEMY = 100.0;	// Chance to activate slow motion when an AUTOMATIC dismember is triggered on the LAST enemy in combat.
	public const var SLOWDOWN_DISMEMBER_DISABLE_CAMERA_SHAKE : bool;
		default SLOWDOWN_DISMEMBER_DISABLE_CAMERA_SHAKE = true;		// If TRUE -> Prevents camera shake when a slowdown is activated on a dismember.
	public const var SLOWDOWN_DISMEMBER_FACTOR, SLOWDOWN_DISMEMBER_DURATION, SLOWDOWN_DISMEMBER_DELAY : float;
		default SLOWDOWN_DISMEMBER_FACTOR = 0.3;					// Time factor for slow motion during a dismember (smaller number = more slowdown).
		default SLOWDOWN_DISMEMBER_DURATION = 0.3;					// Duration of slow motion during a dismember (seconds in game time).
		default SLOWDOWN_DISMEMBER_DELAY = 0.1;						// Delay after dismember is triggered before slow motion activates (seconds in game time).
	
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