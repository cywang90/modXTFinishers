﻿/*
Copyright © CD Projekt RED 2015
*/




enum EBirdType
{
	Crow,
	Pigeon,
	Seagull,
	Sparrow
}

struct SBirdSpawnpoint
{
	var isBirdSpawned : bool;
	var isFlying : bool;
	var entityId : int;
	var entitySpawnTimestamp : float;
	var bird : W3Bird;
	var position : Vector;
	var rotation : EulerAngles;
}

struct SFishSpawnpoint
{
	var isFishSpawned : bool;
	var fish : W3CurveFish;
	var position : Vector;
	var rotation : EulerAngles;
};