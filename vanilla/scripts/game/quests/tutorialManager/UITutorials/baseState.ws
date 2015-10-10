/***********************************************************************/
/** Copyright © 2014-2015
/** Author : Tomek Kozera
/***********************************************************************/

state TutHandlerBaseState in W3TutorialManagerUIHandler
{
	protected var defaultTutorialMessage : STutorialMessage;
	private var currentlyShownHint : name;
	
	event OnEnterState(prevStateName : name)
	{	
		//Set defaults for tutorial message. Child classes can then copy & use easier
		defaultTutorialMessage.type = ETMT_Hint;
		defaultTutorialMessage.forceToQueueFront = true;
		defaultTutorialMessage.canBeShownInMenus = true;
		defaultTutorialMessage.canBeShownInDialogs = true;
		defaultTutorialMessage.hintPositionType = ETHPT_DefaultUI;
		defaultTutorialMessage.disableHorizontalResize = true;
	}
	
	event OnLeaveState( nextStateName : name )
	{
		//when leaving state unregister this tutorial
		theGame.GetTutorialSystem().uiHandler.UnregisterUIHint(GetStateName());
	}
	
	protected final function QuitState()
	{
		var entersNew : bool;
		
		//do nothing if this state is not current state
		if(this != theGame.GetTutorialSystem().uiHandler.GetCurrentState())
			return;
		
		//when leaving state unregister this tutorial
		entersNew = theGame.GetTutorialSystem().uiHandler.UnregisterUIHint(GetStateName());
		
		//go to default state if not entering new state
		if(!entersNew)
			virtual_parent.GotoState('Tutorial_Idle');
	}
	
	protected final function CloseHint(n : name)
	{
		theGame.GetTutorialSystem().HideTutorialHint(n);
		
		currentlyShownHint = '';
	}
	
	protected final function IsCurrentHint(h : name) : bool
	{
		return currentlyShownHint == h;
	}
	
	protected final function ShowHint(tutorialScriptName : name, optional x : float, optional y : float, optional durationType : ETutorialHintDurationType, optional highlights : array<STutorialHighlight>, optional fullscreen : bool, optional isHudTutorial : bool)
	{
		var tut : STutorialMessage;
	
		tut = defaultTutorialMessage;
		tut.tutorialScriptTag = tutorialScriptName;		
		tut.highlightAreas = highlights;
		tut.forceToQueueFront = true;	//all should force because if there is something in the queue it will take priority but will never fire since OnTick won't work as the game is paused
		tut.canBeShownInMenus = true;
		tut.isHUDTutorial = isHudTutorial;
		tut.disableHorizontalResize = true;
		
		if(x != 0 || y != 0)
		{			
			tut.hintPositionType = ETHPT_Custom;
		}
		else
		{
			tut.hintPositionType = ETHPT_DefaultGlobal;
		}
		
		tut.hintPosX = x;
		tut.hintPosY = y;
		
		if(durationType == ETHDT_NotSet)
			tut.hintDurationType = ETHDT_Input;
		else
			tut.hintDurationType = durationType;
		
		if(fullscreen)
		{
			tut.blockInput = true;
			tut.pauseGame = true;
			tut.fullscreen = true;
		}
				
		theGame.GetTutorialSystem().DisplayTutorial(tut);
		currentlyShownHint = tutorialScriptName;
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////  @EVENTS  ///////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//override those in child states
	event OnMenuClosing(menuName : name) 	{}
	event OnMenuClosed(menuName : name) 	{}
	event OnMenuOpening(menuName : name) 	{}
	event OnMenuOpened(menuName : name) 	{}
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool) {}
}
