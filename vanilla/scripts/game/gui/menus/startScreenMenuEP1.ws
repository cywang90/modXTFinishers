/***********************************************************************/
/** Witcher Script file - Start Screen Menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4StartScreenMenuEP1 extends CR4MenuBase
{	
	private var _fadeDuration : float;
	default _fadeDuration = 0.1;
	protected var m_fxSetFadeDuration	: CScriptedFlashFunction;
	protected var m_fxSetIsStageDemo	: CScriptedFlashFunction;
	protected var m_fxStartFade			: CScriptedFlashFunction;
	private var m_fxSetGameLogoLanguage	: CScriptedFlashFunction;
	protected var m_fxSetText			: CScriptedFlashFunction;
	
	event /*flash*/ OnConfigUI()
	{	
		var languageName : string;
		var audioLanguageName : string;
		//theSound.EnterGameState( ESGS_EndScreen ); // #B old, check
		//theSound.SoundEvent("mus_menu_theme"); // #B old, check
		super.OnConfigUI();
		
		_fadeDuration = thePlayer.GetStartScreenFadeDuration();
		m_fxSetFadeDuration = GetMenuFlash().GetMemberFlashFunction("SetFadeDuration");
		m_fxStartFade = GetMenuFlash().GetMemberFlashFunction("startClosingTimer");
		m_fxSetText = GetMenuFlash().GetMemberFlashFunction("setDisplayedText");
		//m_fxSetIsStageDemo = GetMenuFlash().GetMemberFlashFunction("SetIsStageDemo");
		//m_fxSetIsStageDemo.InvokeSelfOneArg(FlashArgBool(thePlayer.GetStartScreenIsOpenedAsStageDemo()));
		SetFadeTime();
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		// #B fixme bidon - add context "EMPTY_CONTEXT"
		
		setStandardtext();
		theGame.GetGuiManager().OnEnteredStartScreen();
		
		theGame.SetActiveUserPromiscuous();
		
		m_fxSetGameLogoLanguage = m_flashModule.GetMemberFlashFunction( "setGameLogoLanguage" );
		//m_fxSetMovieData.InvokeSelfOneArg(FlashArgString(GetCurrentBackgroundMovie()));
		theGame.GetGameLanguageName(audioLanguageName,languageName);
		m_fxSetGameLogoLanguage.InvokeSelfOneArg( FlashArgString(languageName) );
		
		theSound.StopMusic( );
		theSound.SoundEvent( "play_music_main_menu" );
		theSound.SoundEvent( "mus_main_menu_theme_fire_only" );
		
		theGame.ResetFadeLock( "Entering start screen" );
		
		if( theGame.IsBlackscreen() )
		{
			theGame.FadeInAsync();
		}
		
		LogChannel('asdf', "EP1: " + theGame.GetDLCManager().IsEP1Available() );
	}
	
	event /*flash*/ OnCloseMenu()
	{
		if( !thePlayer.GetStartScreenEndWithBlackScreen() )
		{
			theGame.FadeInAsync(thePlayer.GetStartScreenFadeInDuration());
		}
		thePlayer.SetStartScreenIsOpened(false);
		CloseMenu();
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		
		theGame.GetGuiManager().SetIsDuringFirstStartup( false );
		
		theSound.SoundEvent("stop_music"); // Need to stop it for the cinematic between and main menu
	}

	private function SetFadeTime()
	{
		var time : int;
		time = (int)(1000 * _fadeDuration);
		m_fxSetFadeDuration.InvokeSelfOneArg(FlashArgNumber(time));
		theGame.FadeInAsync(_fadeDuration);
	}
	
	public function startFade():void
	{
		m_fxStartFade.InvokeSelf();
		//theGame.FadeOutAsync(_fadeDuration);
	}
	
	event OnKeyPress()
	{
		//theSound.SoundEvent("mus_loc_silent"); // #B old, check
		//theSound.EnterGameState( ESGS_Movie ); // #B old, check
		if (theGame.isUserSignedIn())
		{
			startFade();
		}
	}
	
	event OnPlaySoundEvent( soundName : string )
	{
	}
	
	public function setStandardtext():void
	{
		if (theGame.GetPlatform() == Platform_Xbox1)
		{
			m_fxSetText.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("panel_button_press_any_X1")));
		}
		else if (theGame.GetPlatform() == Platform_PS4)
		{
			m_fxSetText.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("panel_button_press_any_PS4")));
		}
		else
		{
			m_fxSetText.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("panel_button_press_any")));
		}
	}
	
	public function setWaitingText()
	{
		// Same for all platforms
		m_fxSetText.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("panel_please_wait")));
	}
	
	function PlayOpenSoundEvent() // # Disable the open sound when entering start screen
	{
	}
}

exec function TheBeginingEP1()
{
	theGame.RequestMenu('StartScreenMenuEP1');
}
