/*
Copyright © CD Projekt RED 2015
*/











class BTTaskSetEntityAsActionTarget extends IBehTreeTask
{
	
	
	
	var targetTag			: name;
	var multipleTargetsTags : array<name>;
	
	
	function OnActivate() : EBTNodeStatus
	{	
		var l_target		: CNode;
		var l_selectedTag	: name;
		var l_size			: int;
		
		l_size = multipleTargetsTags.Size();
		
		if ( l_size > 0 )
			l_selectedTag = multipleTargetsTags[RandRange(l_size)];
		else
			l_selectedTag = targetTag;
		
		l_target = theGame.GetNodeByTag( l_selectedTag );		
		SetActionTarget( l_target );	
		return BTNS_Completed;
	}

}


class BTTaskSetEntityAsActionTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetEntityAsActionTarget';
	
	
	editable var targetTag	: CBehTreeValCName;
	editable var multipleTargetsObjectName : name;
	
	default multipleTargetsObjectName = 'multipleTargetsTags';
	
	hint multipleTargetsObjectName = "only works for parametrization.";
	
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var task : BTTaskSetEntityAsActionTarget;
		task = (BTTaskSetEntityAsActionTarget) taskGen;
		task.multipleTargetsTags =((W3BehTreeValNameArray)GetObjectByVar(multipleTargetsObjectName)).GetArray();
	}
}
