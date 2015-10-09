/*
Copyright © CD Projekt RED 2015
*/

class CBehTreeHLTaskWander extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{
		GetActor().ActivateAndSyncBehavior('Exploration');
		
		return BTNS_Active;
	}
};


class CBehTreeHLTaskWanderDef extends IBehTreeHLTaskDefinition
{
	default instanceClass = 'CBehTreeHLTaskWander';
}
