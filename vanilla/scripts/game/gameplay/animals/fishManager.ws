/*
Copyright © CD Projekt RED 2015
*/





class W3CurveFish extends CGameplayEntity
{
	
	editable var destroyDistance : float;
	editable var swimCurves : array<name>;
	editable var speedUpChance : float;
	editable var baseSpeedVariance : float;	
	editable var maxSpeed : float;
	editable var randomizedAppearances : array<string>;	
	
	
	private var manager : W3CurveFishManager;
	private var baseSpeed : float;
	private var selectedSwimCurve : name;
	private var currentSpeed : float;
	private var accelerate : bool;
	
		hint destroyDistance = "Distance from camera after which the fish is destroyed";
		hint swimCurves = "Array of names of swim curves - random is picked";
		hint speedupChance = "Chance of fish speeding up while swimming";
		
		default destroyDistance = 50;
		default speedUpChance = 0.2;
		default baseSpeedVariance = 0.2;
		default maxSpeed = 3.0;		
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		selectedSwimCurve = swimCurves[RandRange(swimCurves.Size(), 0)];
		
		super.OnSpawned(spawnData);
		LogAssert(swimCurves.Size() > 0, "W3CurveFish.OnSpawned: fish must have at least one swim curve!");
		
		SetupFishBaseSpeed();
		
		if(randomizedAppearances.Size() > 1)
		{
			ApplyAppearance(randomizedAppearances[RandRange(randomizedAppearances.Size()-1,0)]);
		}
		
		PlayPropertyAnimation(selectedSwimCurve, 0, baseSpeed );
		
		AddTimer('DestructionTimer', 1.0, true, , , true);
		AddTimer('SpeedHandler', 0.1, true);
		
	}
	
	public function SetFishManager(m : W3CurveFishManager)
	{
		manager = m;
	}
	
	function SetupFishBaseSpeed()
	{
		if(baseSpeedVariance < 0.0f) baseSpeedVariance = 0.0;
		baseSpeed = 1.0f + RandRangeF(baseSpeedVariance, baseSpeedVariance * -1.0);
		currentSpeed = baseSpeed;
	}
	
	
	timer function DestructionTimer(dt : float, id : int)
	{
		var isVisible : bool;
		var x, y : float;
		
		isVisible = theCamera.WorldVectorToViewRatio(GetWorldPosition(), x, y);
		if(isVisible && (AbsF(x) > 1.1 && AbsF(y) > 1.1))
			isVisible = false;
		
		if(!isVisible && VecDistance(GetWorldPosition(), theCamera.GetCameraPosition()) > destroyDistance)
		{
			manager.OnFishDestroyed(this);
			Destroy();
		}
	}

	function ModifyFishSpeed()
	{
		SetBehaviorVariable('Speed', currentSpeed * 0.5f );
		PlayPropertyAnimation(selectedSwimCurve, 0, currentSpeed);
	}

	
	timer function SpeedHandler(dt: float, id : int)
	{
		var rand : float;
		
		if( currentSpeed <= baseSpeed )
		{
			rand = RandRangeF(1.0, 0.0);
			
			if(rand >= speedUpChance)
			{
				accelerate = true;
				currentSpeed = currentSpeed + 0.1f;
				ModifyFishSpeed();
			}
			
		}
		else
		{
			if(accelerate)
			{
				currentSpeed = currentSpeed + 0.1f;
				ModifyFishSpeed();
				
				if( currentSpeed >= maxSpeed ) accelerate = false;
				
			}
			else
			{
				currentSpeed = currentSpeed - 0.1f;
				ModifyFishSpeed();
			}
		}
		
	}

	event OnDestroyed()
	{
		RemoveTimer('SpeedHandler');
	}

}




class W3CurveFishSpawnpoint extends CEntity {}




statemachine class W3CurveFishManager extends CGameplayEntity
{
	editable var fishSpawnPointsTag : name;
	editable var spawnRange : float;
	editable var fishTemplate : array<CEntityTemplate>;
	editable var respawnDelay : float;
	editable var respawnMinDistance : float;
	editable var randomFishRotation : bool;

	
	private var fishSpawnpoints : array<SFishSpawnpoint>;
	private var despawnTime : float;				
	private var wasEverVisible : bool;				


	
		default spawnRange = 50.0;
		default respawnDelay = 15;
		default respawnMinDistance = 15;	
		default autoState = 'Default';
		default wasEverVisible = false;
	
		hint respawnMinDistance = "Min distance between manager and camera to allow fish to respawn";
	
	
	
 	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		GotoStateAuto();
		super.OnSpawned(spawnData);
	}
	
	
	event OnDetaching()
	{
		var i : int;
		
		for(i = 0; i < fishSpawnpoints.Size(); i += 1)
		{
			if(fishSpawnpoints[i].fish)
				fishSpawnpoints[i].fish.Destroy();
		}
	}
	
	
	public function OnFishDestroyed(b : W3CurveFish)
	{
		var i : int;
	
		
		for(i=0; i<fishSpawnpoints.Size(); i+=1)
		{
			if(fishSpawnpoints[i].fish == b)
			{
				fishSpawnpoints[i].fish = NULL;
				break;
			}
		}
		
		for(i=0; i<fishSpawnpoints.Size(); i+=1)
			if(fishSpawnpoints[i].fish)
				return;
		
		despawnTime = theGame.GetEngineTimeAsSeconds();
	}
	
	private function SelectFishTemplate () : CEntityTemplate
	{
		
		return fishTemplate[ RandRange( fishTemplate.Size(), 0 ) ];
		
	}
	
	public function SpawnFish(optional forced : bool)
	{
		var i, size : int;
		var x, y : float;
		var isVisible : bool;
		var fish : W3CurveFish;		
		
		var spawnRotation : EulerAngles;
		
		if(!forced)
		{
			
			if(theGame.GetEngineTimeAsSeconds() < (respawnDelay + despawnTime))
				return;
				
			
			if(VecDistance(GetWorldPosition(), theCamera.GetCameraPosition()) < respawnMinDistance)
				return;
		}
		
		
		UpdateSpawnPointsList();
		size = fishSpawnpoints.Size();
		
		for(i = 0; i < size; i += 1)
		{
			if(!fishSpawnpoints[i].fish)
			{
				if(!forced)
				{
					isVisible = theCamera.WorldVectorToViewRatio(fishSpawnpoints[i].position, x, y);
					if(isVisible && (AbsF(x) > 1.1 && AbsF(y) > 1.1))
						isVisible = false;
				}
				
				if(randomFishRotation)
				{
					spawnRotation.Pitch = fishSpawnpoints[i].rotation.Pitch;
					spawnRotation.Roll = fishSpawnpoints[i].rotation.Roll;
					spawnRotation.Yaw = RandRangeF(359.0, 1.0);
				}
				else
				{
					spawnRotation = fishSpawnpoints[i].rotation;	
				}
				
				
				if(!isVisible || forced)
				{
					fish = (W3CurveFish)theGame.CreateEntity(SelectFishTemplate(), fishSpawnpoints[i].position, spawnRotation);
					if(fish)
					{
						fish.SetFishManager(this);
						fishSpawnpoints[i].fish = fish;
					}
				}
			}
		}
	}
	
	
	private function UpdateSpawnPointsList()
	{
		var spawnstruct : SFishSpawnpoint;
		var nodes : array<CNode>;
		var spawnpoint : W3CurveFishSpawnpoint;
		var collisionPos, testVec, normal : Vector;
		var world : CWorld;
		var i, j, lastExistingSpawnPoint : int;
		var exists : bool;
		var foundSpawnpoints : array<int>;
		var collisionGroups : array<name>;
		
		
		
		lastExistingSpawnPoint = fishSpawnpoints.Size()-1;
		theGame.GetNodesByTag(fishSpawnPointsTag, nodes);
		world = theGame.GetWorld();
		
		
		for(i=0; i<nodes.Size(); i+=1)
		{
			spawnpoint = (W3CurveFishSpawnpoint)nodes[i];
			if(spawnpoint)
			{
				
				spawnstruct.position = spawnpoint.GetWorldPosition();				
				
				
				
				
				exists = false;
				for(j=0; j<=lastExistingSpawnPoint; j+=1)
				{
					if(fishSpawnpoints[j].position == spawnstruct.position)
					{
						foundSpawnpoints.PushBack(j);
						exists = true;
						break;
					}
				}
				
				
				if(!exists)
				{
					spawnstruct.rotation = spawnpoint.GetWorldRotation();
					fishSpawnpoints.PushBack(spawnstruct);
				}
			}
		}
		
		
		for(i=lastExistingSpawnPoint; i>=0; i-=1)
		{
			exists = false;
			for(j=0; j<foundSpawnpoints.Size(); j+=1)
			{
				if(i == foundSpawnpoints[j])
				{
					exists = true;
					foundSpawnpoints.Erase(j);	
					break;
				}
			}
			
			if(!exists)
				fishSpawnpoints.Erase(i);		
		}		
	}
	
	private function DespawnFish()
	{
		var i : int;
			
		for(i = 0; i < fishSpawnpoints.Size(); i += 1)
		{
			if(fishSpawnpoints[i].fish)
				fishSpawnpoints[i].fish.Destroy();
		}
	}
	
	event OnDestroyed()
	{
		DespawnFish();
		RemoveTimer('FishSpawnCheck');
	}
	
	
	timer function FishSpawnCheck(td : float, id : int)
	{
		var x, y, dist : float;
		var i : int;
		var pos : Vector;
		var isVisible, areFishSpawned : bool;
	
		
		pos = GetWorldPosition();
		isVisible = theCamera.WorldVectorToViewRatio(pos, x, y);
		x = AbsF(x);
		y = AbsF(y);
		
		if(isVisible && (x >= 1.1 || y >= 1.1) )
			isVisible = false;
			
		if(isVisible)
			wasEverVisible = true;
			
		if(!isVisible)
		{
			dist = VecDistance(pos, theCamera.GetCameraPosition());
			
			areFishSpawned = false;
			for(i=0; i<fishSpawnpoints.Size(); i+=1)
			{
				if(fishSpawnpoints[i].fish)
				{
					areFishSpawned = true;
					break;
				}
			}
			
			if(areFishSpawned)
			{
				if(dist > spawnRange && wasEverVisible)
					DespawnFish();
			}
			else
			{
				if((x < 1.3 || y < 1.3) && dist <= spawnRange)
					SpawnFish(true);
			}
		}
		
		
	}
}

state Default in W3CurveFishManager
{
	event OnEnterState( prevStateName : name )
	{
		StateDefault();
	}
	
	entry function StateDefault()
	{
		parent.SpawnFish(true);		
		parent.AddTimer('FishSpawnCheck', 0.3, true);
	}
}
