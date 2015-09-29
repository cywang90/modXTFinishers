/*
Copyright © CD Projekt RED 2015
*/

exec function fb2(level : int, optional path : name)
{	
	var iID : array<SItemUniqueId>;
	var lm : W3PlayerWitcher;
	var exp, prevLvl, currLvl : int;
	
	GetWitcherPlayer().Debug_ClearCharacterDevelopment();
	
	
	lm = GetWitcherPlayer();
	prevLvl = lm.GetLevel();
	currLvl = lm.GetLevel();
		
	while(currLvl < level)
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
		lm.AddPoints(EExperiencePoint, exp, false); 
		
		currLvl = lm.GetLevel();
		
		if(prevLvl == currLvl)
			break;				
		
		prevLvl = currLvl;
	}		
	
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen steel sword', 1);
	GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen silver sword', 1);
	GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen Pants', 1); GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen Gloves', 1); GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen Boots', 1); GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen Armor', 1); GetWitcherPlayer().EquipItem(iID[0]);
	
}


exec function GetExpPoints(points : int)
{
	GetWitcherPlayer().AddPoints(EExperiencePoint, points, true );
}