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
		
	// finisher animation names	
	
	public const var FINISHER_STANCE_LEFT_HEAD_ONE, FINISHER_STANCE_LEFT_HEAD_TWO, FINISHER_STANCE_LEFT_NECK, FINISHER_STANCE_LEFT_THRUST_ONE, FINISHER_STANCE_LEFT_THRUST_TWO : name;
		default FINISHER_STANCE_LEFT_HEAD_ONE = 'man_finisher_02_lp';
		default FINISHER_STANCE_LEFT_HEAD_TWO = 'man_finisher_07_lp';
		default FINISHER_STANCE_LEFT_NECK = 'man_finisher_08_lp';
		default FINISHER_STANCE_LEFT_THRUST_ONE = 'man_finisher_04_lp';
		default FINISHER_STANCE_LEFT_THRUST_TWO = 'man_finisher_06_lp';
		
	public const var FINISHER_STANCE_RIGHT_HEAD, FINISHER_STANCE_RIGHT_THRUST_ONE, FINISHER_STANCE_RIGHT_THRUST_TWO : name;
		default FINISHER_STANCE_RIGHT_HEAD = 'man_finisher_01_rp';
		default FINISHER_STANCE_RIGHT_THRUST_ONE = 'man_finisher_03_rp';
		default FINISHER_STANCE_RIGHT_THRUST_TWO = 'man_finisher_05_rp';
	
	public const var FINISHER_DLC_STANCE_LEFT_ARM, FINISHER_DLC_STANCE_LEFT_LEGS, FINISHER_DLC_STANCE_LEFT_TORSO : name;
		default FINISHER_DLC_STANCE_LEFT_ARM = 'man_finisher_dlc_arm_lp';
		default FINISHER_DLC_STANCE_LEFT_LEGS = 'man_finisher_dlc_legs_lp';
		default FINISHER_DLC_STANCE_LEFT_TORSO = 'man_finisher_dlc_torso_lp';
		
	public const var FINISHER_DLC_STANCE_RIGHT_ARM, FINISHER_DLC_STANCE_RIGHT_LEGS, FINISHER_DLC_STANCE_RIGHT_TORSO, FINISHER_DLC_STANCE_RIGHT_HEAD, FINISHER_DLC_STANCE_RIGHT_NECK : name;
		default FINISHER_DLC_STANCE_RIGHT_ARM = 'man_finisher_dlc_arm_rp';
		default FINISHER_DLC_STANCE_RIGHT_LEGS = 'man_finisher_dlc_legs_rp';
		default FINISHER_DLC_STANCE_RIGHT_TORSO = 'man_finisher_dlc_torso_rp';
		default FINISHER_DLC_STANCE_RIGHT_HEAD = 'man_finisher_dlc_head_rp';
		default FINISHER_DLC_STANCE_RIGHT_NECK = 'man_finisher_dlc_neck_rp';
		
	// Listener priorities
	
	// Vanilla module
	
	public const var VANILLA_FINISHER_QUERY_DISPATCHER_PRIORITY, VANILLA_DISMEMBER_QUERY_DISPATCHER_PRIORITY : int;
		default VANILLA_FINISHER_QUERY_DISPATCHER_PRIORITY = 0;
		default VANILLA_DISMEMBER_QUERY_DISPATCHER_PRIORITY = 10;
		
	public const var VANILLA_CAMSHAKE_HANDLER_PRIORITY : int;
		default VANILLA_CAMSHAKE_HANDLER_PRIORITY = 0;
	
	public const var VANILLA_FINISHER_CAM_QUERY_DISPATCHER_PRIORITY : int;
		default VANILLA_FINISHER_CAM_QUERY_DISPATCHER_PRIORITY = 0;
	
	// Slowdown types
	
	public const var SLOWDOWN_TYPE_FINISHER, SLOWDOWN_TYPE_DISMEMBER, SLOWDOWN_TYPE_CRIT : int;
		default SLOWDOWN_TYPE_FINISHER = 1;
		default SLOWDOWN_TYPE_DISMEMBER = 2;
		default SLOWDOWN_TYPE_CRIT = 3;
}