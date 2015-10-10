﻿/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2012
/***********************************************************************/

enum ECustomCameraType
{
	CCT_None,
	CCT_CustomController,
	CCT_RotatedToTarget_OverShoulder,
	CCT_RotatedToTarget_Medium,
}

enum ECustomCameraController
{
	CCC_NoTarget,
	CCC_Target_Interior,
	CCC_Target,
}

struct SCustomCameraParams
{
	var source	 			: CActor;
	var useCustomCamera		: bool;
	var cameraParams		: SMultiValue;
}

struct SCustomOrientationParams
{
	var source	 				: CActor;
	var customOrientationTarget	: EOrientationTarget;
}

state Combat in CR4Player extends ExtendedMovable // ABSTRACT
{
	protected var comboDefinition	: CComboDefinition;
	public var comboPlayer			: CComboPlayer;
	
	protected var updatePosition 	: bool;
	
	private var bIsSwitchingDirection	: bool;
	protected var currentWeapon			: EPlayerWeapon;
	
	private var comboAttackA_Id 	: int;
	private var comboAttackA_Target : CGameplayEntity;
	private var comboAttackA_Sliding : bool;
	
	private var comboAttackB_Id 	: int;
	private var comboAttackB_Target : CGameplayEntity;
	private var comboAttackB_Sliding : bool;
	
	private var comboAspectName	: name;
	
	private	var enemiesInRange 			: array<CActor>;
	private	var positionWeightsDest		: array<float>;
	private	var positionWeights			: array<float>;
	private var positionVelocity		: array<float>;
	private var positionWeightDamper	: SpringDamper;
	
	private	var dodgeDirection 				: EPlayerEvadeDirection;
	
	default comboAttackA_Id = -1;
	default comboAttackB_Id = -1;
	
	private var zoomOutForApproachingAttacker : bool;
	
	private var slideDistanceOffset : float;
	
	default slideDistanceOffset = 0.1f;
	
	protected var startupAction 	: EInitialAction;
	protected var startupBuff 	: CBaseGameplayEffect;
	protected var isInCriticalState	: bool;
	
	// combat stats
	private var realCombat : bool;
	private var lastVitality : float;
	
	private var	timeToCheckCombatEndCur	: float;
	private	var	timeToCheckCombatEndMax	: float;		default	timeToCheckCombatEndMax	= 0.5f;
	
	// Sprinting
	private var	timeToExitCombatFromSprinting	: float;	default	timeToExitCombatFromSprinting	= 2.0f;
	
	public function SetupState( initialAction : EInitialAction, optional initialBuff : CBaseGameplayEffect )
	{
		startupAction = initialAction;
		startupBuff	= initialBuff;
	}	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Enter/Leave events	
	/**
	
	*/
	event OnEnterState( prevStateName : name )
	{
		var i : int;
		
		parent.AddAnimEventCallback('AllowInput',		'OnAnimEvent_AllowInput');
		parent.AddAnimEventCallback('AllowRoll',		'OnAnimEvent_AllowRoll');
		parent.AddAnimEventCallback('ForceAttack',		'OnAnimEvent_ForceAttack');
		parent.AddAnimEventCallback('PunchHand_Left',	'OnAnimEvent_PunchHand');
		parent.AddAnimEventCallback('PunchHand_Right',	'OnAnimEvent_PunchHand');
		
		super.OnEnterState(prevStateName);
			
		//LogChannel( 'States', "Changed state to: " + this + " from " + prevStateName);
		
		parent.AddTimer( 'CombatComboUpdate', 0, true, false,  TICK_PrePhysics );
		parent.AddTimer( 'CombatEndCheck', 0.1f, true );
		
		//if ( prevStateName == 'CombatFocusMode_SelectSpot' && comboPlayer && comboPlayer.IsSliderPaused() )
		//{
		//	comboPlayer.UnpauseSlider();
		//}		
		
		parent.SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)PGMM_Combat );
		
		CombatInit();
		
		theTelemetry.Log(TE_STATE_COMBAT);
		
		StatsInit();
	}
	
	function StatsInit()
	{
		realCombat = thePlayer.IsInCombat();
		lastVitality = thePlayer.GetStat(BCS_Vitality);
	}
	/**
	
	*/
	event OnLeaveState( nextStateName : name )
	{ 
		var skillAbilityName : name;
	
		// Pass to base class
		super.OnLeaveState(nextStateName);
		
		parent.RemoveTimer( 'CombatComboUpdate' );
		parent.RemoveTimer( 'CombatEndCheck' );
		//parent.ProcessNavmeshSnap();
		
		//if ( !( nextStateName == 'CombatFists' || nextStateName == 'CombatSteel' || nextStateName == 'CombatSilver' ) )
		//	parent.SetMoveTarget( NULL );
		//parent.RemoveTimer( 'FindMoveTargetTimer' );
		
		if ( nextStateName != 'AimThrow' )
			OnCombatActionEndComplete();
		
//		((W3PlayerWitcher)parent).CastSignAbort();
		
		if ( nextStateName != 'CombatFocusMode_SelectSpot' )
		{
			if ( comboPlayer )
			{
				comboPlayer.Deinit();
			}
		}
		//else if ( comboPlayer )
		//{
		//	comboPlayer.PauseSlider();
		//}
		
		parent.SetInteractionPriority( IP_Prio_0 );
		
		CleanUpComboStuff();
		
		//skill cleanup
		skillAbilityName = SkillEnumToName(S_Alchemy_s17);
		while(thePlayer.HasAbility(skillAbilityName))
			thePlayer.RemoveAbility(skillAbilityName);
	}
	
	event OnStateCanGoToCombat()
	{
		return true;
	}
	
	/**
	
	*/
	entry function CombatInit()
	{
		var camera : CCustomCamera = theGame.GetGameCamera();
		
		camera.ChangePivotPositionController( 'Default' );
		
		//theSound.SoundState( "game_state", "combat" );
		
		parent.AddTimer( 'CombatLoop', 0, true );
		//parent.AddTimer( 'FindMoveTargetTimer', 0.2, true );		
	}
		
	timer function CombatLoop( timeDelta : float , id : int)
	{
		ProcessPlayerOrientation();
		ProcessPlayerCombatStance();
		//parent.ProcessNavmeshSnap();
		parent.GetVisualDebug().AddArrow( 'heading3', parent.GetWorldPosition(), parent.GetWorldPosition() + VecFromHeading( parent.cachedRawPlayerHeading ), 1.f, 0.2f, 0.2f, true, Color(255,0,255), true );
		
		// In air update
		UpdateIsInAir();
		
		StatsUpdate();
		// End combat from sprinting special check
		//if( parent.GetSprintingTime() > timeToExitCombatFromSprinting )
		//{
		//	if( !parent.GoToCombatIfNeeded() )
		//	{
		//		parent.GoToExplorationIfNeeded(); 
		//	}
		//}
	}
	
	private function UpdateIsInAir()
	{
		var mac 		: CMovingPhysicalAgentComponent;
		var isInGround	: bool;
		
		
		// Don't update on ragdoll
		if( thePlayer.IsRagdolled() )
		{
			return;
		}
		
		mac = ( CMovingPhysicalAgentComponent ) thePlayer.GetMovingAgentComponent();
		if( mac )
		{
			isInGround	= mac.IsOnGround();
			thePlayer.SetIsInAir( !isInGround );
		}
	}
	
	function StatsUpdate()
	{
		var curVitality : float;
		
		curVitality = thePlayer.GetStat(BCS_Vitality);
		lastVitality = curVitality;
	}
	
	timer function CombatEndCheck( timeDelta : float , id : int)
	{
		// We have a special case for sprinting
		if( !parent.IsInCombat() )//&& !parent.GetIsSprinting() )
		{
			if( timeToCheckCombatEndCur < 0.0f )
			{
				parent.GoToExplorationIfNeeded(); 
			}
			else
			{
				timeToCheckCombatEndCur	-= timeDelta;
			}
		}
		else
		{
			timeToCheckCombatEndCur	= timeToCheckCombatEndMax;
		}
	}
	
	public function ResetTimeToEndCombat()
	{
		timeToCheckCombatEndCur	= timeToCheckCombatEndMax;
	}

	event OnCombatActionEnd()
	{
		virtual_parent.OnCombatActionEnd();
		//updatePosition = false; //MS: Since we are not translation scaling anymore, this is useless now as we need to constantly update rotation
	}
	
	
	var cFMCameraZoomIsEnabled : bool;
	
	event OnCFMCameraZoomFail()
	{
		CFMCameraZoomFail();
	}
	
	entry function CFMCameraZoomFail()
	{
		var camera : CCustomCamera = theGame.GetGameCamera();
		var animation : SCameraAnimationDefinition;
		
		animation.animation = 'camera_combat_focus_fail';
		animation.priority = CAP_Highest;
		animation.blendIn = 0.1f;
		animation.blendOut = 0.1f;
		animation.weight = 1.f;
		animation.speed	= 1.0f;
		animation.loop = false;
		animation.additive = true;
		animation.reset = true;
		
		camera.PlayAnimation( animation );
	}
	
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{	
		/*if( thePlayer.IsPerformingPhaseChangeAnimation() )
		{
			return true;
		}*/
			
		if( super.OnGameCameraTick( moveData, dt ) )
		{
			return true;
		}
		if( thePlayer.IsFistFightMinigameEnabled() )
		{
			theGame.GetGameCamera().ChangePivotRotationController( 'Exploration' );
			theGame.GetGameCamera().ChangePivotDistanceController( 'Default' );
			theGame.GetGameCamera().ChangePivotPositionController( 'Default' );
			// HACK
			moveData.pivotRotationController = theGame.GetGameCamera().GetActivePivotRotationController();
			moveData.pivotDistanceController = theGame.GetGameCamera().GetActivePivotDistanceController();
			moveData.pivotPositionController = theGame.GetGameCamera().GetActivePivotPositionController();
			// END HACK		
			moveData.pivotPositionController.SetDesiredPosition( thePlayer.GetWorldPosition() );
			moveData.pivotRotationController.SetDesiredPitch( -10.0f );
			moveData.pivotRotationController.maxPitch = 50.0;
			moveData.pivotDistanceController.SetDesiredDistance( 3.5f );
			moveData.pivotPositionController.offsetZ = 1.3f;
			
			DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 1.0f, 2.0f, 0), 0.3f, dt );
			moveData.pivotRotationController.SetDesiredHeading( VecHeading( parent.GetDisplayTarget().GetWorldPosition() - parent.GetWorldPosition() ) + 60.0f, 0.5f );
			
			
			//DEBUG
			//Camera Controller XYZ
			//DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( theGame.GetGameplayConfigFloatValue( 'debugA' ), theGame.GetGameplayConfigFloatValue( 'debugB' ), theGame.GetGameplayConfigFloatValue( 'debugC' ) ), 0.3f, dt );
			//Camera Rotation
			//moveData.pivotRotationController.SetDesiredHeading( VecHeading( parent.GetDisplayTarget().GetWorldPosition() - parent.GetWorldPosition() ) + theGame.GetGameplayConfigFloatValue( 'debugD' ), 0.1f );
		}
		
		if ( parent.IsThreatened() || parent.GetPlayerMode().GetForceCombatMode() )
		{
			theGame.GetGameCamera().ChangePivotDistanceController( 'ScriptedCombat' );
			// HACK
			moveData.pivotDistanceController = theGame.GetGameCamera().GetActivePivotDistanceController();
			// END HACK
		}
		
		return false;
	}
	
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		var enemies : array<CActor> = parent.GetMoveTargets();
		var buff : CBaseGameplayEffect;
		var targetCapsuleHeight : float;
		var offset	:  float;
		var playerToTargetVector	: Vector;
		
		/*if( thePlayer.IsPerformingPhaseChangeAnimation() )
		{
			return true;
		}*/
		
		if( parent.movementLockType == PMLT_NoRun )
		{			
			if ( enemies.Size() == 1 )
			{
				if ( parent.IsCombatMusicEnabled() || parent.GetPlayerMode().GetForceCombatMode() )
					UpdateCameraInterior( moveData, dt );
				else	
					parent.UpdateCameraInterior( moveData, dt );
					
				return true;
			}
			else if ( !parent.IsCombatMusicEnabled() && !parent.IsInCombatAction() )
			{
				parent.UpdateCameraInterior( moveData, dt );
				return true;
			}
		}
		
		buff = parent.GetCurrentlyAnimatedCS();
		if ( ( ( parent.IsInCombatAction() || buff  ) && ( !parent.IsInCombat() || !( parent.moveTarget && parent.moveTarget.IsAlive() && parent.IsThreat( parent.moveTarget ) ) ) )
				|| parent.GetPlayerCombatStance() == PCS_AlertFar )
			parent.UpdateCameraCombatActionButNotInCombat( moveData, dt );
		
		if ( !parent.IsInCombatAction() )
			virtual_parent.UpdateCameraSprint( moveData, dt );
			
		if ( virtual_parent.UpdateCameraForSpecialAttack( moveData, dt ) )
			return true;
		
		if ( ( parent.IsCameraLockedToTarget() /*|| parent.IsPCModeEnabled()*/ ) && !cameraChanneledSignEnabled )
		{
			UpdateCameraInterior( moveData, dt );
			return true;
		}			
		//Add camera offset if you are one-on-one against tall enemy 
		if ( parent.GetPlayerCombatStance() == PCS_AlertNear )
		{
			if ( enemies.Size() <= 1 && parent.moveTarget)
			{
				targetCapsuleHeight = ( (CMovingPhysicalAgentComponent)parent.moveTarget.GetMovingAgentComponent() ).GetCapsuleHeight();
				if ( targetCapsuleHeight > 2.f )
				{
					playerToTargetVector = parent.moveTarget.GetWorldPosition() - parent.GetWorldPosition();
					offset = ( 2 - ( targetCapsuleHeight + playerToTargetVector.Z ) )/(-2);
					offset = ClampF( offset, 0.f, 1.f );
					DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( moveData.cameraLocalSpaceOffset.X, moveData.cameraLocalSpaceOffset.Y, moveData.cameraLocalSpaceOffset.Z + offset ), 1.f, dt );
				}
			}
		}
		
		super.OnGameCameraPostTick( moveData, dt );
	}

	/**
	Dynamically changes Player's orientantion and combat stance depending on his current action and the availability of his target
	*/
	private function ProcessPlayerOrientation()
	{
		var newOrientationTarget		: EOrientationTarget;
		var customOrientationInfo		: SCustomOrientationInfo;
		var customOrientationTarget		: EOrientationTarget;

		if ( parent.GetCustomOrientationTarget( customOrientationInfo ) )
			customOrientationTarget = customOrientationInfo.orientationTarget;
		else
			customOrientationTarget = OT_None;

		if ( parent.moveTarget )
		{
			if ( parent.moveTarget.GetGameplayVisibility() )
				newOrientationTarget = OT_Actor;
			else if ( parent.playerMoveType > PMT_Idle )
				newOrientationTarget = OT_Camera;
			else
				newOrientationTarget = OT_Player;
		}
		else if ( parent.IsCastingSign() && !parent.IsInCombat() )
			newOrientationTarget = OT_CameraOffset;
		//else if ( parent.target && parent.IsInCombatAction() )
		//	newOrientationTarget = OT_Actor;
		else
			newOrientationTarget = OT_Player;
			
		//if ( parent.GetCurrentStateName() == 'CombatFists' && !parent.moveTarget )
		//	newOrientationTarget = OT_Player;

		if ( parent.IsGuarded() )
		{
			if( parent.moveTarget )
			{
				if ( VecDistance( parent.moveTarget.GetWorldPosition(), parent.GetWorldPosition() ) > parent.findMoveTargetDist )
					newOrientationTarget = OT_Camera;
			}
			else if ( !parent.delayOrientationChange )
				newOrientationTarget = OT_Camera;
		}

		//if ( parent.GetIsSprinting() && !parent.IsGuarded() )
		//	newOrientationTarget = OT_Player;
			
		if ( parent.IsThrowingItemWithAim() )
			newOrientationTarget = OT_CameraOffset;	
			
		if ( customOrientationTarget != OT_None )
			newOrientationTarget = customOrientationTarget;
			
		if ( parent.delayOrientationChange )
			newOrientationTarget = parent.GetOrientationTarget();

		if ( newOrientationTarget != parent.GetOrientationTarget() )
			parent.SetOrientationTarget( newOrientationTarget );
	}
		
	protected function ProcessPlayerCombatStance()
	{	
		var targetCapsuleHeight		: float;
		var stance					: EPlayerCombatStance;
		var playerToTargetVector	: Vector;
		var playerToTargetDist		: float;
		var wasVisibleInCam 		: bool;
		var moveTargetNPC			: CNewNPC;
	
		parent.findMoveTargetDistMin = 10.f;
		moveTargetNPC = (CNewNPC)(parent.moveTarget);
		if ( virtual_parent.GetPlayerCombatStance() == PCS_AlertNear || virtual_parent.GetPlayerCombatStance() == PCS_Guarded )
			parent.findMoveTargetDist = parent.findMoveTargetDistMax;
		else
			parent.findMoveTargetDist = parent.findMoveTargetDistMin;
	
		if ( parent.moveTarget 
			&& moveTargetNPC.GetCurrentStance() != NS_Fly 
			//&& parent.moveTarget.GetGameplayVisibility()
			&& parent.enableStrafe 
			&& parent.IsThreat( parent.moveTarget )
			&& parent.IsEnemyVisible( parent.moveTarget ) )
		{
			playerToTargetVector = parent.moveTarget.GetNearestPointInPersonalSpace( parent.GetWorldPosition() ) - parent.GetWorldPosition();
			playerToTargetDist = VecLength( playerToTargetVector );
			if (  playerToTargetDist <= parent.findMoveTargetDist )
				stance = PCS_AlertNear;
			else 
			{
				if ( parent.findMoveTargetDist <= parent.findMoveTargetDistMin ) 
				{
					targetCapsuleHeight = ( (CMovingPhysicalAgentComponent)parent.moveTarget.GetMovingAgentComponent() ).GetCapsuleHeight();
					if ( targetCapsuleHeight > 2.f )  
					{
						parent.findMoveTargetDistMin = 15.f;
						parent.findMoveTargetDist = parent.findMoveTargetDistMin;
						
						if ( playerToTargetDist <= parent.findMoveTargetDist )
							stance = PCS_AlertNear;
						else
							stance = PCS_AlertFar;
					}
					else
						stance = PCS_AlertFar;
				}				
				else	
					stance = PCS_AlertFar;
			}
		}
		else if ( moveTargetNPC && moveTargetNPC.GetCurrentStance() == NS_Fly )
		{
			if ( AbsF( playerToTargetVector.Z ) < 25 && VecLength2D( playerToTargetVector ) < parent.findMoveTargetDist * 2.f )
				stance = PCS_AlertNear;
			else	
				stance = PCS_AlertFar;				
		}
		else if ( parent.IsCastingSign() && !parent.IsInCombat() )
			stance = PCS_Normal;
		else
			stance = virtual_parent.GetPlayerCombatStance();

		//if ( virtual_parent.GetPlayerCombatStance() == PCS_AlertNear !parent.IsEnemyVisible( parent.moveTarget ) )
		//	stance = PCS_AlertFar;
		
		if ( !parent.IsEnemyVisible( parent.moveTarget ) )
		{
			if ( virtual_parent.GetPlayerCombatStance() == PCS_AlertNear || parent.IsInCombat() )
				stance = PCS_AlertFar;
		}
	
		// @E3HACK
		//if ( thePlayer.GetPlayerMode().ShouldForceAlertNearStance() )
		//	stance = PCS_AlertNear;
		
		if ( parent.IsGuarded() )
			stance = PCS_Guarded;
		else if ( stance == PCS_Guarded )
			stance = PCS_AlertFar;
			
		if ( !parent.IsThreatened() )	
			stance = PCS_Normal;	
		
		if( FactsQuerySum("force_stance_normal") > 0 )
		{
			stance = PCS_Normal;
		}
		
		if ( virtual_parent.GetPlayerCombatStance() == PCS_AlertNear && stance != PCS_AlertNear && stance != PCS_Guarded )
		{
			if ( !parent.IsEnemyVisible( parent.moveTarget ) &&  playerToTargetDist <= parent.findMoveTargetDist )
				DisableCombatStance( 5.f, stance );
			else 
				SetStance( stance ); 
		}
		else
			SetStance( stance );
	}
	
	var cachedStance 				: EPlayerCombatStance;
	var disableCombatStanceTimer	: bool;
	protected function DisableCombatStance( timeDelta : float, stance : EPlayerCombatStance )
	{
		cachedStance = stance;
		if ( !disableCombatStanceTimer )
		{ 
			disableCombatStanceTimer = true;
			parent.AddTimer( 'DisableCombatStanceTimer', timeDelta );
		}
	}	
	
	private timer function DisableCombatStanceTimer( timeDelta : float , id : int)
	{
		SetStance( cachedStance ); 
	}
	
	protected function SetStance( stance : EPlayerCombatStance )
	{
		parent.RemoveTimer( 'DisableCombatStanceTimer' );
		disableCombatStanceTimer = false;	
	
		//if ( virtual_parent.GetPlayerCombatStance() != stance )
		virtual_parent.SetPlayerCombatStance( stance );

		if ( stance == PCS_AlertNear || stance == PCS_Guarded )
		{
			parent.RestoreOriginalInteractionPriority();
			parent.SetScriptMoveTarget( parent.moveTarget );
		}
		else
		{
			parent.SetInteractionPriority( IP_Prio_0 );
			parent.SetScriptMoveTarget( NULL );
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Animation Events	
	event OnAnimEvent_AllowInput( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if (!parent.GetBIsCombatActionAllowed() && !parent.IsActorLockedToTarget() )
		{
			if ( animEventType == AET_DurationStart )
			{
				parent.EnableFindTarget( true );
			}		
		}
		virtual_parent.OnAnimEvent_AllowInput(animEventName,animEventType,animInfo);
	}
	
	event OnAnimEvent_AllowRoll( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationEnd )
		{
			parent.bIsRollAllowed = false; 
		}
	}
	
	event OnAnimEvent_ForceAttack( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		parent.RemoveTimer( 'ProcessAttackTimer' );
		ProcessAttack( cachedPlayerAttackType, true );
	}
	
	event OnAnimEvent_PunchHand( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventName == 'PunchHand_Left' )
		{
			parent.SetBehaviorVariable( 'punchHand', 0.0f );
		}		
		else if ( animEventName == 'PunchHand_Right' )
		{
			parent.SetBehaviorVariable( 'punchHand', 1.0f );
		}
	}
	
	//This event is fired each time we swing the weapon
	event OnPreAttackEvent(animEventName : name, animEventType : EAnimationEventType, data : CPreAttackEventData, animInfo : SAnimationEventAnimInfo )
	{
		var res : bool;
		var weaponEntity : CEntity;
		
		if(parent.HasAbility('Runeword 2 _Stats', true))
		{
			if(data.attackName == 'attack_heavy_special')
			{
				data.rangeName = 'runeword2_heavy';		//instead of slash_long
				weaponEntity = thePlayer.inv.GetItemEntityUnsafe(thePlayer.inv.GetItemFromSlot(data.weaponSlot));
				weaponEntity.PlayEffectSingle('heavy_trail_extended_fx');
			}
			else if(data.attackName == 'attack_light_special')
			{
				data.rangeName = 'runeword2_light';		//instead of specialattacklight
				weaponEntity = thePlayer.inv.GetItemEntityUnsafe(thePlayer.inv.GetItemFromSlot(data.weaponSlot));
				weaponEntity.PlayEffectSingle('light_trail_extended_fx');
			}
		}
		else if(parent.HasAbility('Runeword 1 _Stats', true) && (W3PlayerWitcher)parent && GetWitcherPlayer().GetRunewordInfusionType() == ST_Igni)
		{
			weaponEntity = thePlayer.inv.GetItemEntityUnsafe(thePlayer.inv.GetItemFromSlot(data.weaponSlot));
			weaponEntity.PlayEffectSingle('runeword1_fire_trail');
		}
		
		res = virtual_parent.OnPreAttackEvent( animEventName, animEventType, data, animInfo );
		
		if ( animEventType == AET_DurationEnd && parent.HasHitTarget() )
		{
			comboPlayer.PlayHit();
		}
		return res;
	}
	
	event OnPerformGuard()
	{			
		OnInterruptAttack();
		
		//parent.SetSlideTarget( NULL ); 
		//parent.ProcessLockTarget();
	}
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Evade
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnPerformEvade( playerEvadeType : EPlayerEvadeType )
	{		
		if ( playerEvadeType == PET_Dodge )
		{
			parent.bIsRollAllowed = true;
			PerformEvade( PET_Dodge, false);
		}
		else if ( playerEvadeType == PET_Roll )
		{
			PerformEvade( PET_Dodge, true);
		}
			
		
	}
	
	var evadeTarget 			: CActor;
	var wasLockedToTarget 		: bool;	
	var angle 					: float;
	var cachedDodgeDirection 	: EPlayerEvadeDirection;
	var prevRawLeftJoyRot 		: float ;
	var evadeTargetPos			: Vector;
	var cachedRawDodgeHeading	: float;
	var turnInPlaceBeforeDodge	: bool;
	entry function PerformEvade( playerEvadeType : EPlayerEvadeType, isRolling : bool )
	{
		var rawDodgeHeading				: float;
		var predictedDodgePos			: Vector;
		var lineWidth					: float;
		var noCreatureOnLine			: bool;
		
		var tracePosFrom				: Vector;
		var playerToTargetRot			: EulerAngles;
		var predictedDodgePosNormal		: Vector;
		var dodgeNum					: float;
		var randNum						: int;
		var randMax						: int;
		var i							: int;
		var submergeDepth				: float;
	
		var dodgeLength					: float;
		var intersectPoint				: Vector;		
		var intersectLength				: float;
		var playerToPoint				: float;
//		var isRolling					: bool;
		var moveTargets					: array<CActor>;
		var playerToTargetAngleDiff		: float;
		var playerToRawAngleDiff		: float;
		var playerToCamAngleDiff		: float;
		
		var targetCapsuleRadius 		: float;
		
		//parent.AddTimer( 'SnapToNavmeshTimer', 0.05f, true );
		//parent.SetCleanupFunction( 'UnsnapFromNavmesh' );
		parent.ResetUninterruptedHitsCount();		//dodge resets the counter
		parent.SetIsCurrentlyDodging(true, isRolling);
	
		parent.RemoveTimer( 'UpdateDodgeInfoTimer' );

		if ( parent.IsHardLockEnabled() && parent.GetTarget() )
			evadeTarget = parent.GetTarget();
		else
		{
			parent.FindMoveTarget();
			evadeTarget = parent.moveTarget;		
		}
		
		//if ( theInput.IsActionPressed( 'Alternate' ) )
			//isRolling = true;
			
		if ( isRolling )
		{
			dodgeLength = 6.5f;
		}
		else
		{
			if ( parent.GetCurrentStateName() == 'CombatFists' )
				dodgeLength = 3.f;
			else
				dodgeLength = 3.5f;
		}
				
		intersectLength = dodgeLength * 0.75;
	
		evadeTargetPos = evadeTarget.PredictWorldPosition( 0.4f ); //evadeTarget.GetWorldPosition();
		
		dodgeDirection = GetEvadeDirection( playerEvadeType );
		rawDodgeHeading = GetRawDodgeHeading();
		parent.evadeHeading = rawDodgeHeading;
		
		
		predictedDodgePos = VecFromHeading( rawDodgeHeading ) * dodgeLength + parent.GetWorldPosition();
		parent.GetVisualDebug().AddSphere('predictedDodgePos', 0.25, predictedDodgePos, true, Color(0,128,256), 5.0f );
		parent.GetVisualDebug().AddSphere('evadeTargetPos', 0.25, evadeTargetPos, true, Color(255,255,0), 5.0f );
		parent.GetVisualDebug().AddArrow( 'DodgeVector', parent.GetWorldPosition(), predictedDodgePos, 1.f, 0.2f, 0.2f, true, Color(0,128,256), true, 5.f );

		turnInPlaceBeforeDodge = false;		
		
		//Choose the dodge animation (and whether it should be the flipped version or not) to play
		if ( evadeTarget )
		{
			intersectPoint = VecFromHeading( rawDodgeHeading ) * VecDot( VecFromHeading( rawDodgeHeading ), evadeTargetPos - parent.GetWorldPosition() ) + parent.GetWorldPosition();
			parent.GetVisualDebug().AddArrow( 'DodgeVector', parent.GetWorldPosition(), VecFromHeading( rawDodgeHeading ) * intersectLength + parent.GetWorldPosition(), 1.f, 0.2f, 0.2f, true, Color(0,128,256), true, 5.f );
			parent.GetVisualDebug().AddArrow( 'DodgeVector2', intersectPoint, evadeTargetPos, 1.f, 0.2f, 0.2f, true, Color(0,128,256), true, 5.f );
			moveTargets = parent.GetMoveTargets();
			
			playerToTargetAngleDiff = AbsF( AngleDistance( parent.GetHeading(), VecHeading( evadeTargetPos - parent.GetWorldPosition() ) ) );
			playerToRawAngleDiff = AbsF( AngleDistance( rawDodgeHeading, parent.GetHeading() ) );
			
			if ( parent.playerMoveType == PMT_Run || ( parent.playerMoveType > PMT_Run && parent.GetSprintingTime() > 0.12 ) )
			{
				if ( playerToRawAngleDiff < 90 )
				{
					dodgeDirection = PED_Forward;
				}
				else
				{
					dodgeDirection = PED_Back;
					turnInPlaceBeforeDodge = true;
				}
			}
			else
			{
				// You're not facing the enemy
				if ( playerToTargetAngleDiff > 90 )
				{
					//Your pushing the stick towards your facing direction
					if ( playerToRawAngleDiff < 90 )
					{
						dodgeDirection = PED_Forward;
						turnInPlaceBeforeDodge = true;
					}
					else
					{
						//Your dodge is beyond the flip point
						if ( VecLength( intersectPoint - parent.GetWorldPosition() ) < intersectLength )
						{
							if ( theGame.TestNoCreaturesOnLine( parent.GetWorldPosition(), predictedDodgePos, 0.1, parent, NULL, true ) )
								//&& VecDistance( evadeTargetPos, intersectPoint ) > 0.4 )
							{
								dodgeDirection = PED_Back;					
							}
							else 
							{
								dodgeDirection = PED_Back;
								turnInPlaceBeforeDodge = true;	
							}
						}
						else
						{
							dodgeDirection = PED_Back;
							turnInPlaceBeforeDodge = true;							
						}
					}
				}
				else
				{
					//You're pushing the stick towards your facing direction
					if ( playerToRawAngleDiff < 90 )
					{
						//Your dodge is beyond the flip point
						if ( VecLength( intersectPoint - parent.GetWorldPosition() ) < intersectLength )
						{
							if ( theGame.TestNoCreaturesOnLine( parent.GetWorldPosition(), predictedDodgePos, 0.1, parent, NULL, true ) )
								//&& VecDistance( evadeTargetPos, intersectPoint ) > 0.4 )
							{
								dodgeDirection = PED_Forward;
								turnInPlaceBeforeDodge = true;
							}
							else
								dodgeDirection = PED_Forward;
						}
						else
							dodgeDirection = PED_Forward;
					}
					else
					{
						//Your dodge is beyond the flip point && the intersectPoint is behind you
						if ( VecLength( intersectPoint - parent.GetWorldPosition() ) < intersectLength && AbsF( AngleDistance( VecHeading( intersectPoint - parent.GetWorldPosition() ), rawDodgeHeading ) ) < 10.f  )
						{
							if ( theGame.TestNoCreaturesOnLine( parent.GetWorldPosition(), predictedDodgePos, 0.1, parent, NULL, true ) )
								//&& VecDistance( evadeTargetPos, intersectPoint ) > 0.4 )
							{
								dodgeDirection = PED_Back;
							}
							else
							{
								dodgeDirection = PED_Back;
								turnInPlaceBeforeDodge = true;
							}
						}          
						else
						{
							dodgeDirection = PED_Back;
						}
					}
				}
				targetCapsuleRadius = ( (CMovingPhysicalAgentComponent)evadeTarget.GetMovingAgentComponent() ).GetCapsuleRadius();
				if ( parent.IsHardLockEnabled() && targetCapsuleRadius > 0.8f )
				{
					playerToCamAngleDiff = AbsF( AngleDistance( parent.GetHeading(), VecHeading( theCamera.GetCameraDirection() ) ) );
					if ( playerToCamAngleDiff > 0 && playerToCamAngleDiff < 110 )			
					{
						//You're pushing the stick towards your facing direction
						if ( playerToRawAngleDiff < 90 )
						{
							dodgeDirection = PED_Forward;
							turnInPlaceBeforeDodge = false;	
						}
					}	
					
					if ( playerToCamAngleDiff > 60 && playerToCamAngleDiff < 135 )
					{
						//You're pushing the stick towards your facing direction
						if ( playerToRawAngleDiff > 120 )
						{					
							dodgeDirection = PED_Back;
							turnInPlaceBeforeDodge = true;
						}
					}					
				}				
			}
		}		

		if(!SkipStaminaDodgeEvadeCost())
		{
			if(isRolling)
				parent.DrainStamina(ESAT_Roll);
			else
				parent.DrainStamina(ESAT_Dodge);
		}
		
		if ( dodgeDirection == PED_Forward )
		{
			if ( evadeTarget )
			{
				evadeTarget.SignalGameplayEventParamInt('Time2Dodge', (int)EDT_Fear );
				
				if ( wasLockedToTarget  )
					parent.SetUnpushableTarget( evadeTarget );
			}
		}
		
		if ( !theGame.GetWorld().StaticTrace( predictedDodgePos + Vector(0,0,5), predictedDodgePos + Vector(0,0,-5) , predictedDodgePos, predictedDodgePosNormal ) )
			playerToTargetRot.Pitch = 0.f;
		else	
			playerToTargetRot = VecToRotation( predictedDodgePos - parent.GetWorldPosition() );
		
		submergeDepth = ((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).GetSubmergeDepth();
		
		FillDodgePlaylists( isRolling );
		
		if ( !parent.GetWeaponHolster().IsMeleeWeaponReady() )
		{
			dodgeNum = 0;
		}
		else if ( !turnInPlaceBeforeDodge )//select which back dodge animation to play yep...
		{
			if ( dodgeDirection == PED_Back )
			{
				parent.SetBehaviorVariable( 'dodgeNum', dodgePlaylistBck[ dodgePlaylistBck.Size() - 1 ] ); 
				dodgePlaylistBck.EraseFast( dodgePlaylistBck.Size() - 1 );
			}
			else
			{
				parent.SetBehaviorVariable( 'dodgeNum', dodgePlaylistFwd[ dodgePlaylistFwd.Size() - 1 ] ); 
				dodgePlaylistFwd.EraseFast( dodgePlaylistFwd.Size() - 1 );			
			}
		}
		else
		{
			if ( dodgeDirection == PED_Forward )
			{
				parent.SetBehaviorVariable( 'dodgeNum', dodgePlaylistFlipFwd[ dodgePlaylistFlipFwd.Size() - 1 ] ); 
				dodgePlaylistFlipFwd.EraseFast( dodgePlaylistFlipFwd.Size() - 1 );			
			}
		}
		
			
		//parent.SetBehaviorVariable( 'dodgeNum', dodgeNum );//dodgePosPitch
		parent.SetBehaviorVariable( 'combatActionType', (int)CAT_Dodge );
		parent.SetBehaviorVariable(	'playerEvadeDirection', (int)( dodgeDirection ) ) ;
		parent.SetBehaviorVariable(	'turnInPlaceBeforeDodge', 0.f ) ;
		parent.SetBehaviorVariable(	'isRolling', (int)isRolling ) ;
		
		if ( turnInPlaceBeforeDodge )
			parent.SetBehaviorVariable(	'turnInPlaceBeforeDodge', 1.f ) ;
			
		if ( parent.RaiseForceEvent( 'CombatAction' ) )
			virtual_parent.OnCombatActionStart();
		
		parent.SetCustomRotation( 'Dodge', GetDodgeHeading( playerEvadeType ), 0.0f, 0.1f, false );
		
		if (  turnInPlaceBeforeDodge )
			Sleep( 0.4f );
		else
			Sleep( 0.3f );

		//Bind rotation to event
		if ( parent.bLAxisReleased )
			cachedRawDodgeHeading = rawDodgeHeading;
		else
			cachedRawDodgeHeading = GetRawDodgeHeading();
			
		/*if ( dodgeDirection == PED_Forward )
			parent.SetCustomRotation( 'Dodge', GetDodgeHeadingForMovementHeading( cachedRawDodgeHeading ), 90.0f, 0.0f, false );
		else*/
			parent.SetCustomRotation( 'Dodge', GetDodgeHeadingForMovementHeading( cachedRawDodgeHeading ), 90.0f, 0.0f, false );
		
		parent.BindMovementAdjustmentToEvent( 'Dodge', 'Dodge' );
		parent.AddTimer( 'UpdateDodgeInfoTimer', 0, true );	

		parent.WaitForBehaviorNodeDeactivation( 'DodgeComplete', 0.7f );
		parent.RemoveTimer( 'UpdateDodgeInfoTimer' );
		
		//this is after dodge is finished
		parent.SetIsCurrentlyDodging(false);
		//UnsnapFromNavmesh();		
	}
	

	var dodgePlaylistFwd		: array<float>;
	var dodgePlaylistFlipFwd	: array<float>;
	var dodgePlaylistBck		: array<float>;
	private function FillDodgePlaylists( isRolling : bool )
	{
		var linearSequence				: array<float>;
		var i, rand, numOfAnims			: int;			

		if ( dodgePlaylistFwd.Size() <= 0 )
			dodgePlaylistFwd = CreatePlaylist(2);		
		
		if ( dodgePlaylistFlipFwd.Size() <= 0 )
			dodgePlaylistFlipFwd = CreatePlaylist(2);				

		if ( dodgePlaylistBck.Size() <= 0 )
			dodgePlaylistBck = CreatePlaylist(3);		
	}
	
	private function CreatePlaylist( numOfAnims : int ) : array<float>
	{
		var linearSequence	: array<float>;
		var i, rand			: int;
		var playList		: array<float>;
	
		linearSequence.Clear();
		for ( i = 0; i < numOfAnims; i += 1 )
		{
			linearSequence.PushBack(i);
		}
		
		for ( i = 0; i < numOfAnims; i += 1 )
		{
			rand = RandRange( linearSequence.Size(), 0 );
			playList.PushBack( linearSequence[ rand ] );
			linearSequence.Erase( rand );
		}
		
		return playList;
	}
	
	/*cleanup function UnsnapFromNavmesh()
	{
		((CMovingAgentComponent)parent.GetMovingAgentComponent()).SnapToNavigableSpace( false );
		//parent.RemoveTimer( 'SnapToNavmeshTimer' );
	}*/
	
	/*timer function SnapToNavmeshTimer( dt : float , id : int)
	{
		if ( ((CMovingAgentComponent)parent.GetMovingAgentComponent()).IsOnNavigableSpace() )
		{
			((CMovingAgentComponent)parent.GetMovingAgentComponent()).SnapToNavigableSpace( true );
			parent.RemoveTimer( 'SnapToNavmeshTimer' );
		}
	}*/

	
	//check for skill stamina cost nullify
	private function SkipStaminaDodgeEvadeCost() : bool
	{
		var targetNPC : CNewNPC;
		
		targetNPC = (CNewNPC)parent.GetTarget();
		if( targetNPC )
		{
			//if target is attacking and player has skill
			if( targetNPC.IsAttacking() && parent.CanUseSkill(S_Sword_s09) )
			{
				return true;
			}
		}
		
		return false;
	}
	
	/*
	unused? commenting out
	
	private function PayEvadeStaminaCost()
	{
		var i : int;
	
		//-----clear dodge cost anyway
		
		//remove dodge pay timer
		parent.RemoveTimer('DodgeStaminaCost');
		
		//clear dodge cost ids
		for(i=parent.dodgeStaminaActionIds.Size()-1; i>=0; i-=1)
			parent.ReleaseLockedStamina(parent.dodgeStaminaActionIds[i], false);
		
		parent.dodgeStaminaActionIds.Clear();
			
		//-----pay evade if should pay		
		if(!SkipStaminaDodgeEvadeCost())
			parent.DrainStamina(ESAT_Evade);
	}
	*/
	
	protected function GetEvadeDirection( playerEvadeType : EPlayerEvadeType ) : EPlayerEvadeDirection
	{
		var rawToHeadingAngleDiff 		: float;
		var evadeDirection				: EPlayerEvadeDirection;
		var unusedActor 				: CActor;	//MS: placeholder variable to fix memory error
		var	inputToleranceFwd			: float;
		var	inputToleranceBck			: float;
		var checkedHeading				: Vector;
		var moveTargets					: array<CActor>;
		
		var tempAngleDiff				: float;
	
		moveTargets = parent.GetMoveTargets();
		inputToleranceFwd = 45.f;
		inputToleranceBck = 135.f;
		
		if ( playerEvadeType == PET_Dodge )
		{	
			checkedHeading = VecFromHeading( parent.GetCombatActionHeading() );	
			
			if ( parent.GetPlayerCombatStance() == PCS_AlertNear || parent.GetPlayerCombatStance() == PCS_Guarded )
			{
				inputToleranceFwd = 90.f;
				inputToleranceBck = 90.f;
				rawToHeadingAngleDiff = AngleDistance( VecHeading( evadeTarget.GetWorldPosition() - parent.GetWorldPosition() ), parent.GetCombatActionHeading() );
			}
			else
				rawToHeadingAngleDiff = AngleDistance( parent.GetHeading(), parent.GetCombatActionHeading() );	
		}
		else if ( playerEvadeType == PET_Pirouette )
		{
			if ( wasLockedToTarget  )
			{
				inputToleranceFwd = 30.f;
				inputToleranceBck = 30.f;
				rawToHeadingAngleDiff = AngleDistance( VecHeading( evadeTargetPos - parent.GetWorldPosition() ), parent.GetCombatActionHeading() );
			}
			else
				rawToHeadingAngleDiff = AngleDistance( parent.GetHeading(), parent.GetCombatActionHeading() );
		}		
		else
			rawToHeadingAngleDiff = AngleDistance( parent.GetHeading(), parent.GetCombatActionHeading() );
		
		if ( parent.lAxisReleasedAfterCounterNoCA )
			evadeDirection = PED_Back;
		else if( parent.GetIsSprinting() )
			evadeDirection = PED_Forward;
		else if( rawToHeadingAngleDiff >= ( -1 * inputToleranceFwd ) && rawToHeadingAngleDiff < inputToleranceFwd  )
			evadeDirection = PED_Forward;
		else if( rawToHeadingAngleDiff >= inputToleranceFwd && rawToHeadingAngleDiff < ( 180 - inputToleranceBck ) )
			evadeDirection = PED_Right;		
		else if( rawToHeadingAngleDiff >= ( -180 + inputToleranceBck ) && rawToHeadingAngleDiff < ( -1 * inputToleranceFwd ) )
			evadeDirection = PED_Left;
		else
			evadeDirection = PED_Back;		
		

		return evadeDirection;
	}

	function GetRawDodgeHeading() : float
	{
		var heading : float;
		
		if ( wasLockedToTarget )
		{
			if ( dodgeDirection == PED_Forward  )
				heading = VecHeading( evadeTargetPos - parent.GetWorldPosition() );
			else if ( dodgeDirection == PED_Left )
				heading = VecHeading( evadeTargetPos - parent.GetWorldPosition() ) + 90;
			else if ( dodgeDirection == PED_Right )
				heading = VecHeading( evadeTargetPos - parent.GetWorldPosition() ) - 90;
			else
				heading = VecHeading( evadeTargetPos - parent.GetWorldPosition() ) - 180;
		}
		else
		{
			//heading = parent.GetCombatActionHeading();
			if ( parent.lAxisReleasedAfterCounterNoCA )
				heading = parent.GetHeading() + 180;
			else
				heading = parent.rawPlayerHeading;
			
			if ( parent.lAxisReleasedAfterCounterNoCA && evadeTarget )
				heading = VecHeading( parent.GetWorldPosition() - evadeTarget.GetWorldPosition() );
		}
		
		parent.GetVisualDebug().AddArrow( 'Dodge', parent.GetWorldPosition(), parent.GetWorldPosition() + VecFromHeading( heading )*3, 1.f, 0.2f, 0.2f, true, Color(256,128,128), true, 5.f );
		
		return heading;
	}	

	function GetDodgeHeading( playerEvadeType : EPlayerEvadeType ) : float
	{
		var unusedActor 		: CActor;	//MS: placeholder variable to fix memory error
		var rawDodgeHeading		: float;
		var dodgeHeading		: float;
		
		rawDodgeHeading = GetRawDodgeHeading();
		
		if ( dodgeDirection == PED_Forward )
			dodgeHeading = rawDodgeHeading;
		else if ( dodgeDirection == PED_Right )
			dodgeHeading = rawDodgeHeading + 90;
		else if ( dodgeDirection == PED_Left )
			dodgeHeading = rawDodgeHeading - 90;
		else 
			dodgeHeading = rawDodgeHeading + 180;
			
		return dodgeHeading;	
	}
	
	timer function UpdateDodgeInfoTimer( time : float , id : int)
	{
		if ( wasLockedToTarget && evadeTarget )
		{
			parent.UpdateCustomRotationHeading( 'Dodge', VecHeading( evadeTargetPos - parent.GetWorldPosition() )  );
			parent.UpdateCustomLockMovementHeading( 'DodgeMovement', GetRawDodgeHeading() );			
		}
		else
		{	
			if ( !parent.bLAxisReleased )
				cachedRawDodgeHeading = GetRawDodgeHeading();
				
			parent.UpdateCustomRotationHeading( 'Dodge', GetDodgeHeadingForMovementHeading( cachedRawDodgeHeading ) );
		}	
	}
	

	function GetDodgeHeadingForMovementHeading( movementHeading : float) : float
	{
		var heading : float;
	
		if ( evadeTarget && parent.bLAxisReleased )
			heading = parent.GetHeading();
	
		if ( dodgeDirection == PED_Forward )
			heading = movementHeading;
		else if ( dodgeDirection == PED_Right )
			heading = movementHeading + 90;
		else if ( dodgeDirection == PED_Left )
			heading = movementHeading - 90;
		else
			heading = movementHeading + 180;
			
		if ( turnInPlaceBeforeDodge )
			return heading + 180;
		
		return heading;
	}
	
	timer function UpdateRollInfoTimer( time : float , id : int)
	{
		var playerToTargetDist			: float;
		var evadeTargetSpeed			: float;

		if ( wasLockedToTarget && evadeTarget )
		{
			parent.UpdateCustomRotationHeading( 'Roll', GetRawDodgeHeading() );
			parent.UpdateCustomLockMovementHeading( 'RollMovement', GetRawDodgeHeading() );			
		}
		else
		{	
			if ( !parent.bLAxisReleased )
				parent.UpdateCustomRotationHeading( 'Roll', parent.rawPlayerHeading );
			else	
				parent.UpdateCustomRotationHeading( 'Roll', VecHeading( parent.GetHeadingVector() ) );
		}
		
		parent.GetVisualDebug().AddArrow( 'dodgeInitialHeading', parent.GetWorldPosition(), parent.GetWorldPosition() + VecFromHeading( parent.rawPlayerHeading )*3, 1.f, 0.2f, 0.2f, true, Color(256,128,256), true, 5.f );
	}
	
	protected function GetLandingEvadeDirection( landAt : Vector, evadingHeading : float ) : EPlayerEvadeDirection
	{
		var playerToTargetHeading 		: float;
		var headingDiff 				: float;
		var changeDirection				: EPlayerEvadeDirection;
		var	dontChangeAngle				: float;
		var currentDodgeFwdHeading		: float;
		
		dontChangeAngle = 180;
		//parent.EnableFindTarget( false );

		playerToTargetHeading = VecHeading( evadeTargetPos - landAt );
		currentDodgeFwdHeading = GetDodgeHeadingForMovementHeading( evadingHeading );
		
		headingDiff = AngleDistance( playerToTargetHeading, currentDodgeFwdHeading );

		// should we change left or right? or not change at all?
		if( headingDiff >= -dontChangeAngle && headingDiff < dontChangeAngle  )
			changeDirection = PED_Forward;
		else if( headingDiff >= dontChangeAngle )
			changeDirection = PED_Right;		
		else
			changeDirection = PED_Left;

		if( changeDirection == PED_Forward)
		{
			return dodgeDirection;
		}
		// we assume that dodgeDirection takes only those four values
		if( changeDirection == PED_Right)
		{
			switch( dodgeDirection )
			{
				case PED_Forward:	return PED_Right;
				case PED_Right:		return PED_Back;
				case PED_Back:		return PED_Left;
				case PED_Left:		return PED_Forward;
			}
		}
		if( changeDirection == PED_Left)
		{
			switch( dodgeDirection )
			{
				case PED_Forward:	return PED_Left;
				case PED_Right:		return PED_Forward;
				case PED_Back:		return PED_Right;
				case PED_Left:		return PED_Back;
			}
		}
		return dodgeDirection;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Combo
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	private final function CleanUpComboStuff()
	{
		comboAttackA_Id = -1;
		comboAttackB_Id = -1;
		
		comboAttackA_Target = NULL;
		comboAttackB_Target = NULL;
		
		comboAttackA_Sliding = false;
		comboAttackB_Sliding = false;
		
		comboAspectName = '';
	}
	
	private final function CacheComboAttack( attackId : int, slideTarget : CGameplayEntity, sliding : bool, aspectName : name )
	{
		comboAttackB_Id = comboAttackA_Id;
		comboAttackB_Target = comboAttackA_Target;
		comboAttackB_Sliding = comboAttackA_Sliding;
		
		comboAttackA_Id = attackId;
		comboAttackA_Target = slideTarget;
		comboAttackA_Sliding = sliding;
		
		comboAspectName = aspectName;
	}
	
	public final function BuildComboPlayer()
	{
		if ( !comboPlayer )
		{
			BuildCombo();
		}

		if ( comboPlayer )
		{
			comboPlayer.Init();
		}
	}
	
	private final function BuildCombo()
	{
		// 1. Create definition
		comboDefinition = new CComboDefinition in this;
		
		// 2. Fill aspects
		OnCreateAttackAspects();
		
		// 3. Create player
		comboPlayer = new CComboPlayer in this;
		if ( !comboPlayer.Build( comboDefinition, parent ) )
		{
			LogChannel( 'ComboNode', "Error: BuildCombo" );	
		}
		
		// Set default blend duration between combo's animations
		comboPlayer.SetDurationBlend( 0.2f );
		
		// Clean up combo data
		CleanUpComboStuff();
	}
	
	event OnCreateAttackAspects(){}

	event OnPerformAttack( playerAttackType : name )
	{
		var actor : CActor;
		var finish : CComponent;
		var playerToTargetHeading	: float;
		var shouldFaceTarget : bool;
		var aiStorageObject	: IScriptable;
		var newTarget : CActor;
	
		//
		if ( parent.DisableManualCameraControlStackHasSource('Finisher') )
			return false;
		
		if ( !thePlayer.IsCombatMusicEnabled() 
			&& !thePlayer.CanAttackWhenNotInCombat( EBAT_LightAttack, false, newTarget ) ) 
		{	
			if ( parent.IsInCombatActionFriendly() )
			{
				return false;
			}
				
			actor = (CActor)(parent.slideTarget);	
				
			shouldFaceTarget = true;
			
			if ( shouldFaceTarget )
				parent.SetBehaviorVariable( 'playerToTargetDistForOverlay', VecDistance( parent.GetWorldPosition(), actor.GetNearestPointInPersonalSpace( parent.GetWorldPosition() ) ) );
			else
				parent.SetBehaviorVariable( 'playerToTargetDistForOverlay', 50.f );
			
			aiStorageObject = actor.GetAIStorageObject('ReactionData');
			if ( virtual_parent.DisplayCannotAttackMessage( actor ) )
			{
				return false;
			}
			else
			{
				if ( parent.RaiseAttackFriendlyEvent( actor ) )
				{		
					return true;	
				}	

				return false;
			}
		}
		else
		{
			if ( parent.IsInCombatActionFriendly() )
			{
				parent.RaiseEvent('CombatActionFriendlyEnd');
			}
			
			parent.SendAttackReactionEvent();
			ProcessAttackApproach( playerAttackType );
			parent.ObtainTicketFromCombatTarget('TICKET_Melee',10000);
			parent.ObtainTicketFromCombatTarget('TICKET_Range',10000);
			parent.RemoveTimer('FreeTickets');
		}
	}
	
	private function IsInCombatAction_Attack(): bool
	{
		return parent.IsInCombatAction_Attack();
	}	
	
	var cachedPlayerAttackType	: name;
	var farAttackMinDist 		: float;
	var previousSlideTarget		: CGameplayEntity;
	var finisherDist			: float;
	var isOnHighSlope			: bool;
	entry function ProcessAttackApproach( playerAttackType : name )
	{	
		var playerToTargetDist		: float;
		var playerToTargetVec		: Vector;
		var actor 					: CActor;
		var npc 					: CNewNPC;
		
		var isDeadlySwordHeld		: bool;

		actor = (CActor)parent.slideTarget;
		npc = (CNewNPC)parent.slideTarget;
		
		FactsAdd("ach_attack", 1, 4 );
		theGame.GetGamerProfile().CheckLearningTheRopes();
		if ( actor && ( !npc || npc.GetCurrentStance() != NS_Fly ) )
		{	
			finisherDist = 1.5f;
					
			actor.IsAttacked( true );
			
			if ( actor.GetComponent("Finish").IsEnabled() && ( parent.GetCurrentStateName() == 'CombatSteel' || parent.GetCurrentStateName() == 'CombatSilver' ) )
				parent.OnForceTicketUpdate();
			
			playerToTargetDist = GetPlayerToTargetDistance( true, 1.f );
			
			playerToTargetVec = parent.GetWorldPosition() - actor.GetWorldPosition();
			if ( AbsF( playerToTargetVec.Z ) > 1.f )
				isOnHighSlope = true;
			else 
				isOnHighSlope = false;
			
			if ( parent.GetCurrentStateName() == 'CombatFists' )
				farAttackMinDist = 3.f;
			else
				farAttackMinDist = 4.f;
			
			if ( actor.GetComponent("Finish").IsEnabled() 
				&& playerToTargetDist < GetMaxAttackDist() + 1.f
				&& ( parent.GetCurrentStateName() == 'CombatSteel' || parent.GetCurrentStateName() == 'CombatSilver' ) )
			{
				isDeadlySwordHeld = parent.IsDeadlySwordHeld();
			
				if ( playerToTargetDist < finisherDist || !isDeadlySwordHeld  )
					ProcessAttack( playerAttackType, false );
				else
				{
					if ( parent.IsInCombatAction() && parent.GetBehaviorVariable( 'combatActionType' ) == 8 )	
					{
						if ( previousSlideTarget != actor )
							EnableAttackApproach( playerAttackType );
					}
					else
						EnableAttackApproach( playerAttackType );
				}
			}
			else
			{
				if ( parent.approachAttack == 0 )
				{
					if ( playerToTargetDist > farAttackMinDist && playerToTargetDist < parent.softLockDist )
					{
						if ( parent.IsInCombatAction() && parent.GetBehaviorVariable( 'combatActionType' ) == 8 )	
						{
							if ( previousSlideTarget != actor )
								EnableAttackApproach( playerAttackType );
						}
						else
							EnableAttackApproach( playerAttackType );
					}
					else
						ProcessAttack( playerAttackType, false );
				}	
				else
					ProcessAttack( playerAttackType, false );
			}
			
		}
		/*else if ( parent.GetIsSprinting() )
			ProcessAttack( playerAttackType, true );*/
		else
		{
			ProcessAttack( playerAttackType, false );
		}
	}
	
	entry function EnableAttackApproach( playerAttackType : name )
	{
		var playerToTargetHeading	: float;
			
		previousSlideTarget = parent.slideTarget;
		playerToTargetHeading = VecHeading( parent.slideTarget.GetWorldPosition() - parent.GetWorldPosition() );
		
		if ( parent.RaiseForceEvent( 'CombatAction' ) )
			virtual_parent.OnCombatActionStart();
			
		parent.SetBehaviorVariable( 'combatActionType', 8 );
		parent.SetCustomRotation( 'PreAttack_Rotation', playerToTargetHeading, 0.0f, 0.2f, false );
		parent.CustomLockMovement( 'PreAttack_Movement', playerToTargetHeading );
		parent.BindMovementAdjustmentToEvent( 'PreAttack_Movement', 'PreAttack_Movement' );
		cachedPlayerAttackType = playerAttackType;
		
		parent.SetBehaviorVariable( 'approachDirectionWS', playerToTargetHeading );
		parent.SetBehaviorVariable( 'approachDirectionLS', AngleDistance( parent.GetHeading(), playerToTargetHeading )/180 );

		parent.AddTimer( 'ProcessAttackTimer', 0.1f, true );
		//parent.AddTimer( 'AttackTimerEnd', 2.f );
	}

	var prevPlayerToTargetDist			: float;
	//var prevTargetPos					: Vector;
	var wasDecreasing					: bool;
	timer function ProcessAttackTimer( time : float , id : int)
	{
		var slideDistance 			: float;
		var playerToTargetDist		: float;
		var playerToTargetHeading	: float;
		
		playerToTargetDist = GetPlayerToTargetDistance( true, 1.f );
		playerToTargetHeading = VecHeading( parent.slideTarget.GetWorldPosition() - parent.GetWorldPosition() );
		parent.SetBehaviorVariable( 'approachDirectionWS', playerToTargetHeading );
		parent.SetBehaviorVariable( 'approachDirectionLS', AngleDistance( parent.GetHeading(), playerToTargetHeading )/180 );
		
		parent.UpdateCustomLockMovementHeading( 'PreAttack_Movement', playerToTargetHeading );
		parent.UpdateCustomRotationHeading( 'PreAttack_Movement', playerToTargetHeading );
		
		if ( !parent.slideTarget )
			ProcessAttack( cachedPlayerAttackType, true );
		else if ( parent.slideTarget.GetComponent("Finish").IsEnabled() )
		{
			playerToTargetDist = GetPlayerToTargetDistance( false, 1.f );
			if ( playerToTargetDist < finisherDist )	
				ProcessAttack( cachedPlayerAttackType, true );
		}
		else if ( isOnHighSlope )
		{
			if ( playerToTargetDist < 2.f )
				ProcessAttack( cachedPlayerAttackType, true );	
		}
		else if ( playerToTargetDist < farAttackMinDist )
			ProcessAttack( cachedPlayerAttackType, true );

		if ( playerToTargetDist < prevPlayerToTargetDist )
			wasDecreasing = true;				
		else if ( wasDecreasing && playerToTargetDist > prevPlayerToTargetDist  )
		{
			wasDecreasing = false;
			ProcessAttack( cachedPlayerAttackType, true );
		}					
		
		prevPlayerToTargetDist = playerToTargetDist;
	}
	
	timer function AttackTimerEnd( time : float , id : int)
	{
		var slideTargetNPC	: CNewNPC;
		
		slideTargetNPC = (CNewNPC)( parent.slideTarget );
		if ( !slideTargetNPC || !slideTargetNPC.IsInFinisherAnim() || !parent.isInFinisher )
		{
			parent.SetSlideTarget( parent.GetCombatActionTarget( EBAT_LightAttack ) );
			ProcessAttack( cachedPlayerAttackType, true );
		}
	}
	
	var enableSoftLock	: bool; //when running in combat, geralt will not rotate towards the moveTarget
	entry function ProcessAttack( playerAttackType : name, performApproachAttack : bool )
	{
		var temp1 					: name;
		var temp2, temp3, temp4 	: bool;
		var playerToTargetVec		: Vector;
		var playerToTargetRot		: EulerAngles;
		var targetCapsuleHeight		: float;
		var attackTarget			: CActor;
		var tempPos1				: Vector;
		var tempPos2				: Vector;
		var noSlideTargetPos		: Vector;
		var noSlideTargetNormal		: Vector;
		var temp					: CActor;
		var npc, npcAttackTarget	: CNewNPC;
		var witcher					: W3PlayerWitcher;
		var i						: int;
		var isDeadlySwordHeld		: bool;
		var comp					: CComponent;
		var compEnabled				: bool;
		var useNormalAttack 		: bool;

		parent.RemoveTimer( 'ProcessAttackTimer' );
		parent.RemoveTimer( 'AttackTimerEnd' );
		npc = (CNewNPC)parent.slideTarget;
		
		if(npc)
		{
			comp = npc.GetComponent("Finish");
			compEnabled = comp.IsEnabled();
		}
		isDeadlySwordHeld = parent.IsDeadlySwordHeld();
		if ( npc 
			&& compEnabled
			&& ( VecDistance( parent.GetWorldPosition(), npc.GetNearestPointInBothPersonalSpaces( parent.GetWorldPosition() ) ) < 1.5f || !isDeadlySwordHeld ) )
		{
			if ( !isDeadlySwordHeld )
			{
				if ( parent.IsWeaponHeld( 'fist' ))
					parent.SetBehaviorVariable( 'combatTauntType', 1.f );
				else
					parent.SetBehaviorVariable( 'combatTauntType', 0.f );
					
				if ( parent.RaiseEvent( 'CombatTaunt' ) )
					parent.PlayBattleCry( 'BattleCryTaunt', 1.f, true, true );
	
				//if ( parent.RaiseEvent( 'CombatTaunt' ) )
				//	virtual_parent.OnCombatActionStart();
			}
			else if ( parent.IsWeaponHeld( 'steelsword' ) || parent.IsWeaponHeld( 'silversword' ) )
			{
				if ( !theGame.GetWorld().NavigationLineTest( parent.GetWorldPosition(), npc.GetWorldPosition(), 0.4f ) ) 
				{
					useNormalAttack = true;
					comp.SetEnabled( false );
				}
				else if ( !parent.isInFinisher )
				{	
					npc.SignalGameplayEvent( 'Finisher' );
					parent.AddTimer( 'AttackTimerEnd', 0.2f );
				}
			}
			else
			{
				//FAILSAFE
				parent.SetBehaviorVariable( 'combatTauntType', 0.f );
				
				if ( parent.RaiseEvent( 'CombatTaunt' ) )
					parent.PlayBattleCry( 'BattleCryTaunt', 1.f, true, true );
					
				//if ( parent.RaiseEvent( 'CombatTaunt' ) )
				//	virtual_parent.OnCombatActionStart();
			}	
		}
		else
			useNormalAttack = true;
		
		if ( useNormalAttack )
		{		
			parent.GetMovingAgentComponent().GetMovementAdjustor().CancelAll();

			if ( !comboPlayer )
			{
				BuildComboPlayer();
				//BuildCombo(); 
				//comboPlayer.Init();
			}		

			enableSoftLock = true;
			if ( parent.IsInCombat() 
				&& thePlayer.IsSprintActionPressed()
				&& !parent.bLAxisReleased
				&& !parent.IsActorLockedToTarget()
				&& parent.GetForceDisableUpdatePosition() )
				enableSoftLock = false;
			
			updatePosition = true;
			if ( !enableSoftLock )
				updatePosition = false;
			
			attackTarget = (CActor)parent.slideTarget;
			npcAttackTarget = (CNewNPC)attackTarget;
			
			// Set unpushable target to both attacker and target
			// Effect: None will be pushed aside by animation
			//if( attackTarget.GetInteractionPriority() < parent.GetInteractionPriority() )
			//{
			if(attackTarget)
			{
				attackTarget.SetUnpushableTarget( parent );
				parent.SetUnpushableTarget(attackTarget);
			}
			parent.SetBehaviorVariable( 'combatActionType', (int)CAT_Attack );
			
			if ( parent.slideTarget )
				playerToTargetVec = parent.slideTarget.GetWorldPosition() - parent.GetWorldPosition();
			else
			{
				tempPos1 = parent.GetWorldPosition() + parent.GetHeadingVector() * 4;
				tempPos1.Z += 10.f;
				tempPos2 = tempPos1;
				tempPos2.Z -= 20.f;
				theGame.GetWorld().StaticTrace( tempPos1, tempPos2, noSlideTargetPos, noSlideTargetNormal );
				playerToTargetVec = parent.GetWorldPosition() - noSlideTargetPos;
			}			
			
			if( playerAttackType == theGame.params.ATTACK_NAME_LIGHT )
			{
				if (npc)
					npc.SignalGameplayEventParamInt('Time2Dodge', (int)EDT_Attack_Light );
			
				if ( parent.GetCurrentStateName() == 'CombatFists' )
				{
					if ( parent.slideTarget )
					{
						if ( !attackTarget || !parent.IsThreat(attackTarget) )
							comboPlayer.PlayAttack( 'AttackLightNoTarget' );
						else
						{
							/*if ( performApproachAttack )
								comboPlayer.PlayAttack( 'AttackLightFar' );
							else*/
								comboPlayer.PlayAttack( 'AttackLight' );
						}
					}
					else
						comboPlayer.PlayAttack( 'AttackLightNoTarget' );
				}
				else
				{	
					if ( npc && npc.IsUsingHorse() )
						comboPlayer.PlayAttack('AttackLightVsRider');
					else if  ( !parent.IsInShallowWater() && npc && ( npc.GetCurrentStance() == NS_Fly || npc.IsInAir() ) ) 
					{
						if ( playerToTargetVec.Z >= 0.f )
							comboPlayer.PlayAttack( 'AttackLightFlying' );
						else
							comboPlayer.PlayAttack( 'AttackLightSlopeDown' );
					}
					else
					{	
						if (attackTarget)
							targetCapsuleHeight = ((CMovingPhysicalAgentComponent)attackTarget.GetMovingAgentComponent()).GetCapsuleHeight();
						else
							targetCapsuleHeight = 0;
							
						playerToTargetRot = VecToRotation( playerToTargetVec );
						
						/*if ( attackTarget
							&& npcAttackTarget
							&& attackTarget.IsHuman()
							&& !parent.IsThreat(attackTarget) 
							&& VecLength( playerToTargetVec ) < parent.interactDist 
							&& AbsF( AngleDistance( VecHeading( attackTarget.GetWorldPosition() - parent.GetWorldPosition() ), parent.GetCombatActionHeading() ) ) < 90.f 
							) // FIXME: IsHorse check can be removed once there is no mount interaction on A button
							comboPlayer.PlayAttack( 'AttackNeutral' );
						else*/ if ( ( playerToTargetVec.Z > 0.4f && AbsF( playerToTargetRot.Pitch ) > 12.f ) || parent.IsInShallowWater() )
							comboPlayer.PlayAttack( 'AttackLightSlopeUp' );						
						else if ( playerToTargetVec.Z < -0.35f && AbsF( playerToTargetRot.Pitch ) > 12.f  )
							comboPlayer.PlayAttack( 'AttackLightSlopeDown' );
						/*else if ( performApproachAttack && !parent.IsEnemyInCone( parent, VecFromHeading( parent.rawPlayerHeading ), 8.f, 45.f, temp ) )
							comboPlayer.PlayAttack( 'AttackLightFar' );*/
						else if ( !parent.slideTarget )
							comboPlayer.PlayAttack( 'AttackLight' );
						else if ( targetCapsuleHeight < 1.5 )
							comboPlayer.PlayAttack( 'AttackLightCapsuleShort' );
						else
							comboPlayer.PlayAttack( 'AttackLight' );
					}
				}
				
				virtual_parent.OnCombatActionStart();
			}
			else if ( playerAttackType == theGame.params.ATTACK_NAME_HEAVY )
			{
				
				thePlayer.PlayBattleCry( 'BattleCryAttack', 0.1f );				
			
				if ( parent.GetCurrentStateName() == 'CombatFists' )
				{
					if ( parent.slideTarget )
					{
						if ( !attackTarget || !parent.IsThreat(attackTarget) )
							comboPlayer.PlayAttack( 'AttackHeavyNoTarget' );
						else
						{
							/*if ( performApproachAttack )
								comboPlayer.PlayAttack( 'AttackHeavyFar' );
							else*/
								comboPlayer.PlayAttack( 'AttackHeavy' );
						}
					}
					else
						comboPlayer.PlayAttack( 'AttackHeavyNoTarget' );
				}			
				else
				{
					if ( npc && npc.IsUsingHorse() )
						comboPlayer.PlayAttack('AttackHeavyVsRider');
					else if ( parent.slideTarget )
					{
						/*if ( attackTarget
							&& npcAttackTarget
							&& attackTarget.IsHuman()
							&& !parent.IsThreat(attackTarget) 
							&& VecLength( playerToTargetVec ) < parent.interactDist 
							&& AbsF( AngleDistance( VecHeading( attackTarget.GetWorldPosition() - parent.GetWorldPosition() ), parent.GetCombatActionHeading() ) ) < 90.f 
							) // FIXME: IsHorse check can be removed once there is no mount interaction on A button
							comboPlayer.PlayAttack( 'AttackNeutral' );
						else*/ if(npc && ( npc.GetCurrentStance() == NS_Fly || npc.IsInAir() ) ) 
							comboPlayer.PlayAttack( 'AttackHeavyFlying' );
						/*else if ( performApproachAttack )		
							comboPlayer.PlayAttack( 'AttackHeavyFar' );*/
						else
							comboPlayer.PlayAttack( 'AttackHeavy' );
					}
					else
					{
						/*if ( performApproachAttack )		
							comboPlayer.PlayAttack( 'AttackHeavyFar' );
						else*/
							comboPlayer.PlayAttack( 'AttackHeavy' );
					}
					
					witcher = (W3PlayerWitcher)parent;
					if(witcher)
					{
						witcher.ToggleSpecialAttackHeavyAllowed(true);
						parent.AddTimer( 'SpecialAttackHeavyAllowedTimer', 0.2 );
					}
				}
				
				virtual_parent.OnCombatActionStart();
			}
			else
				LogChannel( 'PlayerAttackType', "playerAttackType does not exist!" );	
		}	
	}

	timer function SpecialAttackHeavyAllowedTimer( time : float , id : int)
	{
		((W3PlayerWitcher)parent).ToggleSpecialAttackHeavyAllowed(false);
	}
	
	event OnInterruptAttack()
	{
		parent.RaiseEvent( 'AttackInterrupt' );
	}	


	var wasInCloseCombat : bool;
	// FIX THIS: REMOVE ANY FUNCTIONS BECAUSE OF MULTITHREADING!
	function OnComboAttackCallback( out callbackInfo : SComboAttackCallbackInfo )
	{
		var angle 						: float;
		var playerHeading 				: float;
		var playerToTargetHeading		: float;
		var playerToTargetAngleDiff		: float;
		var playerToTargetDist			: float;
		var farAttackMinDist			: float;
		var mediumAttackMinDist			: float;
		var enableCloseCombatRadius		: bool;
		var isHumanoid					: bool;
		var	maxAttackDist				: float;
		var actorTarget					: CActor;
		var isLightAttack				: bool;
		var attackTarget 				: CGameplayEntity;
		var playerToTargetVec			: Vector;
		var attackTargetActor			: CActor; 
		
		LogChannel( 'ComboNode', "inGlobalAttackCounter = " + callbackInfo.inGlobalAttackCounter + ", inStringAttackCounter = " + callbackInfo.inStringAttackCounter );	
		//LogChannel('HAInd',"OnComboAttackCallback start");
		
		callbackInfo.outShouldRotate = true;
		
		if (	callbackInfo.inAspectName == 'AttackLight' 
				|| callbackInfo.inAspectName == 'AttackLightNoTarget'
				|| callbackInfo.inAspectName == 'AttackLightCapsuleShort'
				|| callbackInfo.inAspectName == 'AttackLightFlying'
				|| callbackInfo.inAspectName == 'AttackLightSlopeDown'
				|| callbackInfo.inAspectName == 'AttackLightSlopeUp'
				|| callbackInfo.inAspectName == 'AttackLightVsRider'
				|| callbackInfo.inAspectName == 'AttackLightFar' )
		{
			isLightAttack = true;
		}
		else
			isLightAttack = false;
		
		playerToTargetVec = parent.slideTarget.GetWorldPosition() - parent.GetWorldPosition();
		
		if ( parent.slideTarget &&
			 enableSoftLock &&	
			 ( !( (CNewNPC)parent.slideTarget ) 
			 || ( ( (CActor)parent.slideTarget ).GetGameplayVisibility() 
					//&& parent.WasVisibleInScaledFrame( parent.slideTarget, 1.f, 1.f ) 
					&& ( ( (CNewNPC)(parent.slideTarget) ).GetCurrentStance() != NS_Fly || playerToTargetVec.Z < 2.5f || parent.IsActorLockedToTarget() ) ) ) )
		{		
			attackTarget = parent.slideTarget;
		
			//check if the slideTarget selected in the middle of the current attack is still within the softlock distance upon arrival at the final slidePos
			//If not, we should change target to the nearest target
			
			if ( parent.HasAbility('NoTransOnHitCheat') )
			{
				parent.SetHitReactTransScale( 0.0f );
			}
			else if ( parent.HasAbility('NoCloseCombatCheat') )
			{
				parent.SetHitReactTransScale( 1.f );
			}
			else
			{
				if ( isLightAttack && callbackInfo.inStringAttackCounter >= 2 && !( (CActor)parent.slideTarget ).IsGuarded() && !wasInCloseCombat )
					parent.SetHitReactTransScale( 0.5f );
				else
					parent.SetHitReactTransScale( 1.f );			
			}
		
			playerToTargetDist = GetPlayerToTargetDistance( true, parent.GetHitReactTransScale(), 0.2f );
			
			if ( !parent.GetBIsCombatActionAllowed() )
			{
				if ( playerToTargetDist > parent.softLockDist )
				{
					parent.EnableFindTarget( true );
					parent.SetSlideTarget( parent.GetTarget() );
					playerToTargetDist = GetPlayerToTargetDistance( true, parent.GetHitReactTransScale(), 0.2f );	
				}
			}	
			
			attackTargetActor = (CActor)parent.slideTarget;
			attackTargetActor.IsAttacked( true );
			
			if ( parent.GetPlayerCombatStance() == PCS_AlertNear || parent.GetPlayerCombatStance() == PCS_Guarded )
				callbackInfo.outRotateToEnemyAngle = VecHeading( parent.slideTarget.GetWorldPosition() - parent.GetWorldPosition() );
			else
				callbackInfo.outRotateToEnemyAngle = parent.GetCombatActionHeading();
			
			if ( (CActor)parent.slideTarget )
				callbackInfo.outSlideToPosition = ( (CActor)parent.slideTarget ).GetNearestPointInBothPersonalSpaces( parent.GetWorldPosition() );
			else
				callbackInfo.outSlideToPosition = parent.slideTarget.GetWorldPosition();
			
			playerToTargetAngleDiff = AngleDistance( callbackInfo.outRotateToEnemyAngle, parent.GetHeading() );		
			
			callbackInfo.outShouldTranslate = false;
			
			if ( parent.GetCurrentStateName() == 'CombatFists' )
			{
				farAttackMinDist =  2.f;
				mediumAttackMinDist = 0.75f;
			}
			else
			{
				farAttackMinDist =  2.5f;
				mediumAttackMinDist = 1.f;
			}
			
			enableCloseCombatRadius = false;
			
			actorTarget = ( CActor ) parent.slideTarget;
			if ( actorTarget && CalculateAttributeValue( actorTarget.GetAttributeValue( 'humanoid' ) ) > 0.f )
				isHumanoid = true; 
			else
				isHumanoid = false;
			
			if ( parent.GetIsSprinting() )
				callbackInfo.outDistance = ADIST_Large;
			else if ( playerToTargetDist > parent.softLockDist )
				callbackInfo.outDistance = ADIST_Medium;
			else if ( playerToTargetDist > farAttackMinDist )
				callbackInfo.outDistance = ADIST_Large;
			else if ( playerToTargetDist > mediumAttackMinDist )
				callbackInfo.outDistance = ADIST_Medium;
			else
				callbackInfo.outDistance = ADIST_Medium;			
				
			if ( parent.slideTarget && (CActor)parent.slideTarget )
			{
				if ( ( (CActor)( parent.slideTarget ) ).IsCurrentlyDodging() )
					callbackInfo.outDistance = ADIST_Medium;

				if ( GetAttitudeBetween( parent, parent.slideTarget ) != AIA_Hostile )
					callbackInfo.outDistance = ADIST_Medium;
			}
			
			if ( callbackInfo.inAspectName == 'AttackNeutral' )
			{
				if ( playerToTargetDist > 1.f || parent.HasAbility('NoCloseCombatCheat') )
					callbackInfo.outDistance = ADIST_Medium;
				else
					callbackInfo.outDistance = ADIST_Small;
			}
			
				
			if ( callbackInfo.outDistance != ADIST_Small || callbackInfo.inAspectName == 'AttackHeavy' )
				wasInCloseCombat = false;
			else
				wasInCloseCombat = true;
		}
		else
		{
			callbackInfo.outShouldTranslate = false;
			callbackInfo.outSlideToPosition = parent.GetWorldPosition() + VecFromHeading( parent.GetCombatActionHeading() );
			
			callbackInfo.outRotateToEnemyAngle = parent.GetCombatActionHeading();
								
			playerToTargetAngleDiff = AngleDistance( callbackInfo.outRotateToEnemyAngle , VecHeading( parent.GetHeadingVector() ) );

			if ( parent.GetIsSprinting() )
				callbackInfo.outDistance = ADIST_Large;
			else
				callbackInfo.outDistance = ADIST_Medium;
		}
		
		if ( playerToTargetAngleDiff < -135.f )
			callbackInfo.outDirection = AD_Back;
		else if ( playerToTargetAngleDiff < -45.f )
			callbackInfo.outDirection = AD_Right;
		else if ( playerToTargetAngleDiff > 135.f )
			callbackInfo.outDirection = AD_Back;
		else if ( playerToTargetAngleDiff > 45.f )
			callbackInfo.outDirection = AD_Left;	
		else
			callbackInfo.outDirection = AD_Front;
		
		if ( callbackInfo.inStringAttackCounter == 0 || callbackInfo.inGlobalAttackCounter == 0 )
			parent.SetBIsFirstAttackInCombo(true);
		else if ( callbackInfo.inStringAttackCounter >= 2 )//&& callbackInfo.outDirection == AD_Front )
			parent.SetBIsFirstAttackInCombo(false);
		//else if ( callbackInfo.outDirection != AD_Front )
		//	parent.SetBIsFirstAttackInCombo(true);
		
		//if ( parent.slideTarget && playerToTargetDist < 0.5f )
		//	callbackInfo.outDirection = AD_Front;
			
		if ( callbackInfo.inAspectName == 'AttackNeutral' )
			callbackInfo.outDirection = AD_Front;
		
		if ( callbackInfo.inAspectName == 'AttackNeutral' )
			callbackInfo.outAttackType = ComboAT_Normal;
		else if( ( callbackInfo.inStringAttackCounter == 0 || AbsF(playerToTargetAngleDiff) >= 45.f || playerToTargetDist > farAttackMinDist || !parent.slideTarget )  )
		{
			callbackInfo.outAttackType = ComboAT_Directional;
			callbackInfo.outShouldTranslate = true;
		}
		else
			callbackInfo.outAttackType = ComboAT_Normal;
		
		if ( callbackInfo.outShouldTranslate )
		{
			MarkSlidePosition( callbackInfo.outSlideToPosition );
		}
		
		if ( parent.GetBehaviorVariable( 'combatIdleStance' ) > 0.8 )
			callbackInfo.outLeftString = false;
		else
			callbackInfo.outLeftString = true;
		
		if ( callbackInfo.inAspectName == 'AttackHeavy' )
			parent.SetBehaviorVariable( 'playerAttackType', (int)PAT_Heavy );
		else
		{
			parent.SetBehaviorVariable( 'playerAttackType', (int)PAT_Light );
		}
		
		parent.EnableCloseCombatCharacterRadius( enableCloseCombatRadius );
		CacheComboAttack( callbackInfo.inAttackId, attackTarget, callbackInfo.outShouldTranslate, callbackInfo.inAspectName );
	}
	
	private function GetMaxAttackDist() : float
	{
		var maxAttackDist	: float;
	
		if ( parent.approachAttack == 0 )
			maxAttackDist = 0.f;	
		else if ( parent.approachAttack == 2 )
			maxAttackDist = 7.f;
		else
			maxAttackDist = 4.f;

		return maxAttackDist;
	}
	
	private function GetPlayerToTargetDistance( getPredictedDistance : bool, translationScale : float,  optional customTime : float  ) : float
	{
		var predictionTime					: float;
		var targetCapsuleRadius				: float;
		var nearestPoint					: Vector;
		var nearestPointNoPredict			: Vector;
		var predictedPos					: Vector;
		var currentPos						: Vector;
		var scaledCurrToPredictedVector		: Vector;
		var capsuleOffsetVec				: Vector;
		var dist							: float;
		var distPredict						: float;
		var slideTargetNPC					: CNewNPC;
		
		if ( (CActor)(parent.slideTarget) )
			targetCapsuleRadius = ((CMovingPhysicalAgentComponent)( (CActor)(parent.slideTarget) ).GetMovingAgentComponent()).GetCapsuleRadius();
		
		if ( customTime > 0.f )
			predictionTime = customTime;
		else 
			predictionTime = 0.8f;
			
		if ( getPredictedDistance && ( (CActor)(parent.slideTarget) ) && !parent.slideTarget.IsRagdolled() )
		{
			currentPos = parent.slideTarget.GetWorldPosition();
			predictedPos = ( (CActor)(parent.slideTarget) ).PredictWorldPosition( predictionTime );
			scaledCurrToPredictedVector = ( predictedPos - currentPos ) * translationScale;
			predictedPos = currentPos + scaledCurrToPredictedVector;
			capsuleOffsetVec = targetCapsuleRadius * VecNormalize( parent.GetWorldPosition() - parent.slideTarget.GetWorldPosition() );
			nearestPoint = predictedPos + capsuleOffsetVec;	
		}
		else
			nearestPoint = parent.slideTarget.GetWorldPosition() + targetCapsuleRadius * VecNormalize( parent.GetWorldPosition() - parent.slideTarget.GetWorldPosition() );

		nearestPointNoPredict = parent.slideTarget.GetWorldPosition() + capsuleOffsetVec;
		distPredict = VecDistance( parent.GetWorldPosition(), nearestPoint );
		dist = VecDistance( parent.GetWorldPosition(), nearestPointNoPredict );
		
		if ( distPredict > dist )
		{
			parent.GetVisualDebug().AddSphere('playerToTargetDist', 0.25, nearestPoint, true, Color(128,128,128), 3.0f );
			return distPredict;
		}
		else
		{
			slideTargetNPC = (CNewNPC)( parent.slideTarget );
			if ( slideTargetNPC && slideTargetNPC.IsAttacking() && slideTargetNPC.GetTarget() == parent )
			{
				parent.GetVisualDebug().AddSphere('playerToTargetDist', 0.25, nearestPoint, true, Color(128,128,128), 3.0f );
				return distPredict;
			}
			else
			{
				parent.GetVisualDebug().AddSphere('playerToTargetDist', 0.25, nearestPointNoPredict, true, Color(128,128,128), 3.0f );
				return dist;
			}
		}
	}

	timer function CombatComboUpdate( timeDelta : float , id : int)
	{
		var stateName : name;
		
		InteralCombatComboUpdate( timeDelta );
		
		if( thePlayer.IsInCombatAction_Attack() && !thePlayer.IsInCombatActionFriendly() )
		{
			thePlayer.ProcessWeaponCollision();
		}
	}
	
	
	protected final function InteralCombatComboUpdate( timeDelta : float )
	{
		var slidePosition : Vector;
		var slideRotationVector : Vector;
		var slideRotation : float;
		var targetNearestPoint : Vector;
		var playerToTargetDist : float;
		var playerRadius : float;
		
		var heading : float;
		
		if ( comboAttackA_Target )
		{
			//parent.GetVisualDebug().AddSphere('slideTargetPos', 1.0f, comboAttackA_Target.GetWorldPosition() + Vector(0,0,1), true, Color(128,128,128), 3.0f );
			if ( (CActor)comboAttackA_Target )
				playerToTargetDist =  VecDistance( parent.GetWorldPosition(), ( (CActor)comboAttackA_Target ).GetNearestPointInBothPersonalSpaces( parent.GetWorldPosition() ) );
			else
				playerToTargetDist =  VecDistance( parent.GetWorldPosition(), comboAttackA_Target.GetWorldPosition() );
			
			if ( !((CActor)comboAttackA_Target).GetGameplayVisibility() )
				updatePosition = false;
			
			if ( ( parent.GetOrientationTarget() == OT_Camera || parent.GetOrientationTarget() == OT_CameraOffset ) && playerToTargetDist > 1.5f )
				updatePosition = false;
	
			//if ( comboAspectName != 'AttackNeutral' && parent.moveTarget && !parent.IsThreat( parent.moveTarget ) && comboAttackA_Target && VecDistance( comboAttackA_Target.GetWorldPosition(), parent.GetWorldPosition() ) > parent.interactDist )
			//	updatePosition = false;
			
			if ( parent.moveTarget && !parent.IsThreat( parent.moveTarget ) && comboAttackA_Target )
			{
				if ( VecDistance( comboAttackA_Target.GetWorldPosition(), parent.GetWorldPosition() ) > parent.interactDist 
					|| AbsF( AngleDistance( parent.GetCombatActionHeading(), VecHeading( comboAttackA_Target.GetWorldPosition() - parent.GetWorldPosition() ) ) ) > 90.f )
					updatePosition = false;
			}

			if ( updatePosition && comboAttackA_Id != -1 )
			{
				if ( (CActor)comboAttackA_Target )
					targetNearestPoint = ( (CActor)comboAttackA_Target ).GetNearestPointInPersonalSpace( parent.GetWorldPosition() ) ;
				else 
					targetNearestPoint = comboAttackA_Target.GetWorldPosition();
				playerRadius = ((CMovingPhysicalAgentComponent)(parent).GetMovingAgentComponent()).GetCapsuleRadius();
				slidePosition = playerRadius * VecNormalize( parent.GetWorldPosition() - comboAttackA_Target.GetWorldPosition() ) + targetNearestPoint;
				slideRotationVector = comboAttackA_Target.GetWorldPosition() - parent.GetWorldPosition();
				slideRotation = VecHeading( slideRotationVector );
				comboPlayer.UpdateTarget( comboAttackA_Id, slidePosition, slideRotation, true, true );
				
				if ( comboAttackA_Sliding )
				{
					MarkSlidePosition( slidePosition );
				}
			}
			
			if ( !updatePosition && comboAttackA_Id != -1 )
				comboPlayer.UpdateTarget( comboAttackA_Id, parent.GetWorldPosition() + VecFromHeading( parent.GetCombatActionHeading() ), parent.GetCombatActionHeading(), true, true );
		}
		else if ( comboAttackA_Id != -1 && parent.IsInCombatAction() && parent.GetBehaviorVariable( 'combatActionType' ) == 0.f )
		{
			comboPlayer.UpdateTarget( comboAttackA_Id, parent.GetWorldPosition() + VecFromHeading( parent.GetCombatActionHeading() ), parent.GetCombatActionHeading(), true, true );
			//parent.GetVisualDebug().AddSphere('slideTargetPos', 1.0f, parent.GetWorldPosition() + Vector(0,0,1), true, Color(128,128,128), 3.0f );
		}
			
		if(comboPlayer)
			comboPlayer.Update( timeDelta );
	}	
	
	private final function MarkSlidePosition( position : Vector )
	{
		parent.GetVisualDebug().AddSphere('slidePos', 0.5f, position, true, Color(255,0,255), 5.0f );
	}
	
	public final function ResetComboPlayerAndGoToIdle()
	{
		comboPlayer.Deinit();
		parent.GetRootAnimatedComponent().RaiseBehaviorForceEvent( 'ToIdle' );
	}

	private var ticketRequests : array<int>;
	private var ticketNames : array<name>;
	
	private function BlockAllCombatTickets( block : bool )
	{
		var combatData : CCombatDataComponent;
		var tmpTicketRequest : int;
		var i : int;
		
		combatData = parent.GetCombatDataComponent();
		
		if ( ticketNames.Size() <= 0 )
			InitTicketNames();
		
		ReleaseTicketRequests();
		
		if ( block )
		{
			for ( i=0; i<ticketNames.Size(); i+=1 )
			{
				tmpTicketRequest = combatData.TicketSourceOverrideRequest( ticketNames[i], 0, 10000000.0 );
				ticketRequests.PushBack(tmpTicketRequest);
			}
			ForceTicketUpdate();
		}
	}
	
	private function ReleaseTicketRequests()
	{
		var i : int;
		var combatData : CCombatDataComponent;
		
		combatData = parent.GetCombatDataComponent();
		
		for ( i=0; i<ticketRequests.Size(); i+=1 )
		{
			combatData.TicketSourceClearRequest( ticketNames[i], ticketRequests[i] );
		}
		ticketRequests.Clear();
	}
	
	private function ForceTicketUpdate()
	{
		var i : int;
		var combatData : CCombatDataComponent;
		
		combatData = parent.GetCombatDataComponent();
		
		for ( i=0; i<ticketRequests.Size(); i+=1 )
		{
			combatData.ForceTicketImmediateImportanceUpdate( ticketNames[i]);
		}
	}
	
	private function InitTicketNames()
	{
		ticketNames.PushBack('TICKET_Melee');
		ticketNames.PushBack('TICKET_Range');
		ticketNames.PushBack('TICKET_Special');
		ticketNames.PushBack('TICKET_Charge');
	}
	
	event OnBlockAllCombatTickets( block : bool )
	{
		BlockAllCombatTickets( block );
	}
	
	event OnForceTicketUpdate()
	{
		ForceTicketUpdate();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Combat Events
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	event OnCombatActionEndComplete()
	{
		parent.EnableCloseCombatCharacterRadius( false );
		parent.OnCombatActionEndComplete();
		parent.SetBIsFirstAttackInCombo(false);
	}
}
