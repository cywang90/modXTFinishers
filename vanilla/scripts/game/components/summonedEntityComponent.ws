﻿//----------------------------------------------------------------------
// Witcher Script file
//----------------------------------------------------------------------
//>---------------------------------------------------------------
// Contains info about the summoner
//----------------------------------------------------------------
// Copyright © 2014 CDProjektRed
// Author : R.Pergent - 02-April-2014
//----------------------------------------------------------------------
class W3SummonedEntityComponent extends CScriptedComponent
{
	//>---------------------------------------------------------------
	// Variable
	//----------------------------------------------------------------
	protected var 		m_Summoner 					: CActor;
	protected var 		m_SummonedTime 				: float;
	editable var		shouldUseSummonerGuardArea	: bool;
	editable var 		killOnSummonersDeath		: bool;
	
	default shouldUseSummonerGuardArea = true;
	//>---------------------------------------------------------------
	//----------------------------------------------------------------
	public function 	GetSummoner() 		: CActor 		{ 		return m_Summoner; 			}
	public function 	GetSummonedTime() 	: float 		{ 		return m_SummonedTime; 		}
	//>---------------------------------------------------------------
	//----------------------------------------------------------------
	public function Init ( _Summoner : CActor )
	{
		var l_npc 	: CNewNPC;
		
		m_Summoner 		= _Summoner;
		m_SummonedTime 	= theGame.GetEngineTimeAsSeconds();
		
		l_npc = (CNewNPC) GetEntity();
		if( l_npc && shouldUseSummonerGuardArea )
		{
			l_npc.DeriveGuardArea( (CNewNPC) _Summoner );
		}
	}
	//>---------------------------------------------------------------
	//----------------------------------------------------------------
	public function OnSummonerDeath()
	{
		var durationObstacle	: W3DurationObstacle;
		var flies				: W3SummonedFlies;
		var npc					: CNewNPC;
		
		durationObstacle = (W3DurationObstacle) GetEntity();		
		if( durationObstacle )
		{
			durationObstacle.Disappear();
		}
		if( killOnSummonersDeath )
		{
			npc = (CNewNPC)GetEntity();
			npc.AddTag( 'AchievementKillDontCount' );
			npc.Kill( 'Summoner Death' );
		}
		flies = (W3SummonedFlies) GetEntity();		
		if( flies )
		{
			flies.Die();
		}
	}
	//>---------------------------------------------------------------
	//----------------------------------------------------------------
	public function OnDeath()
	{
		m_Summoner.SignalGameplayEventParamObject( 'SummonedEntityDeath', GetEntity() );
	}
	
}