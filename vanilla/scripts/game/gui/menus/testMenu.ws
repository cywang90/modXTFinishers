﻿/*
Copyright © CD Projekt RED 2015
*/

class CR4TestMenu extends CR4MenuBase
{
	private var entityTemplateIndex : int;			default entityTemplateIndex = 0;
	private var appearanceIndex : int;				default appearanceIndex = 0;
	private var environmentDefinitionIndex : int;	default environmentDefinitionIndex = 0;
	private var entityTemplates : array< string >;
	private var appearances : array< name >;
	private var environmentDefinitions : array< string >;
	
	private var sunRotation : EulerAngles;

	event  OnConfigUI()
	{
		super.OnConfigUI();
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		
		entityTemplates.PushBack( "characters\player_entities\geralt\geralt_player.w2ent" );
		entityTemplates.PushBack( "characters\player_entities\ciri\ciri_player.w2ent" );
		entityTemplates.PushBack( "characters\npc_entities\animals\horse\player_horse.w2ent");	

		appearances.PushBack( 'ciri_player' );
		appearances.PushBack( 'ciri_player_towel' );
		appearances.PushBack( 'ciri_player_naked' );
		appearances.PushBack( 'ciri_player_wounded' );

		environmentDefinitions.PushBack( "environment\definitions\gui_character_display\gui_character_environment.env" );
		
		theGame.GetGuiManager().SetBackgroundTexture( LoadResource( "inventory_background" ) );

		UpdateEntityTemplate();
		UpdateEnvironmentAndSunRotation();
		UpdateItems();
	}

	event  OnClosingMenu()
	{
		theInput.RestoreContext( 'EMPTY_CONTEXT', false );
	}
	
	event  OnCameraUpdate( lookAtX : float, lookAtY : float, lookAtZ : float, cameraYaw : float, cameraPitch : float, cameraDistance : float )
	{
		var lookAtPos : Vector;
		var cameraRotation : EulerAngles;
		var fov : float;
		
		fov = 35.0f;
		
		lookAtPos.X = lookAtX;
		lookAtPos.Y = lookAtY;
		lookAtPos.Z = lookAtZ;
		
		cameraRotation.Yaw = cameraYaw;
		cameraRotation.Pitch = cameraPitch;
		cameraRotation.Roll = 0;
		
		theGame.GetGuiManager().SetupSceneCamera( lookAtPos, cameraRotation, cameraDistance, fov );
	}
	
	event  OnSunUpdate( sunYaw : float, sunPitch : float )
	{
		sunRotation.Yaw = sunYaw;
		sunRotation.Pitch = sunPitch;
		UpdateEnvironmentAndSunRotation();
	}

	event  OnNextEntityTemplate()
	{
		entityTemplateIndex += 1;
		entityTemplateIndex = entityTemplateIndex % entityTemplates.Size();
		
		UpdateEntityTemplate();
		
		if( entityTemplateIndex == 0 )
		{
			UpdateItems();
		}
		
	}

	event  OnNextAppearance()
	{
		appearanceIndex += 1;
		appearanceIndex = appearanceIndex % appearances.Size();
		
		UpdateApperance();
	}

	event  OnNextEnvironmentDefinition()
	{
		environmentDefinitionIndex += 1;
		environmentDefinitionIndex = environmentDefinitionIndex % environmentDefinitions.Size();

		UpdateEnvironmentAndSunRotation();
	}

	event  OnCloseMenu()
	{
		CloseMenu();
	}
	
	event  OnCloseMenuTemp()
	{
		CloseMenu();
	}

	protected function UpdateEntityTemplate()
	{
		var template : CEntityTemplate;
		template = ( CEntityTemplate )LoadResource( entityTemplates[ entityTemplateIndex ], true );
		if ( template )
		{
			theGame.GetGuiManager().SetSceneEntityTemplate( template, 'locomotion_idle' );
			m_flashValueStorage.SetFlashString("test.entityTemplate", entityTemplates[ entityTemplateIndex ] );
		}
	}
	
	protected function UpdateApperance()
	{
		theGame.GetGuiManager().ApplyAppearanceToSceneEntity( appearances[ appearanceIndex ] );
	}
	
	protected function UpdateItems()
	{
		var inventory : CInventoryComponent;
		var items : array< name >;
		var witcher : W3PlayerWitcher;

		inventory = thePlayer.GetInventory();
		if ( inventory )
		{
			inventory.GetHeldAndMountedItems( items );
			
			witcher = (W3PlayerWitcher) thePlayer;
			if ( witcher )
			{
				witcher.GetMountableItems( items );
			}
			
			theGame.GetGuiManager().UpdateSceneEntityItems( items );
		}
	}

	protected function UpdateEnvironmentAndSunRotation()
	{
		var environment : CEnvironmentDefinition;
		environment = ( CEnvironmentDefinition )LoadResource( environmentDefinitions[ environmentDefinitionIndex ], true );
		if ( environment )
		{
			theGame.GetGuiManager().SetSceneEnvironmentAndSunPosition( environment, sunRotation );
			m_flashValueStorage.SetFlashString("test.environmentDefinition", environmentDefinitions[ environmentDefinitionIndex ] );
		}
	}

}

exec function testmenu()
{
	theGame.RequestMenu('TestMenu');
}

exec function testmenu_transform(x : float, y : float, z : float, scale : float)
{
	var position:Vector;
	var _scale:Vector;
	var rotation:EulerAngles;
	
	position.X = x;
	position.Y = y;
	position.Z = z;
	
	_scale.X = scale;
	_scale.Y = scale;
	_scale.Z = scale;
	
	theGame.GetGuiManager().SetEntityTransform(position, rotation, _scale);
}
