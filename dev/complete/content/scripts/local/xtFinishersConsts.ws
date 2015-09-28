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
		
	// Listener priorities
	
	// Vanilla module
	
	public const var VANILLA_FINISHER_QUERY_DISPATCHER_PRIORITY, VANILLA_DISMEMBER_QUERY_DISPATCHER_PRIORITY : int;
		default VANILLA_FINISHER_QUERY_DISPATCHER_PRIORITY = 0;
		default VANILLA_DISMEMBER_QUERY_DISPATCHER_PRIORITY = 10;
		
	public const var VANILLA_CAMSHAKE_HANDLER_PRIORITY : int;
		default VANILLA_CAMSHAKE_HANDLER_PRIORITY = 0;
	
	public const var VANILLA_FINISHER_CAM_QUERY_DISPATCHER_PRIORITY : int;
		default VANILLA_FINISHER_CAM_QUERY_DISPATCHER_PRIORITY = 0;
		
	// Default modules
	
	// reaction start
	public const var DEFAULT_FINISHER_QUERY_DISPATCHER_PRIORITY, DEFAULT_DISMEMBER_QUERY_DISPATCHER_PRIORITY : int;
		default DEFAULT_FINISHER_QUERY_DISPATCHER_PRIORITY = 0;
		default DEFAULT_DISMEMBER_QUERY_DISPATCHER_PRIORITY = 10;
	
	// dismember
	public const var DEFAULT_SLOWDOWN_DISMEMBER_QUERY_DISPATCHER_PRIORITY : int;
		default DEFAULT_SLOWDOWN_DISMEMBER_QUERY_DISPATCHER_PRIORITY = 0;
		
	// action end
	public const var DEFAULT_SLOWDOWN_CRIT_QUERY_DISPATCHER_PRIORITY, DEFAULT_CAMSHAKE_HANDLER_PRIORITY : int;
		default DEFAULT_SLOWDOWN_CRIT_QUERY_DISPATCHER_PRIORITY = 0;
		default DEFAULT_CAMSHAKE_HANDLER_PRIORITY = 10;
	
	// finisher
	public const var DEFAULT_FINISHER_CAM_QUERY_DISPATCHER_PRIORITY, DEFAULT_SLOWDOWN_FINISHER_QUERY_DISPATCHER_PRIORITY : int;
		default DEFAULT_FINISHER_CAM_QUERY_DISPATCHER_PRIORITY = 0;
		default DEFAULT_SLOWDOWN_FINISHER_QUERY_DISPATCHER_PRIORITY = 10;
	
	// Slowdown types
	
	public const var SLOWDOWN_TYPE_FINISHER, SLOWDOWN_TYPE_DISMEMBER, SLOWDOWN_TYPE_CRIT : int;
		default SLOWDOWN_TYPE_FINISHER = 1;
		default SLOWDOWN_TYPE_DISMEMBER = 2;
		default SLOWDOWN_TYPE_CRIT = 3;
}