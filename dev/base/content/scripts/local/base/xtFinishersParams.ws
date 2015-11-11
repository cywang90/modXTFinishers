abstract class XTFinishersParams extends XTFinishersObject {
	public function LoadParamsFromPreset(preset : XTFinishersParamsList) {
		var paramDefs : array<XTFinishersParamDefinition>;
		var i : int;
		
		paramDefs = preset.GetParams();
		for (i = 0; i < paramDefs.Size(); i+=1) {
			LoadParam(paramDefs[i]);
		}
	}
	
	public function LoadParam(paramDef : XTFinishersParamDefinition);
}

class XTFinishersParamsPreset extends XTFinishersObject {
	private var paramDefs : array<XTFinishersParamDefinition>;
	
	public function AddParam(param : XTFinishersParamDefinition) {
		paramDefs.PushBack(param);
	}
	
	public function GetParams() : array<XTFinishersParamDefinition> {
		return paramDefs;
	}
}

abstract class XTFinishersParamDefinition extends XTFinishersObject {
	public function GetId() : string;
	public function GetData() : XTFinishersObject;
}

class XTFinishersConcreteParamDefinition extends XTFinishersParamDefinition {
	private var id : string;
	private var data : XTFinishersObject;
	
	public function Init(id : string, data : XTFinishersObject) {
		this.id = id;
		this.data = data;
	}
	
	public function GetId() : string {
		return id;
	}
	
	public function GetData() : XTFinishersObject {
		return data;
	}
}

// convenience constructors

function CreateXTFinishersParamDefInt(owner : XTFinishersObject, id : string, value : int) : XTFinishersParamDefinition {
	var paramDef : XTFinishersConcreteParamDefinition;
	
	paramDef = new XTFinishersConcreteParamDefinition in owner;
	paramDef.Init(id, CreateXTFinishersInt(paramDef, value));
	return paramDef;
}

function CreateXTFinishersParamDefFloat(owner : XTFinishersObject, id : string, value : float) : XTFinishersParamDefinition {
	var paramDef : XTFinishersConcreteParamDefinition;
	
	paramDef = new XTFinishersConcreteParamDefinition in owner;
	paramDef.Init(id, CreateXTFinishersFloat(paramDef, value));
	return paramDef;
}

function CreateXTFinishersParamDefBool(owner : XTFinishersObject, id : string, value : bool) : XTFinishersParamDefinition {
	var paramDef : XTFinishersConcreteParamDefinition;
	
	paramDef = new XTFinishersConcreteParamDefinition in owner;
	paramDef.Init(id, CreateXTFinishersBool(paramDef, value));
	return paramDef;
}

function CreateXTFinishersParamDefString(owner : XTFinishersObject, id : string, value : string) : XTFinishersParamDefinition {
	var paramDef : XTFinishersConcreteParamDefinition;
	
	paramDef = new XTFinishersConcreteParamDefinition in owner;
	paramDef.Init(id, CreateXTFinishersString(paramDef, value));
	return paramDef;
}

function CreateXTFinishersParamDefName(owner : XTFinishersObject, id : string, value : name) : XTFinishersParamDefinition {
	var paramDef : XTFinishersConcreteParamDefinition;
	
	paramDef = new XTFinishersConcreteParamDefinition in owner;
	paramDef.Init(id, CreateXTFinishersName(paramDef, value));
	return paramDef;
}