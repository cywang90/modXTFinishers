class XTFinishersObject {
	public function toString() : string {
		return "" + this;
	}
}

// wrapper classes

class XTFinishersInt extends XTFinishersObject {
	public var value : int;
	
	public function Init(value : int) {
		this.value = value;
	}
	
	public function toString() : string {
		return "" + value;
	}
}

class XTFinishersFloat extends XTFinishersObject {
	public var value : float;
	
	public function Init(value : float) {
		this.value = value;
	}
	
	public function toString() : string {
		return "" + value;
	}
}

class XTFinishersBool extends XTFinishersObject {
	public var value : bool;
	
	public function Init(value : bool) {
		this.value = value;
	}
	
	public function toString() : string {
		return "" + value;
	}
}

class XTFinishersString extends XTFinishersObject {
	public var value : string;
	
	public function Init(value : string) {
		this.value = value;
	}
	
	public function toString() : string {
		return value;
	}
}

class XTFinishersName extends XTFinishersObject {
	public var value : name;
	
	public function Init(value : name) {
		this.value = value;
	}
	
	public function toString() : string {
		return "" + value;
	}
}

// constructors for wrapper classes

function CreateXTFinishersInt(owner : XTFinishersObject, value : int) : XTFinishersInt {
	var obj : XTFinishersInt;
	
	obj = new XTFinishersInt in owner;
	obj.Init(value);
	return obj;
}

function CreateXTFinishersFloat(owner : XTFinishersObject, value : float) : XTFinishersFloat {
	var obj : XTFinishersFloat;
	
	obj = new XTFinishersFloat in owner;
	obj.Init(value);
	return obj;
}

function CreateXTFinishersBool(owner : XTFinishersObject, value : bool) : XTFinishersBool {
	var obj : XTFinishersBool;
	
	obj = new XTFinishersBool in owner;
	obj.Init(value);
	return obj;
}

function CreateXTFinishersString(owner : XTFinishersObject, value : string) : XTFinishersString {
	var obj : XTFinishersString;
	
	obj = new XTFinishersString in owner;
	obj.Init(value);
	return obj;
}

function CreateXTFinishersName(owner : XTFinishersObject, value : name) : XTFinishersName {
	var obj : XTFinishersName;
	
	obj = new XTFinishersName in owner;
	obj.Init(value);
	return obj;
}