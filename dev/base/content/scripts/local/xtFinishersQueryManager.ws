
/*
	Dispatches responders to answer queries. Responders are added using the LoadXXResponder() functions. Queries are made using the FireXXQuery() functions.
	
	The FireXXQuery() functions update contexts passed to them after they have been processed by responders. Responders should write any desired outputs to these contexts.
*/
class XTFinishersQueryManager extends XTFinishersObject {
	private var finisherResponder : XTFinishersFinisherQueryResponder;
	private var dismemberResponder : XTFinishersDismemberQueryResponder;
	private var finisherCamResponder : XTFinishersFinisherCamQueryResponder;
	private var slowdownResponder : XTFinishersSlowdownQueryResponder;
	
	// responders
	
	public function LoadFinisherResponder(responder : XTFinishersFinisherQueryResponder) {
		finisherResponder = responder;
	}
	
	public function LoadDismemberResponder(responder : XTFinishersDismemberQueryResponder) {
		dismemberResponder = responder;
	}
	
	public function LoadFinisherCamResponder(responder : XTFinishersFinisherCamQueryResponder) {
		finisherCamResponder = responder;
	}
	
	public function LoadSlowdownResponder(responder : XTFinishersSlowdownQueryResponder) {
		slowdownResponder = responder;
	}
	
	// fire queries
	
	public function FireFinisherQuery(context : XTFinishersActionContext) {
		finisherResponder.CanPerformFinisher(context);
	}
	
	public function FireDismemberQuery(context : XTFinishersActionContext) {
		dismemberResponder.CanPerformDismember(context);
	}
	
	public function FireFinisherCamQuery(context : XTFinishersActionContext) {
		finisherCamResponder.CanPerformFinisherCam(context);
	}
	
	public function FireSlowdownQuery(context : XTFinishersActionContext) {
		slowdownResponder.CanPerformSlowdown(context);
	}
}

abstract class XTFinishersFinisherQueryResponder extends XTFinishersObject {
	public function CanPerformFinisher(context : XTFinishersActionContext);
}

abstract class XTFinishersDismemberQueryResponder extends XTFinishersObject {
	public function CanPerformDismember(context : XTFinishersActionContext);
}

abstract class XTFinishersFinisherCamQueryResponder extends XTFinishersObject {
	public function CanPerformFinisherCam(context : XTFinishersActionContext);
}

abstract class XTFinishersSlowdownQueryResponder extends XTFinishersObject {
	public function CanPerformSlowdown(context : XTFinishersActionContext);
}