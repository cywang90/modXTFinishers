﻿/*
Copyright © CD Projekt RED 2015
*/

abstract class W3UsableEntity extends CGameplayEntity
{
	public function UseEntity();
	public function CanBeUsed() : bool;
}