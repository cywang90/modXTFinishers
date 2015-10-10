/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2013 CD Projekt RED
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTTaskSetBehVarOnAnimEvent extends IBehTreeTask
{
	var eventName 		: name;
	var behVarName 		: name;
	var behVarValue		: float;
	var eventReceived 	: bool;
	
	latent function Main()
	{
		var npc : CNewNPC = GetNPC();
		
		while ( true )
		{
			if ( eventReceived && IsNameValid(eventName) && eventName != 'AllowBlend' )
			{
				npc.SetBehaviorVariable( behVarName, behVarValue );
				eventReceived = false;
			}
		}
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
	//	AllowBlend handled on OnDeactivate because AtomicPlayAnimationEvent
	//	should always be used with PlayAnimationEventDecorator which Completes task on AllowBlend
		if ( eventReceived && IsNameValid(eventName) && eventName == 'AllowBlend' )
		{
			npc.SetBehaviorVariable( behVarName, behVarValue );
			eventReceived = false;
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == eventName )
		{
			eventReceived = true;
			return true;
		}
		
		return false;
	}
};

class CBTTaskSetBehVarOnAnimEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetBehVarOnAnimEvent';

	editable var eventName 		: name;
	editable var behVarName 	: name;
	editable var behVarValue	: float;
	
	default eventName = 'AllowBlend';
};
