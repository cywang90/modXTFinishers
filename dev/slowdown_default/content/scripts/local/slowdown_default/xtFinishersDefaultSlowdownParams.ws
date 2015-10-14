class XTFinishersDefaultSlowdownParams {
	//=================
	// GENERAL SETTINGS
	//=================
	public const var SLOWDOWN_DISABLE_CAMERA_SHAKE : bool;
		default SLOWDOWN_DISABLE_CAMERA_SHAKE = true;					// If TRUE -> prevents camera shake when a slowdown is activated.
	
	//==================================
	// SLOWDOWN ON CRITICAL HIT SETTINGS
	//==================================
	
	public const var SLOWDOWN_CRIT_CHANCE_NONFATAL, SLOWDOWN_CRIT_CHANCE_FATAL, SLOWDOWN_CRIT_CHANCE_FATAL_LAST_ENEMY : float;
		default SLOWDOWN_CRIT_CHANCE_NONFATAL = 0.0;					// Chance to activate slow motion when a critical hit is performed on a non-fatal attack.
		default SLOWDOWN_CRIT_CHANCE_FATAL = 0.0;						// Chance to activate slow motion when a critical hit is performed on a fatal attack.
		default SLOWDOWN_CRIT_CHANCE_FATAL_LAST_ENEMY = 0.0;			// Chance to activate slow motion when a critical hit is performed on a fatal attack on the LAST enemy in combat.
	public const var SLOWDOWN_CRIT_FACTOR, SLOWDOWN_CRIT_DURATION, SLOWDOWN_CRIT_DELAY : float;
		default SLOWDOWN_CRIT_DELAY = 0.1;								// Delay after critical hit is triggered before slow motion activates (seconds in game time).
		default SLOWDOWN_CRIT_FACTOR = 0.3;								// Time factor for slow motion during a critical hit (smaller number = more slowdown).
		default SLOWDOWN_CRIT_DURATION = 0.3;							// Duration of slow motion during a critical hit (seconds in game time).
	
	//==============================
	// SLOWDOWN ON FINISHER SETTINGS
	//==============================
	
	public const var SLOWDOWN_FINISHER_CHANCE, SLOWDOWN_FINISHER_AUTO_CHANCE, SLOWDOWN_FINISHER_INSTANTKILL_CHANCE : float;
		default SLOWDOWN_FINISHER_CHANCE = 100.0;						// Chance to activate slow motion when a REGULAR or DEBUG finisher is triggered.
		default SLOWDOWN_FINISHER_AUTO_CHANCE = 100.0;					// Chance to activate slow motion when an AUTOMATIC finisher is triggered.
		default SLOWDOWN_FINISHER_INSTANTKILL_CHANCE = 100.0;			// Chance to activate slow motion when an INSTANT-KILL finisher is triggered.
	public const var SLOWDOWN_FINISHER_CHANCE_LAST_ENEMY, SLOWDOWN_FINISHER_AUTO_CHANCE_LAST_ENEMY, SLOWDOWN_FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY : float;
		default SLOWDOWN_FINISHER_CHANCE_LAST_ENEMY = 100.0;			// Chance to activate slow motion when a REGULAR or DEBUG finisher is triggered on the LAST enemy in combat.
		default SLOWDOWN_FINISHER_AUTO_CHANCE_LAST_ENEMY = 100.0;		// Chance to activate slow motion when an AUTOMATIC finisher is triggered on the LAST enemy in combat.
		default SLOWDOWN_FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY = 100;	// Chance to activate slow motion when an INSTANT-KILL finisher is triggered on the LAST enemy in combat
	public const var SLOWDOWN_FINISHER_A_FACTOR, SLOWDOWN_FINISHER_A_DURATION, SLOWDOWN_FINISHER_A_DELAY : float;
		default SLOWDOWN_FINISHER_A_DELAY = 0.0;						// Delay after finisher is triggered before first slow motion section activates (seconds in game time).
		default SLOWDOWN_FINISHER_A_FACTOR = 0.3;						// Time factor for first slow motion section during a finisher (smaller number = more slowdown).
		default SLOWDOWN_FINISHER_A_DURATION = 0.3;						// Duration of first slow motion section during a finisher (seconds in game time).
	public const var SLOWDOWN_FINISHER_B_FACTOR, SLOWDOWN_FINISHER_B_DURATION, SLOWDOWN_FINISHER_B_DELAY : float;
		default SLOWDOWN_FINISHER_B_DELAY = 1.15;						// Delay after first slow motion section finishes before second slow motion section activates (seconds in game time).
		default SLOWDOWN_FINISHER_B_FACTOR = 0.3;						// Time factor for second slow motion section during a finisher (smaller number = more slowdown).
		default SLOWDOWN_FINISHER_B_DURATION = 0.3;						// Duration of second slow motion section during a finisher (seconds in game time).
	
	public const var SLOWDOWN_FINISHER_KNOCKDOWN_CHANCE, SLOWDOWN_FINISHER_KNOCKDOWN_CHANCE_LAST_ENEMY : float;
		default SLOWDOWN_FINISHER_KNOCKDOWN_CHANCE = 0.0;				// Chance to activate slow motion when a KNOCKDOWN finisher is triggered.
		default SLOWDOWN_FINISHER_KNOCKDOWN_CHANCE_LAST_ENEMY = 0.0;	// Chance to activate slow motion when a KNOCKDOWN finisher is triggered on the LAST enemy in combat.
	public const var SLOWDOWN_FINISHER_KNOCKDOWN_FACTOR, SLOWDOWN_FINISHER_KNOCKDOWN_DURATION, SLOWDOWN_FINISHER_KNOCKDOWN_DELAY : float;
		default SLOWDOWN_FINISHER_KNOCKDOWN_DELAY = 1.3;				// Delay after KNOCKDOWN finisher is triggered before slow motion activates (seconds in game time).
		default SLOWDOWN_FINISHER_KNOCKDOWN_FACTOR = 0.3;				// Time factor for slow motion during a KNOCKDOWN finisher (smaller number = more slowdown).
		default SLOWDOWN_FINISHER_KNOCKDOWN_DURATION = 0.3;				// Duration of slow motion during a KNOCKDOWN finisher (seconds in game time).
	
	//===============================
	// SLOWDOWN ON DISMEMBER SETTINGS
	//===============================
	
	public const var SLOWDOWN_DISMEMBER_CHANCE, SLOWDOWN_DISMEMBER_FROZEN_CHANCE, SLOWDOWN_DISMEMBER_BOMB_CHANCE, SLOWDOWN_DISMEMBER_BOLT_CHANCE, SLOWDOWN_DISMEMBER_YRDEN_CHANCE, SLOWDOWN_DISMEMBER_TOXICCLOUD_CHANCE, SLOWDOWN_DISMEMBER_AUTO_CHANCE,
			SLOWDOWN_DISMEMBER_CHANCE_LAST_ENEMY, SLOWDOWN_DISMEMBER_FROZEN_CHANCE_LAST_ENEMY, SLOWDOWN_DISMEMBER_BOMB_CHANCE_LAST_ENEMY, SLOWDOWN_DISMEMBER_BOLT_CHANCE_LAST_ENEMY, SLOWDOWN_DISMEMBER_YRDEN_CHANCE_LAST_ENEMY, SLOWDOWN_DISMEMBER_TOXICCLOUD_CHANCE_LAST_ENEMY, SLOWDOWN_DISMEMBER_AUTO_CHANCE_LAST_ENEMY : float;
		default SLOWDOWN_DISMEMBER_CHANCE = 0.0;							// Chance to activate slow motion when a REGULAR or DEBUG dismember is triggered.
		default SLOWDOWN_DISMEMBER_FROZEN_CHANCE = 100.0;					// Chance to activate slow motion when a FROZEN dismember is triggered.
		default SLOWDOWN_DISMEMBER_BOMB_CHANCE = 0.0;						// Chance to activate slow motion when a BOLT dismember is triggered.
		default SLOWDOWN_DISMEMBER_BOLT_CHANCE = 0.0;						// Chance to activate slow motion when a BOMB dismember is triggered.
		default SLOWDOWN_DISMEMBER_YRDEN_CHANCE = 0.0;						// Chance to activate slow motion when a YRDEN dismember is triggered.
		default SLOWDOWN_DISMEMBER_TOXICCLOUD_CHANCE = 0.0;					// Chance to activate slow motion when a TOXIC CLOUD dismember is triggered.
		default SLOWDOWN_DISMEMBER_AUTO_CHANCE = 100.0;						// Chance to activate slow motion when an AUTOMATIC dismember is triggered.
		default SLOWDOWN_DISMEMBER_CHANCE_LAST_ENEMY = 100.0;				// Chance to activate slow motion when a REGULAR or DEBUG dismember is triggered on the LAST enemy in combat.
		default SLOWDOWN_DISMEMBER_FROZEN_CHANCE_LAST_ENEMY = 100.0;		// Chance to activate slow motion when a FROZEN dismember is triggered on the LAST enemy in combat.
		default SLOWDOWN_DISMEMBER_BOMB_CHANCE_LAST_ENEMY = 100.0;			// Chance to activate slow motion when a BOLT dismember is triggered on the LAST enemy in combat.
		default SLOWDOWN_DISMEMBER_BOLT_CHANCE_LAST_ENEMY = 100.0;			// Chance to activate slow motion when a BOMB dismember is triggered on the LAST enemy in combat.
		default SLOWDOWN_DISMEMBER_YRDEN_CHANCE_LAST_ENEMY = 100.0;			// Chance to activate slow motion when a YRDEN dismember is triggered on the LAST enemy in combat.
		default SLOWDOWN_DISMEMBER_TOXICCLOUD_CHANCE_LAST_ENEMY = 100.0;	// Chance to activate slow motion when a TOXIC CLOUD dismember is triggered on the LAST enemy in combat.
		default SLOWDOWN_DISMEMBER_AUTO_CHANCE_LAST_ENEMY = 100.0;			// Chance to activate slow motion when an AUTOMATIC dismember is triggered on the LAST enemy in combat.
	public const var SLOWDOWN_DISMEMBER_FACTOR, SLOWDOWN_DISMEMBER_DURATION, SLOWDOWN_DISMEMBER_DELAY : float;
		default SLOWDOWN_DISMEMBER_DELAY = 0.1;								// Delay after dismember is triggered before slow motion activates (seconds in game time).
		default SLOWDOWN_DISMEMBER_FACTOR = 0.3;							// Time factor for slow motion during a dismember (smaller number = more slowdown).
		default SLOWDOWN_DISMEMBER_DURATION = 0.3;							// Duration of slow motion during a dismember (seconds in game time).
		
}