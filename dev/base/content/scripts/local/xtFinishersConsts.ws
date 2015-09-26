/*
	Constants used by the mod and its modules. Don't mess with them unless you know what you are doing.
*/
class XTFinishersConsts {
	// Event ids
	
	public const var ACTION_START_EVENT_ID, ACTION_END_EVENT_ID, REACTION_START_EVENT_ID, REACTION_END_EVENT_ID, FINISHER_EVENT_ID, DISMEMBER_EVENT_ID, FINISHER_CAM_EVENT_ID : string;
		default ACTION_START_EVENT_ID = "actionstart";
		default ACTION_END_EVENT_ID = "actionend";
		default REACTION_START_EVENT_ID = "reactionstart";
		default REACTION_END_EVENT_ID = "reactionend";
		default FINISHER_EVENT_ID = "finisher";
		default DISMEMBER_EVENT_ID = "dismember";
		default FINISHER_CAM_EVENT_ID = "finishercam";
	
	public const var SLOWDOWN_SEQUENCE_START_EVENT_ID, SLOWDOWN_SEQUENCE_END_EVENT_ID, SLOWDOWN_SEGMENT_START_EVENT_ID, SLOWDOWN_SEGMENT_END_EVENT_ID : string;
		default SLOWDOWN_SEQUENCE_START_EVENT_ID = "slowdownseqstart";
		default SLOWDOWN_SEQUENCE_END_EVENT_ID = "slowdownseqend";
		default SLOWDOWN_SEGMENT_START_EVENT_ID = "slowdownsegstart";
		default SLOWDOWN_SEGMENT_END_EVENT_ID = "slowdownsegend";
	
	// Slowdown types
	
	public const var SLOWDOWN_TYPE_FINISHER, SLOWDOWN_TYPE_DISMEMBER, SLOWDOWN_TYPE_CRIT : int;
		default SLOWDOWN_TYPE_FINISHER = 1;
		default SLOWDOWN_TYPE_DISMEMBER = 2;
		default SLOWDOWN_TYPE_CRIT = 3;
		
	// =====================
	// MODULE CONSTS GO HERE
	// =====================
	
}