﻿/*
Copyright © CD Projekt RED 2015
*/

import class CCommonGame extends CGame
{
	import final function EnableSubtitles( enable : bool );
	import final function AreSubtitlesEnabled() : bool;

	
	import final function GetCommunitySystem() : CCommunitySystem;
	
	
	import final function GetAttackRangeForEntity( sourceEntity : CEntity, optional attackName : name ) : CAIAttackRange;
	
	
	import final function GetReactionsMgr() : CReactionsManager;
	
	import final function GetBehTreeReactionManager() : CBehTreeReactionManager;
	
	
	import final function GetIngredientCategoryElements(catName : name , out names : array<name>, out priorities : array<int>);
	
	
	import final function IsIngredientCategorySpecified(catName : name):bool;
	
	
	import final function GetIngredientCathegories() : array<name>;

	
	import final function GetSetItems( setName : name) : array<name>;
	
	
	import final function GetItemSetAbilities( itemName : name) : array<name>;
	
	
	import final function GetDefinitionsManager() : CDefinitionsManagerAccessor;
	
	import final function QueryExplorationSync( entity : CEntity, optional queryContext : SExplorationQueryContext ) : SExplorationQueryToken;
	import final function QueryExplorationFromObjectSync( entity : CEntity, object : CEntity, optional queryContext : SExplorationQueryContext ) : SExplorationQueryToken;
	

	
	import final function GetGlobalAttitude( srcGroup : name, dstGroup : name ) : EAIAttitude;

	
	import final function SetGlobalAttitude( srcGroup : name, dstGroup : name, attitude : EAIAttitude ) : bool;
		
	
	import final function GetReward( rewardName : name, out rewrd : SReward ) : bool;
	
	
	import final function GiveReward( rewardName : name, targetEntity : CEntity );
	
	
	
	
	import final function ConvertToStrayActor( actor : CActor ) : bool;
	
	
	
	
	
	
	
	
	
	import final function CreateEntityAsync( createEntityHelper : CCreateEntityHelper, entityTemplate : CEntityTemplate, pos : Vector, optional rot : EulerAngles,
										optional useAppearancesFromIncludes : bool , optional forceBehaviorPose : bool , 
										optional doNotAdjustPlacement : bool , optional persistanceMode : EPersistanceMode , optional tagList : array< name > ) : int;
	
	
	
	
	
	
	
	
	import final function LoadLastGameInit( optional suppressVideo : bool  );
	import final function LoadGameInit( info : SSavegameInfo );

	
	
	
	
	
	
	
	import final function GetLoadGameProgress() : ELoadGameResult;

	import final function ListSavedGames( out fileNames : array< SSavegameInfo > ) : bool; 
	
	import final function GetDisplayNameForSavedGame( savegame : SSavegameInfo ) : string;
	
	
	
	
	
	
	
	
	
	import final function SaveGame( type : ESaveGameType, slot : int );
	
	
	import final function GetNumSaveSlots( type : ESaveGameType ) : int;
	
	import final function DeleteSavedGame( savegame : SSavegameInfo ) : void;
	
	import final function GetContentRequiredByLastSave( out content : array< name > ) : void;
	
	
	
	
	
	import final function GetSaveInSlot( type : ESaveGameType, slot : int, out info : SSavegameInfo ) : bool;
	
	import final function ShouldShowSaveCompatibilityWarning() : bool;
	
	import final function RequestNewGame( gameResourceFilename : string ) : bool;
	import final function RequestEndGame();
	import final function RequestExit();
	import final function GetGameResourceList() : array< string >;
	
	import final function GetGameRelease() : string;
	
	
	import final function GetCurrentLocale() : string;
	
	
	import final function GetAllNPCs( out npcs : array<CNewNPC> );
	
	
	import final function GetAPManager() : CActionPointManager;

	
	import final function GetStorySceneSystem() : CStorySceneSystem;
	
	
	import final function GetActorByTag( tag : name ) : CActor;
	import final function GetNPCByTag( tag : name ) : CNewNPC;
	
	
	import final function GetActorsByTag( tag : name, out actors : array<CActor> );
	import final function GetNPCsByTag( tag : name, out npcs : array<CNewNPC> );
	
	
	import final function GetGameLanguageId( out audioLang : int, out subtitleLang : int );
	
	
	import final function GetGameLanguageName( out audioLang : string, out subtitleLang : string );
	
	
	import final function GetGameLanguageIndex( out audioLang : int, out subtitleLang : int );
	
	
	import final function GetAllAvailableLanguages( out textLanguages : array< string >, out speechLanguages : array< string > );
	
	
	import final function SwitchGameLanguageByIndex( audioLang : int, subtitleLang : int );
	
	import final function ReloadLanguage();
	
	
	import final function IsGameTimePaused() : bool;
	
	
	
	import final function AddStateChangeRequest( entityTag : name, modifier : IEntityStateChangeRequest );
	
	
	
	
	
	import final function CreateNoSaveLock( reason : string, out lock : int, optional unique : bool, optional allowCheckpoints : bool );
	
	
	import final function ReleaseNoSaveLock( lock : int );
	
	
	import final function ReleaseNoSaveLockByName( lockName : string );
	
	
	import final function AreSavesLocked() : bool;
	
	
	import final function ConfigSave();
	
	
	import final function AreSavesInitialized() : bool;
	
	
	import final function IsInvertCameraX() : bool;
	import final function IsInvertCameraY() : bool;
	import final function SetInvertCameraX( invert : bool );
	import final function SetInvertCameraY( invert : bool );
	import final function SetInvertCameraXOnMouse( invert : bool );
	import final function SetInvertCameraYOnMouse( invert : bool );
	
	import final function IsCameraAutoRotX() : bool;
	import final function IsCameraAutoRotY() : bool;
	import final function SetCameraAutoRotX( flag : bool );
	import final function SetCameraAutoRotY( flag : bool );
	
	import final function ChangePlayer( playerTemplate : String, optional appearance : name );
	
	import final function ScheduleWorldChangeToMapPin( worldPath : string, mapPinName : name );
	import final function ScheduleWorldChangeToPosition( worldPath : string, position : Vector, rotation : EulerAngles );
	
	import final function ForceUIAnalog( value : bool );
	import final function RequestMenu( menuName: name, optional initData : IScriptable );
	import final function CloseMenu( menuName: name );
	import final function RequestPopup( popupName: name, optional initData : IScriptable );
	import final function ClosePopup( popupName: name );
	import final function GetHud() : CHud;
	import final function GetInGameConfigWrapper() : CInGameConfigWrapper;
	
	
	import final function ImportSave( savegameInfo : SSavegameInfo ) : bool;
	
	
	import final function ListW2SavedGames( out savedGames : array< SSavegameInfo > ) : bool;
	
	
	import final function TestNoCreaturesOnLocation( pos : Vector, radius : float, optional ignoreActor : CActor ) : bool;
	
	
	import final function TestNoCreaturesOnLine( pos0 : Vector, pos1 : Vector, lineWidth : float, optional ignoreActor0 : CActor , optional ignoreActor1 : CActor , optional ignoreGhostCharacters : bool  ) : bool;
	
	
	
	import final function RequestAutoSave( reason : string, force : bool );
	
	import final function CalculateTimePlayed() : GameTime;
	
	
	import final function RequestScreenshotData( save : SSavegameInfo );

	
	
	import final function IsScreenshotDataReady() : bool;

	
	import final function FreeScreenshotData();
	
	
	import final function CenterMouse();
	
	
	import final function MoveMouseTo(xpos : float, ypos : float);

	event OnBeforeWorldChange( worldName : string );

	
	public var tooltipSettings : C2dArray;
	
	import final function GetUIHorizontalPlusFrameScale() : float;
	
	import final function GetDLCManager() : CDLCManager;
	
	import final function AreConfigResetInThisSession() : bool;
	
	import final function HasShownConfigChangedMessage() : bool;
	
	import final function SetHasShownConfigChangedMessage( value : bool ) : void;

	import final function GetApplicationVersion() : string;
	
	import final function IsSoftwareCursor() : bool;
	
	import final function ShowHardwareCursor() : void;
	
	import final function HideHardwareCursor() : void;
	
	import final function GetAchievementsDisabled() : bool;
}