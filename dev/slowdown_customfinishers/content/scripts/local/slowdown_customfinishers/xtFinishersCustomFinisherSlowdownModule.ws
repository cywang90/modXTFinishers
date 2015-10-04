class XTFinishersCustomFinisherSlowdownModule extends XTFinishersDefaultSlowdownModule {
	protected function GetNewSlowdownManagerInstance() : XTFinishersSlowdownManager {
		var mgr : XTFinishersCustomFinisherSlowdownManager;
		
		mgr = new XTFinishersCustomFinisherSlowdownManager in this;
		mgr.Init();
		
		return mgr;
	}
}

class XTFinishersCustomFinisherSlowdownManager extends XTFinishersDefaultSlowdownManager {
	private var customSequenceDefs : array<XTFinishersSlowdownSequenceDef>;
	
	public function Init() {
		var seqDef : XTFinishersSlowdownSequenceDef;
		
		super.Init();
		
		// man_finisher_01_rp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.75));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.45));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_02_lp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.75));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.65));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_03_rp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.75));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_04_lp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_05_rp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.75));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_06_lp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.75));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_07_lp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.65));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_08_lp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.95));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_dlc_arm_lp/rp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.95));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.2, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_dlc_legs_lp/rp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.4));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.05, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.5));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_dlc_torso_lp/rp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.55));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.15, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.2));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_dlc_head_rp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.85));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 0.65));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
		
		// man_finisher_dlc_neck_rp
		seqDef = new XTFinishersSlowdownSequenceDef in this;
		seqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, 1.25));
		seqDef.AddSegment(CreateXTFinishersSlowdownSession(this, 0.1, 0.1));
		customSequenceDefs.PushBack(seqDef);
	}
	
	protected function GetFinisher01Sequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[0];
	}
	
	protected function GetFinisher02Sequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[1];
	}
	
	protected function GetFinisher03Sequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[2];
	}
	
	protected function GetFinisher04Sequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[3];
	}
	
	protected function GetFinisher05Sequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[4];
	}
	
	protected function GetFinisher06Sequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[5];
	}
	
	protected function GetFinisher07Sequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[6];
	}
	
	protected function GetFinisher08Sequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[7];
	}
	
	protected function GetDlcFinisherArmLeftSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[8];
	}
	
	protected function GetDlcFinisherArmRightSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[8];
	}
	
	protected function GetDlcFinisherLegsLeftSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[9];
	}
	
	protected function GetDlcFinisherLegsRightSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[9];
	}
	
	protected function GetDlcFinisherTorsoLeftSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[10];
	}
	
	protected function GetDlcFinisherTorsoRightSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[10];
	}
	
	protected function GetDlcFinisherHeadRightSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[11];
	}
	
	protected function GetDlcFinisherNeckRightSequence() : XTFinishersSlowdownSequenceDef {
		return customSequenceDefs[12];
	}
	
	protected function GetFinisherSequence(context : XTFinishersActionContext) : XTFinishersSlowdownSequenceDef {
		switch (context.finisher.animName) {
		case 'man_finisher_01_rp' : 		return GetFinisher01Sequence();
		case 'man_finisher_02_lp' : 		return GetFinisher02Sequence();
		case 'man_finisher_03_rp' : 		return GetFinisher03Sequence();
		case 'man_finisher_04_lp' : 		return GetFinisher04Sequence();
		case 'man_finisher_05_rp' : 		return GetFinisher05Sequence();
		case 'man_finisher_06_lp' : 		return GetFinisher06Sequence();
		case 'man_finisher_07_lp' : 		return GetFinisher07Sequence();
		case 'man_finisher_08_lp' : 		return GetFinisher08Sequence();
		case 'man_finisher_dlc_arm_lp' : 	return GetDlcFinisherArmLeftSequence();
		case 'man_finisher_dlc_arm_rp' :	return GetDlcFinisherArmRightSequence();
		case 'man_finisher_dlc_legs_lp' :	return GetDlcFinisherLegsLeftSequence();
		case 'man_finisher_dlc_legs_rp' :	return GetDlcFinisherLegsRightSequence();
		case 'man_finisher_dlc_torso_lp' :	return GetDlcFinisherTorsoLeftSequence();
		case 'man_finisher_dlc_torso_rp' :	return GetDlcFinisherTorsoRightSequence();
		case 'man_finisher_dlc_head_rp' :	return GetDlcFinisherHeadRightSequence();
		case 'man_finisher_dlc_neck_rp' :	return GetDlcFinisherNeckRightSequence();
		}
		return super.GetFinisherSequence(context);
	}
}