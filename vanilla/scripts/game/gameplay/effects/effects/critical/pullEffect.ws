/*
Copyright © CD Projekt RED 2015
*/




class W3Effect_Pull extends W3ImmobilizeEffect
{
	default effectType = EET_Pull;
	default resistStat = CDS_None;
	default criticalStateType = ECST_Pull;
	default isDestroyedOnInterrupt = true;
	default postponeHandling = ECH_Abort;
	default airHandling = ECH_Abort;	
	default usesFullBodyAnim			= true;
	
	private var movementAdjustor	: CMovementAdjustor;	
	private var ticket 				: SMovementAdjustmentRequestTicket;
	
	public function CacheSettings()
	{
		super.CacheSettings();
				
		blockedActions.PushBack(EIAB_Dodge);
		blockedActions.PushBack(EIAB_Roll);
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var player : CR4Player = thePlayer;
		var headingVector		: Vector;
		
		super.OnEffectAdded(customParams);
		
		target.PlayEffectSingle('web');
		
		if ( this.isOnPlayer )
		{
			
			
			
			
			
			
			
			if(GetCreator())
				headingVector = GetCreator().GetWorldPosition() - target.GetWorldPosition();
			else
				headingVector = target.GetHeadingVector();
			
			movementAdjustor = target.GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelAll();
			ticket = movementAdjustor.CreateNewRequest( 'EffectPull' );
			movementAdjustor.Continuous( ticket );
			movementAdjustor.ReplaceRotation( ticket );
			movementAdjustor.RotateTo( ticket, VecHeading(headingVector) );
			movementAdjustor.RotateTowards(ticket, GetCreator());
			movementAdjustor.MaxRotationAdjustmentSpeed( ticket, 2160 );
			movementAdjustor.MaxLocationAdjustmentSpeed( ticket, 5 );
			movementAdjustor.KeepActiveFor( ticket, this.duration );
			movementAdjustor.SlideTowards(ticket,GetCreator(),2,3);
			movementAdjustor.NotifyScript(ticket,this,'OnSlideFinish',MAN_LocationAdjustmentReachedDestination);
		}
	}
	
	event OnEffectRemoved()
	{
		target.StopEffect('web');
		
		
		
			
		target.SetBehaviorVariable( 'bCriticalStopped', 1 );
		
		movementAdjustor.Cancel( ticket );
		
		super.OnEffectRemoved();
	}
	
	event OnSlideFinish( requestName : CName, notify : EMovementAdjustmentNotify )
	{
		var actor : CActor;
		
		actor = (CActor)GetCreator();
		if(actor)
			actor.SignalGameplayEvent('SlideFinish');
			
		timeLeft = 0;
		
	}	
}