class XTFinishersDefaultCamShakeParams {
	//=====================================
	// CAMERA SHAKE ON FAST ATTACK SETTINGS
	//=====================================
	
	public const var CAMERA_SHAKE_FAST_CHANCE, CAMERA_SHAKE_FAST_PARRIED_CHANCE : float;
		default CAMERA_SHAKE_FAST_CHANCE = 100.0;					// Chance to trigger camera shake on fast attacks.
		default CAMERA_SHAKE_FAST_PARRIED_CHANCE = 100.0;			// Chance to trigger camera shake on fast attacks that were parried by the enemy.
	public const var CAMERA_SHAKE_FAST_STRENGTH, CAMERA_SHAKE_FAST_PARRIED_STRENGTH : float;
		default CAMERA_SHAKE_FAST_STRENGTH = 0.1;					// Strength of camera shake on fast attacks.
		default CAMERA_SHAKE_FAST_PARRIED_STRENGTH = 0.1;			// Strength of camera shake on fast attacks that were parried by the enemy.
	
	//=======================================
	// CAMERA SHAKE ON STRONG ATTACK SETTINGS
	//=======================================
	
	public const var CAMERA_SHAKE_STRONG_CHANCE, CAMERA_SHAKE_STRONG_PARRIED_CHANCE : float;
		default CAMERA_SHAKE_STRONG_CHANCE = 100.0;					// Chance to trigger camera shake on strong attacks.
		default CAMERA_SHAKE_STRONG_PARRIED_CHANCE = 100.0;			// Chance to trigger camera shake on strong attacks that were parried by the enemy.
	public const var CAMERA_SHAKE_STRONG_STRENGTH, CAMERA_SHAKE_STRONG_PARRIED_STRENGTH : float;
		default CAMERA_SHAKE_STRONG_STRENGTH = 0.1;					// Strength of camera shake on strong attacks.
		default CAMERA_SHAKE_STRONG_PARRIED_STRENGTH = 0.2;			// Strength of camera shake on strong attacks that were parried by the enemy.
	
	//===================================
	// CAMERA SHAKE ON FATAL HIT SETTINGS
	//===================================
	public const var CAMERA_SHAKE_FATAL_CHANCE : float;
		default CAMERA_SHAKE_FATAL_CHANCE = 0.0;					// Chance to trigger camera shake on fatal hits.
	public const var CAMERA_SHAKE_FATAL_STRENGTH : float;
		default CAMERA_SHAKE_FATAL_STRENGTH = 0.2;					// Strength of camera shake on fatal hits.
		
	//======================================
	// CAMERA SHAKE ON CRITICAL HIT SETTINGS
	//======================================
	
	public const var CAMERA_SHAKE_CRIT_NONFATAL_CHANCE, CAMERA_SHAKE_CRIT_FATAL_CHANCE, CAMERA_SHAKE_CRIT_FATAL_CHANCE_LAST_ENEMY : float;
		default CAMERA_SHAKE_CRIT_NONFATAL_CHANCE = 0.0;			// Chance to trigger camera shake on non-fatal critical hits.
		default CAMERA_SHAKE_CRIT_FATAL_CHANCE = 100.0;				// Chance to trigger camera shake on fatal critical hits.
		default CAMERA_SHAKE_CRIT_FATAL_CHANCE_LAST_ENEMY = 100.0;	// Chance to trigger camera shake on fatal critical hits on the LAST enemy in combat.
	public const var CAMERA_SHAKE_CRIT_NONFATAL_STRENGTH, CAMERA_SHAKE_CRIT_FATAL_STRENGTH, CAMERA_SHAKE_CRIT_FATAL_STRENGTH_LAST_ENEMY : float;
		default CAMERA_SHAKE_CRIT_NONFATAL_STRENGTH = 0.5;			// Strength of camera shake on non-fatal critical hits.
		default CAMERA_SHAKE_CRIT_FATAL_STRENGTH = 0.5;				// Strength of camera shake on fatal critical hits.
		default CAMERA_SHAKE_CRIT_FATAL_STRENGTH_LAST_ENEMY = 0.5;	// Strength of camera shake on fatal critical hits on the LAST enemy in combat.
		
	//==============================
	// CAMERA SHAKE ON REND SETTINGS
	//==============================
	
	public const var CAMERA_SHAKE_REND_CHANCE : int;
		default CAMERA_SHAKE_REND_CHANCE = 100.0;					// Chance to trigger camera shake on Rend attacks.
	
	//===================================
	// CAMERA SHAKE ON DISMEMBER SETTINGS
	//===================================
	
	public const var CAMERA_SHAKE_DISMEMBER_CHANCE, CAMERA_SHAKE_DISMEMBER_CHANCE_LAST_ENEMY : float;
		default CAMERA_SHAKE_DISMEMBER_CHANCE = 100.0;				// Chance to trigger camera shake on a dismemberment.
		default CAMERA_SHAKE_DISMEMBER_CHANCE_LAST_ENEMY = 100.0;	// Chance to trigger camera shake on a dismemberment on the LAST enemy in combat.
	public const var CAMERA_SHAKE_DISMEMBER_STRENGTH, CAMERA_SHAKE_DISMEMBER_STRENGTH_LAST_ENEMY : float;
		default CAMERA_SHAKE_DISMEMBER_STRENGTH = 0.5;				// Strength of camera shake on a dismemberment.
		default CAMERA_SHAKE_DISMEMBER_STRENGTH_LAST_ENEMY = 0.5;	// Strength of camera shake on a dismemberment on the LAST enemy in combat.
}