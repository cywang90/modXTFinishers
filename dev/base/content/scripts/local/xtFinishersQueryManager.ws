
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
	
	public function FireFinisherQuery(out context : XTFinishersActionContext) {
		finisherResponder.CanPerformFinisher(context);
	}
	
	public function FireDismemberQuery(out context : XTFinishersActionContext) {
		dismemberResponder.CanPerformDismember(context);
	}
	
	public function FireFinisherCamQuery(out context : XTFinishersActionContext) {
		finisherCamResponder.CanPerformFinisherCam(context);
	}
	
	public function FireSlowdownQuery(out context : XTFinishersActionContext) {
		slowdownResponder.CanPerformSlowdown(context);
	}
}

abstract class XTFinishersFinisherQueryResponder extends XTFinishersObject {
	public function CanPerformFinisher(out context : XTFinishersActionContext);
}

abstract class XTFinishersDismemberQueryResponder extends XTFinishersObject {
	public function CanPerformDismember(out context : XTFinishersActionContext);
}

abstract class XTFinishersFinisherCamQueryResponder extends XTFinishersObject {
	public function CanPerformFinisherCam(out context : XTFinishersActionContext);
}

abstract class XTFinishersSlowdownQueryResponder extends XTFinishersObject {
	public function CanPerformSlowdown(out context : XTFinishersActionContext);
}