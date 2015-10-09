﻿/*
Copyright © CD Projekt RED 2015
*/










import class IScriptable extends ISerializable
{
	
	

	
	import function PushState( stateName : name );

	
	import function PopState( optional popAll : bool );

	
	import function GotoState( optional newState : name, optional keepStack : bool, optional forceEvents : bool );

	
	import final function GotoStateAuto();
	
	
	import final function GetState( stateName : name ) : CScriptableState;

	
	import final function GetCurrentState() : CScriptableState;

	
	import final function GetCurrentStateName() : name;

	
	import final function IsInState( stateName : name ) : bool;

	
	import final function LockEntryFunction( lock : bool );
	
	
	import final function SetCleanupFunction( functionName : name );

	
	import final function ClearCleanupFunction();
	
	
	import final function DebugDumpEntryFunctionCalls( enabled : bool );
	
	
	import final function LogStates();

	
	import function ToString() : string;
}




import class CObject extends IScriptable 
{	
	
	import function Clone( newParent : CObject ) : CObject;
	
	
	import function GetParent() : CObject;
}