
/*
	Dispatches responders to answer queries. Responders are added using the LoadXXResponder() functions. Queries are made using the FireXXQuery() functions.
	
	The FireXXQuery() functions update contexts passed to them after they have been processed by responders. Responders should write any desired outputs to these contexts.
*/
class XTFinishersQueryManager {
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
	
	public function FireFinisherQuery(out context : XTFinishersFinisherContext) {
		finisherResponder.CanPerformFinisher(context);
	}
	
	public function FireDismemberQuery(out context : XTFinishersDismemberContext) {
		dismemberResponder.CanPerformDismember(context);
	}
	
	public function FireFinisherCamQuery(out context : XTFinishersFinisherCamContext) {
		finisherCamResponder.CanPerformFinisherCam(context);
	}
	
	public function FireSlowdownFinisherQuery(out context : XTFinishersSlowdownContext) {
		slowdownResponder.CanPerformSlowdownFinisher(context);
	}
	
	public function FireSlowdownDismemberQuery(out context : XTFinishersSlowdownContext) {
		slowdownResponder.CanPerformSlowdownDismember(context);
	}
}

class XTFinishersFinisherQueryResponder {
	public function CanPerformFinisher(out context : XTFinishersFinisherContext) {}
}

class XTFinishersDismemberQueryResponder {
	public function CanPerformDismember(out context : XTFinishersDismemberContext) {}
}

class XTFinishersFinisherCamQueryResponder {
	public function CanPerformFinisherCam(out context : XTFinishersFinisherCamContext) {}
}

class XTFinishersSlowdownQueryResponder {
	public function CanPerformSlowdownFinisher(out context : XTFinishersSlowdownContext) {}
	
	public function CanPerformSlowdownDismember(out context : XTFinishersSlowdownContext) {}
}