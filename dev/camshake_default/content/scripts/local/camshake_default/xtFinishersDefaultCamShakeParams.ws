class XTFinishersDefaultCamShakeParams {
	//==============================
	// CAMERA SHAKE ON REND SETTINGS
	//==============================
	
	public const var CAMERA_SHAKE_ON_REND : bool;
		default CAMERA_SHAKE_ON_REND = true;						// If TRUE -> triggers camera shake on Rend attacks.
		
	//======================================
	// CAMERA SHAKE ON CRITICAL HIT SETTINGS
	//======================================
	
	public const var CAMERA_SHAKE_ON_CRIT_NONFATAL, CAMERA_SHAKE_ON_CRIT_FATAL : bool;
		default CAMERA_SHAKE_ON_CRIT_NONFATAL = false;				// If TRUE -> triggers camera shake on non-fatal critical hits.
		default CAMERA_SHAKE_ON_CRIT_FATAL = true;					// If TRUE -> triggers camera shake on fatal critical hits.
	public const var CAMERA_SHAKE_CRIT_NONFATAL_STRENGTH, CAMERA_SHAKE_CRIT_FATAL_STRENGTH : float;
		default CAMERA_SHAKE_CRIT_NONFATAL_STRENGTH = 0.5;			// Strength of camera shake on non-fatal critical hits.
		default CAMERA_SHAKE_CRIT_FATAL_STRENGTH = 0.5;				// Strength of camera shake on fatal critical hits.
	
	//===================================
	// CAMERA SHAKE ON DISMEMBER SETTINGS
	//===================================
	
	public const var CAMERA_SHAKE_ON_DISMEMBER : bool;
		default CAMERA_SHAKE_ON_DISMEMBER = true;					// If TRUE -> Triggers camera shake when a dismemberment is triggered.
	public const var CAMERA_SHAKE_DISMEMBER_STRENGTH : float;
		default CAMERA_SHAKE_DISMEMBER_STRENGTH = 0.5;				// Strength of camera shake when a dismemberment is triggered.
}