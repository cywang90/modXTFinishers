﻿/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Patryk Fiutowski
/***********************************************************************/

class CBTTaskSearchForThrowable extends IBehTreeTask
{
	var range : float;
	var tag : name;
	
	var selectedObject : CNode;
	
	var physicalComponent : CComponent;
	
	var activate : bool;
	var findTime : float;
	
	var throwData : CAIStorageHandler;
	
	function IsAvailable() : bool
	{
		return activate;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( this.GetActionTarget() != selectedObject)
			this.SetActionTarget(selectedObject);
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		findTime = 0.f;
		activate = false;
		physicalComponent = NULL;
		//??
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC = GetNPC();
		var component : CComponent;
		
		if ( eventName == 'CollisionWithStatic' && !activate )
		{
			component = (CComponent)GetEventParamObject();
			if ( component.HasDynamicPhysic() )
			{
				activate = true;
				findTime = GetLocalTime();
				physicalComponent = component;
				selectedObject = component.GetEntity();
				GetNPC().SignalGameplayEventParamObject('Throwable',component);
			}
			return true;
		}
		
		return false;
	}
}

class CBTTaskSearchForThrowableDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSearchForThrowable';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CollisionWithStatic' );
	}
}
