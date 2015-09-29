/*
Copyright © CD Projekt RED 2015
*/





struct ErrandDetailsList
{
	editable saved var errandStringKey	: string;	
	editable saved var newQuestFact		: string;
	editable saved var requiredFact		: string;
	editable saved var forbiddenFact	: string;
	editable saved var addedItemName	: name;
	var posX	: int;
	var posY	: int;
		
	var errandPosition : int;
	default errandPosition = 0;
}

enum AQMTN_EntityType
{
	AQMTN_Actor,
	AQMTN_NonActor,	
}

statemachine class W3NoticeBoard extends CR4MapPinEntity
{
	editable saved var visited : bool;						default visited = false;
	editable saved var addedNotes		: array< ErrandDetailsList >;
	editable saved var fluffNotices : array < string >;
	editable var entitiesToBeShown : array < name >;
	editable saved var questEntitiesToBeShown : array < name >;
	editable saved var questNonActorEntitiesToBeShown : array < name >;
	editable var InteractionSpawnDelayTime		: float;		default InteractionSpawnDelayTime = 1.0f;	
	editable var backgroundOverride : string;
	editable var factAddedOnDiscovery : name;
	
	var activeErrands 			: array< ErrandDetailsList >;
	var updatingInteraction		: bool;							default updatingInteraction		= false;
	var errandPositionName		: string;						default errandPositionName = "errand_card_0";
	var MAX_DISPLAYED_ERRANDS	: int;							default MAX_DISPLAYED_ERRANDS = 6;	
	var lastTimeInteracted 		: GameTime;
	
	protected optional autobind 	interactionComponent 	: CInteractionComponent = "LookAtBoard";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		updatingInteraction = false;
		
		FixNamesAndTags();
		
		FixErrands();
		
		UpdateBoard();
		
		SetCardsVisible(true);
		
		SetFocusModeVisibility( FMV_Interactive );
	}
	
	function FixNamesAndTags()
	{
		if ( HasTag( 'harbor_district_noticeboard' ) )
		{
			if ( HasTag( 'market_noticeboard' ) )
			{
				RemoveTag( 'market_noticeboard' );
			}
		}
		
		if ( HasTag( 'poppystone_notice_board' ) )
		{
			if ( HasTag( 'inn_crossroads_notice_board' ) )
			{
				RemoveTag( 'inn_crossroads_notice_board' );
			}
		}
	}
	
	function WasVisited() : bool
	{
		return visited;
	}
	
	function FixErrands()
	{
		var i : int;
		for( i = addedNotes.Size() - 1; i > -1 ; i -= 1 )
		{
			if( addedNotes[i].errandStringKey == "" )
			{
				addedNotes.Erase(i);
			}
		}
	}
	
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if(activator == thePlayer && ShouldProcessTutorial('TutorialQuestBoard'))
		{
			FactsAdd("tut_near_noticeboard");
		}
	}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		if(activator == thePlayer && ShouldProcessTutorial('TutorialQuestBoard'))
		{
			FactsSet("tut_near_noticeboard", 0);
		}
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if ( interactionComponentName == "LookAtBoard" )
		{
			if( IsEmpty(true) )
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		return false;
	}
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		var vect : Vector;
		var tags : array< name >;
		
		if ( activator.GetEntity() == thePlayer )
		{
			if( area == (CTriggerAreaComponent)this.GetComponent( "FirstDiscoveryTrigger" ) )
			{
				this.GetComponent( "FirstDiscoveryTrigger" ).SetEnabled( false );			
				mapManager.SetEntityMapPinDiscoveredScript(false, entityName, true );
			}
			else if( area == (CTriggerAreaComponent)this.GetComponent( "UpdateNoticeBoard" ) )
			{
				UpdateBoard(true);
			}
			UpdateInteraction( true );
		}
	}	

	function UpdateInteraction( optional waitForComponent : bool )
	{
		if ( interactionComponent )
		{
			if ( updatingInteraction )
			{
				updatingInteraction = false;
				RemoveTimer( 'EnableInteractionComponentDelayed' );
				
			}
			if ( IsEmpty(true))
			{
				interactionComponent.SetEnabled( false );
			}
			else
			{
				interactionComponent.SetEnabled( true );
			}
		}
		else if ( waitForComponent && !updatingInteraction )
		{
			updatingInteraction = true;
			AddTimer( 'EnableInteractionComponentDelayed', InteractionSpawnDelayTime, false );
		}	
	}
	
	private timer function EnableInteractionComponentDelayed( delta : float , id : int)
	{
		updatingInteraction = false;
		UpdateInteraction( true );
	}	

	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{		
		var currentGameTime : GameTime;
		currentGameTime = theGame.GetGameTime();

		if ( activator.GetEntity() == thePlayer )
		{
			if( area == (CTriggerAreaComponent)this.GetComponent( "UpdateNoticeBoard" ) )
			{
				if( fluffNotices.Size() == 0 && Have24HoursPassed(currentGameTime, lastTimeInteracted) )
				{
					ResetFlawErrands(); 
				}
				UpdateBoard();
			}
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if( activator == (CEntity)thePlayer )
		{
			if ( !visited )
			{
				visited = true;
				theGame.GetCommonMapManager().InvalidateStaticMapPin( entityName );
			}
			AddDiscoveredFact();
			SetEntitiesKnown();
			UpdateBoard(true);
			theGame.RequestMenu( 'NoticeBoardMenu', this );
			lastTimeInteracted = theGame.GetGameTime();
		}
	}
	
	private function AddDiscoveredFact()
	{
		if( !FactsDoesExist( factAddedOnDiscovery ) )
		{
			FactsAdd( factAddedOnDiscovery, 1, -1 );
		}
	}
	
	private function SetEntitiesKnown()
	{
		var i : int;
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		var count : int;
		
		if ( !mapManager )
		{
			return;
		}
				
		for ( i = 0; i < entitiesToBeShown.Size(); i += 1 )
		{
			if ( !mapManager.IsEntityMapPinKnown( entitiesToBeShown[ i ] ) )
			{
				mapManager.SetEntityMapPinKnown( entitiesToBeShown[ i ], true );
				count += 1;
			}
		}
		if ( count > 0 && mapManager.CanShowKnownEntities() )
		{
			mapManager.UpdateHud('notdiscoveredpoi');
		}
	}
	
	function CanAddErrand( candidateToAdd : ErrandDetailsList ) : bool
	{
		var i : int;
		
		for( i = 0; i < addedNotes.Size(); i += 1 )
		{
			if( candidateToAdd.errandStringKey == addedNotes[i].errandStringKey )
			{
				
				return false;
			}		
		}
		return true;
	}
	
	function AddErrand( newErrand : ErrandDetailsList )
	{
		var i : int;
		
		if( CanAddErrand( newErrand ) )
		{
			addedNotes.Insert( 0, newErrand );
		}
		else
		{
			LogChannel( 'NoticeBoardDebug', "The errand "+newErrand.errandStringKey+" was added before!" );
		}
		
		theGame.GetCommonMapManager().InvalidateStaticMapPin( entityName );
	}

	function SetCardsVisible( optional bSilent : bool )
	{
		var errandPos : name;
		var i : int;
		var length : int;
		var card : CDrawableComponent;
		var tempErrand : ErrandDetailsList;
		var bOverrideFlaw : bool;
			
		length = 0;
		
		activeErrands.Clear();
		activeErrands.Grow( MAX_DISPLAYED_ERRANDS );
		HideAllCards();
		
		for( i = 0; i < addedNotes.Size(); i += 1 )
		{
			bOverrideFlaw = false;
			if ( CheckFact(addedNotes[i].newQuestFact, true ) )
			{
				addedNotes[ i ].errandPosition = -1;
				continue;
			}
			if ( CheckFact(addedNotes[i].forbiddenFact, false ) && CheckFact( addedNotes[i].requiredFact, true ) ) 
			{	
				switch( addedNotes[i].errandPosition )
				{
					case -1 :
						continue;
					case 0 : 
						if( addedNotes[i].errandStringKey != "flaw" )
						{
							bOverrideFlaw = true;
						}
						addedNotes[i].errandPosition = GetFirstFreeErrandSlot(bOverrideFlaw);
						if( addedNotes[i].errandPosition == 0 )
						{
							break;
						}
					default :
						if(addedNotes[i].posX == 0 || addedNotes[i].posY == 0)
						{
							addedNotes[i].posX = RandRange( 25, -25 );
							addedNotes[i].posY = RandRange( 30, -30 );
						}
						length += 1;
						activeErrands[addedNotes[i].errandPosition - 1] = addedNotes[i];
						card = (CDrawableComponent)this.GetComponent( errandPositionName + activeErrands[addedNotes[i].errandPosition - 1].errandPosition );
						card.SetVisible( true );
						break;
				}
			}
			if( length >= MAX_DISPLAYED_ERRANDS )
			{
				return;
			}
		}
		
		for( i = length; i < MAX_DISPLAYED_ERRANDS; i += 1 )
		{
			if( !bSilent )
			{
				tempErrand.errandStringKey = GetRandomFlawErrand();
			}
			if( tempErrand.errandStringKey != "" )
			{
				tempErrand.newQuestFact = "flaw";
				tempErrand.errandPosition = GetFirstFreeErrandSlot();
				addedNotes[i].posX = RandRange( 25, -25 );
				addedNotes[i].posY = RandRange( 30, -30 );
				card = (CDrawableComponent)this.GetComponent(  errandPositionName + tempErrand.errandPosition );
				card.SetVisible( true );					
				addedNotes.PushBack(tempErrand);
				activeErrands[tempErrand.errandPosition - 1] = addedNotes[i];
			}
		}
	}
	
	function HideAllCards()
	{
		var card : CDrawableComponent;
		var i : int;
		for( i = 0; i < MAX_DISPLAYED_ERRANDS; i += 1 )
		{
			card = (CDrawableComponent)this.GetComponent(  errandPositionName + (i+1) );
			card.SetVisible( false );	
		}
	}
	
	function GetFirstFreeErrandSlot( optional bOverrideFlaw : bool ) : int
	{
		var i : int;
		var j : int;
		
		for( i = 0; i < activeErrands.Size(); i += 1 )
		{
			if( activeErrands[i].errandStringKey == "" )
			{
				for( j = 0; j < addedNotes.Size(); j += 1 )
				{
					if( addedNotes[j].errandPosition > -1 && addedNotes[j].errandPosition == (i + 1) && CheckFact(addedNotes[j].forbiddenFact, false ) && CheckFact( addedNotes[j].requiredFact, true ) )
					{
						break;
					}
				}
				if( j == addedNotes.Size() ) 
				{
					return i + 1;
				}
			}
		}
		if( bOverrideFlaw )
		{
			return RemoveFlawErrand();
		}
		LogChannel('BOARD_ERROR'," GetFirstFreeErrandSlot failed ");
		return 0;
	}
	
		
	function RemoveEmptyActiveErrands() : void
	{
		var i : int;

		
		for( i = activeErrands.Size() -1; i > -1 ; i -= 1 )
		{
			if( activeErrands[i].errandStringKey == "" )
			{
				activeErrands.Erase(i);
			}
		}

	}
	
	function GetRandomFlawErrand() : string
	{
		var randIDX : int;
		var retString : string;
		
		if( fluffNotices.Size() == 0 ) 
		{
			return "";
		}
		
		randIDX = RandRange(fluffNotices.Size());
		
		retString = fluffNotices[randIDX];
		fluffNotices.Erase(randIDX);
		
		return retString;
	}
	
	function ResetFlawErrands()
	{
		var i : int;
		
		for( i = addedNotes.Size() -1; i > -1; i -= 1 )
		{
			if( addedNotes[i].newQuestFact == "flaw" )
			{
				if( addedNotes[i].errandPosition == -1 )
				{
					fluffNotices.PushBack( addedNotes[i].errandStringKey );
					addedNotes.Remove( addedNotes[i] );
				}
			}
		}
	}
	
	function RemoveFlawErrand() : int
	{
		var i : int;
		var ret : int;
		
		for( i = addedNotes.Size() -1; i > -1; i -= 1 )
		{
			if( addedNotes[i].newQuestFact == "flaw" )
			{
				if( addedNotes[i].errandPosition > 0 )
				{
					ret = addedNotes[i].errandPosition;
					fluffNotices.PushBack( addedNotes[i].errandStringKey );
					addedNotes.Remove( addedNotes[i] );
					return ret;
				}
			}
		}
		return 0;
	}
	
	function CheckFact( factName : string, forbidden : bool ) : bool
	{
		if( factName != "" )
		{
			return ( FactsDoesExist( factName ) == forbidden );
		}
		return true;
	}
	
	function UpdateBoard( optional bSilent : bool )
	{
		SetCardsVisible(bSilent);
		CheckIfEmpty();
	}
	
	function CheckIfEmpty()
	{
		var val : int;
		var exp : int;
		var tags : array<name>;
		
		if( HasAnyNote() )
		{
			val = 1;
			exp = -1;
			tags = GetTags();
			FactsAdd(tags[0]+"_empty", val, exp);
			LogChannel('NoticeBoard',"isEmpty "+tags[0]);
		}
	}
	
	public function IsEmpty( checkFluff : bool ) : bool
	{
		if( HasAnyNote() )
		{
			return false;
		}
		if( checkFluff && fluffNotices.Size() > 0 )
		{
			return false;
		}
		return true;
	}
	
	function HasAnyQuest() : bool 
	{
		var i : int;
		
		for( i = 0; i < activeErrands.Size(); i += 1 )
		{
			if( activeErrands[i].errandPosition > 0 && activeErrands[ i ].newQuestFact != "flaw"  )
			{
				return true;
			}
		}
		return false;
	}
	
	function HasAnyNote() : bool 
	{
		var i : int;
		
		for( i = 0; i < activeErrands.Size(); i += 1 )
		{
			if( activeErrands[i].errandPosition > 0 )
			{
				return true;
			}
		}
		return false;
	}
	
	public function RemoveQuest( errandName : string ) : bool
	{
		var i : int;
		var stillDisplayed : int;
		var card: CDrawableComponent;
		
		stillDisplayed = 0;
		for ( i = 0; i < addedNotes.Size(); i += 1 )
		{
			if ( addedNotes[ i ].errandStringKey == errandName )
			{
				card = (CDrawableComponent)this.GetComponent( errandPositionName + addedNotes[i].errandPosition );
				card.SetVisible( false );
				addedNotes [ i ].errandPosition = -1;
			}
			
		}
		for( i = activeErrands.Size() - 1; i > -1; i -= 1 )
		{
			if ( activeErrands[ i ].errandStringKey == errandName )
			{
				activeErrands.Erase(i);
				continue;
			}
			if( activeErrands[ i ].errandPosition > 0 )
			{
				stillDisplayed += 1;
			}
		}
		
		theGame.GetCommonMapManager().InvalidateStaticMapPin( entityName );

		if( stillDisplayed == 0 )
		{
			if( interactionComponent )
			{
				interactionComponent.SetEnabled(false);
			}
			return true;
		}
		return false;
	}
	
	public function AddQuestMappin( entityTag : name, entityType : AQMTN_EntityType )
	{	
		if( entityType == AQMTN_Actor )
		{
			ArrayOfNamesPushBackUnique( questEntitiesToBeShown, entityTag );
		}
		else
		{
			ArrayOfNamesPushBackUnique( questNonActorEntitiesToBeShown, entityTag );
		}
	}
	
	function AcceptNewQuest( errandName : string ) : bool
	{	
		var i : int;
		var stillDisplayed : int;
		var card : CDrawableComponent;
		
		stillDisplayed = 0;
		for ( i = 0; i < addedNotes.Size(); i += 1 )
		{
			if ( addedNotes[ i ].errandStringKey == errandName )
			{
				if( addedNotes[ i ].newQuestFact != "flaw" )
				{
					FactsAdd( addedNotes[ i ].newQuestFact );
				}
					
				if( addedNotes[ i ].addedItemName )
				{
					GetWitcherPlayer().GetInventory().AddAnItem(addedNotes[ i ].addedItemName , 1, false);
				}
				
				card = (CDrawableComponent)this.GetComponent( errandPositionName + addedNotes[i].errandPosition );
				card.SetVisible( false );
				addedNotes[ i ].errandPosition = -1;
			}
		}
		
		for( i = activeErrands.Size() - 1; i > -1; i -= 1 )
		{
			if ( activeErrands[ i ].errandStringKey == errandName )
			{
				activeErrands.Erase(i);
				continue;
			}
			if( activeErrands[ i ].errandPosition > 0 )
			{
				stillDisplayed += 1;
			}
		}
		
		theGame.GetCommonMapManager().InvalidateStaticMapPin( entityName );
		
		if( stillDisplayed == 0 )
		{
			if( interactionComponent )
			{
				interactionComponent.SetEnabled(false);
			}
			return true;
		}
		return false;
	}
	
	
	function  GetStaticMapPinType( out type : name )
	{
		if ( !visited || HasAnyQuest() )
		{
			type = 'NoticeBoardFull';
		}
		else
		{
			type = 'NoticeBoard';
		}
	}
}