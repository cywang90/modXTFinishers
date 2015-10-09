﻿/*
Copyright © CD Projekt RED 2015
*/





class CBTTaskSlideToTarget extends IBehTreeTask
{
	var minDistance			: float;
	var maxDistance			: float;
	var maxSpeed			: float; 
	var onAnimEvent			: name;
	var adjustVertically 	: bool;
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc 				: CNewNPC = GetNPC();
		var target 				: CActor = npc.GetTarget();
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		
		if ( animEventName == onAnimEvent && ( animEventType == AET_DurationStart || animEventType == AET_DurationStartInTheMiddle ) )
		{
			movementAdjustor = npc.GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'SlideToTarget' );
			ticket = movementAdjustor.CreateNewRequest( 'SlideToTarget' );
			movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
			movementAdjustor.MaxLocationAdjustmentSpeed( ticket, maxSpeed );
			if ( adjustVertically )
			{
				movementAdjustor.AdjustLocationVertically( ticket, true );
			}
			movementAdjustor.SlideTowards( ticket, target, minDistance, maxDistance );
			return true;
		}
		
		return false;
	}
};

class CBTTaskSlideToTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSlideToTarget';

	editable var minDistance		: float;
	editable var maxDistance		: float;
	editable var maxSpeed			: float;
	editable var onAnimEvent		: name;
	editable var adjustVertically	: bool;
	
	default minDistance = 1.5;
	default maxDistance = 2;
	default maxSpeed = 5;
	default onAnimEvent = 'SlideToTarget';
	default adjustVertically = false;
	
	hint onAnimEvent = "Must be specified. Won't work without an event.";
};
