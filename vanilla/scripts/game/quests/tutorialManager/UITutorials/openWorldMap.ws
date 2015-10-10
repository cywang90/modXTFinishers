﻿/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

state OpenWorldMap in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_FAST_MENU, OPEN_MAP : name;
	
		default OPEN_FAST_MENU = 'TutorialMapOpenFastMenu';
		default OPEN_MAP = 'TutorialMapOpenMap';
	
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		//close hint asking to open menus
		CloseHint(OPEN_FAST_MENU);
		
		//hint about going to map panel
		highlights.Resize(1);
		highlights[0].x = 0.4;
		highlights[0].y = 0.4;
		highlights[0].width = 0.15;
		highlights[0].height = 0.18;
		
		ShowHint(OPEN_MAP, 0.35f, 0.6f, ETHDT_Infinite, highlights);	
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseHint(OPEN_MAP);
		
		super.OnLeaveState(nextStateName);
	}	
}
