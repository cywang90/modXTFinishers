class XTFinishersTailoredFinishersSlowdownModule extends XTFinishersDefaultSlowdownModule {
	protected function GetNewSlowdownManagerInstance() : XTFinishersSlowdownManager {
		var mgr : XTFinishersTailoredFinishersSlowdownManager;
		
		mgr = new XTFinishersTailoredFinishersSlowdownManager in this;
		mgr.Init();
		
		return mgr;
	}
}

class XTFinishersTailoredFinishersSlowdownManager extends XTFinishersDefaultSlowdownManager {
	private var customSequenceDefs : array<XTFinishersSlowdownSequenceDef>;
	
	private const var FINISHER_STANCE_LEFT_HEAD_ONE_INDEX, FINISHER_STANCE_LEFT_HEAD_TWO_INDEX, FINISHER_STANCE_LEFT_NECK_INDEX, FINISHER_STANCE_LEFT_THRUST_ONE_INDEX, FINISHER_STANCE_LEFT_THRUST_TWO_INDEX, FINISHER_STANCE_RIGHT_HEAD_INDEX, FINISHER_STANCE_RIGHT_THRUST_ONE_INDEX, FINISHER_STANCE_RIGHT_THRUST_TWO_INDEX : int;
		default FINISHER_STANCE_LEFT_HEAD_ONE_INDEX = 0;
		default FINISHER_STANCE_LEFT_HEAD_TWO_INDEX = 5;
		default FINISHER_STANCE_LEFT_NECK_INDEX = 6;
		default FINISHER_STANCE_LEFT_THRUST_ONE_INDEX = 2;
		default FINISHER_STANCE_LEFT_THRUST_TWO_INDEX = 4;
		default FINISHER_STANCE_RIGHT_HEAD_INDEX = 0;
		default FINISHER_STANCE_RIGHT_THRUST_ONE_INDEX = 1;
		default FINISHER_STANCE_RIGHT_THRUST_TWO_INDEX = 3;
		
	
	private const var FINISHER_DLC_STANCE_LEFT_ARM_INDEX, FINISHER_DLC_STANCE_LEFT_LEGS_INDEX, FINISHER_DLC_STANCE_LEFT_TORSO_INDEX, FINISHER_DLC_STANCE_RIGHT_ARM_INDEX, FINISHER_DLC_STANCE_RIGHT_LEGS_INDEX, FINISHER_DLC_STANCE_RIGHT_TORSO_INDEX, FINISHER_DLC_STANCE_RIGHT_HEAD_INDEX, FINISHER_DLC_STANCE_RIGHT_NECK_INDEX : int;
		default FINISHER_DLC_STANCE_LEFT_ARM_INDEX = 7;
		default FINISHER_DLC_STANCE_LEFT_LEGS_INDEX = 8;
		default FINISHER_DLC_STANCE_LEFT_TORSO_INDEX = 9;
		default FINISHER_DLC_STANCE_RIGHT_ARM_INDEX = 7;
		default FINISHER_DLC_STANCE_RIGHT_LEGS_INDEX = 8;
		default FINISHER_DLC_STANCE_RIGHT_TORSO_INDEX = 9;
		default FINISHER_DLC_STANCE_RIGHT_HEAD_INDEX = 10;
		default FINISHER_DLC_STANCE_RIGHT_NECK_INDEX = 11;
	
	public function Init() {
		var seqDef : XTFinishersSlowdownSequenceDef;
		
		super.Init();
		
		// 0: FINISHER_STANCE_LEFT_HEAD_ONE/FINISHER_STANCE_RIGHT_HEAD
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.75));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.45));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// 1: FINISHER_STANCE_RIGHT_THRUST_ONE
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.75));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// 2: FINISHER_STANCE_LEFT_THRUST_ONE
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// 3: FINISHER_STANCE_RIGHT_THRUST_TWO
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.75));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// 4: FINISHER_STANCE_LEFT_THRUST_TWO
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.75));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// 5: FINISHER_STANCE_LEFT_HEAD_TWO
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.65));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// 6: FINISHER_STANCE_LEFT_NECK
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.95));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// 7: FINISHER_DLC_STANCE_LEFT_ARM/FINISHER_DLC_STANCE_RIGHT_ARM
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.95));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.2, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// 8: FINISHER_DLC_STANCE_LEFT_LEGS/FINISHER_DLC_STANCE_RIGHT_LEGS
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.4));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.05, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.5));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// 9: FINISHER_DLC_STANCE_LEFT_TORSO/FINISHER_DLC_STANCE_RIGHT_TORSO
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.55));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.15, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.2));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// 10: FINISHER_DLC_STANCE_RIGHT_HEAD
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.65));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// 11: FINISHER_DLC_STANCE_RIGHT_NECK
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 1.25));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
	}
	
	protected function GetFinisherStanceLeftHeadOneSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_STANCE_LEFT_HEAD_ONE_INDEX];
	}
	
	protected function GetFinisherStanceLeftHeadTwoSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_STANCE_LEFT_HEAD_TWO_INDEX];
	}
	
	protected function GetFinisherStanceLeftNeckSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_STANCE_LEFT_NECK_INDEX];
	}
	
	protected function GetFinisherStanceLeftThrustOneSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_STANCE_LEFT_THRUST_ONE_INDEX];
	}
	
	protected function GetFinisherStanceLeftThrustTwoSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_STANCE_LEFT_THRUST_TWO_INDEX];
	}
	
	protected function GetFinisherStanceRightHeadSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_STANCE_RIGHT_HEAD_INDEX];
	}
	
	protected function GetFinisherStanceRightThrustOneSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_STANCE_RIGHT_THRUST_ONE_INDEX];
	}
	
	protected function GetFinisherStanceRightThrustTwoSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_STANCE_RIGHT_THRUST_TWO_INDEX];
	}
	
	protected function GetFinisherDlcStanceLeftArmSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_DLC_STANCE_LEFT_ARM_INDEX];
	}
	
	protected function GetFinisherDlcStanceLeftLegsSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_DLC_STANCE_LEFT_LEGS_INDEX];
	}
	
	protected function GetFinisherDlcStanceLeftTorsoSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_DLC_STANCE_LEFT_TORSO_INDEX];
	}
	
	protected function GetFinisherDlcStanceRightArmSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_DLC_STANCE_RIGHT_ARM_INDEX];
	}
	
	protected function GetFinisherDlcStanceRightLegsSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_DLC_STANCE_RIGHT_LEGS_INDEX];
	}
	
	protected function GetFinisherDlcStanceRightTorsoSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_DLC_STANCE_RIGHT_TORSO_INDEX];
	}
	
	protected function GetFinisherDlcStanceRightHeadSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_DLC_STANCE_RIGHT_HEAD_INDEX];
	}
	
	protected function GetFinisherDlcStanceRightNeckSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[FINISHER_DLC_STANCE_RIGHT_NECK_INDEX];
	}
	
	protected function GetFinisherSequence(context : XTFinishersActionContext) : XTFinishersSlowdownSequenceDef {
		switch (context.finisher.animName) {
		case theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_HEAD_ONE : 		return GetFinisherStanceLeftHeadOneSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_HEAD_TWO : 		return GetFinisherStanceLeftHeadTwoSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_NECK : 			return GetFinisherStanceLeftNeckSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_THRUST_ONE : 	return GetFinisherStanceLeftThrustOneSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_THRUST_ONE : 	return GetFinisherStanceLeftThrustTwoSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_STANCE_RIGHT_HEAD : 		return GetFinisherStanceRightHeadSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_STANCE_RIGHT_THRUST_ONE : 	return GetFinisherStanceRightThrustOneSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_STANCE_RIGHT_THRUST_ONE : 	return GetFinisherStanceRightThrustTwoSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_LEFT_ARM : 		return GetFinisherDlcStanceLeftArmSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_LEFT_LEGS :		return GetFinisherDlcStanceLeftLegsSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_LEFT_TORSO :		return GetFinisherDlcStanceLeftTorsoSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_ARM :		return GetFinisherDlcStanceRightArmSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_LEGS :		return GetFinisherDlcStanceRightLegsSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_TORSO :	return GetFinisherDlcStanceRightTorsoSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_HEAD :		return GetFinisherDlcStanceRightHeadSequence();
		case theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_NECK :		return GetFinisherDlcStanceRightNeckSequence();
		}
		return super.GetFinisherSequence(context);
	}
}