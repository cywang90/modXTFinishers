
/*
	Event dispatcher for XTFinishers. Tracks and notifies event listeners. Listeners are added using the RegisterXXListener() functions. Events are triggered using the FireXXEvent functions.
	
	When an event is triggered, listeners are called in order according to the value returned by their GetPriority() function:
		- listener a is guaranteed to be called before listener b if and only if a.GetPriority() < b.GetPriority().
		- if a.GetPriority() == b.GetPriority() is true, there is no guarantee which one will be called first.
*/
class XTFinishersEventManager {
	//private var actionStartListenerQueue, actionEndListenerQueue, reactionListenerQueue, finisherListenerQueue, dismemberListenerQueue, finisherCamListenerQueue, slowdownListenerQueue : XTFinishersPriorityListenerQueue;
	
	private var queues : array<XTFinishersPriorityListenerQueue>;
	private var ids : array<string>;
	
	public function Init() {
		/*
		actionStartListenerQueue = new XTFinishersPriorityListenerQueue in this;
		actionEndListenerQueue = new XTFinishersPriorityListenerQueue in this;
		reactionListenerQueue = new XTFinishersPriorityListenerQueue in this;
		finisherListenerQueue = new XTFinishersPriorityListenerQueue in this;
		dismemberListenerQueue = new XTFinishersPriorityListenerQueue in this;
		finisherCamListenerQueue = new XTFinishersPriorityListenerQueue in this;
		slowdownListenerQueue = new XTFinishersPriorityListenerQueue in this;
		*/
	}
	
	public function RegisterEventListener(id : string, listener : XTFinishersPriorityListener) {
		AddListener(id, listener);
	}
	
	public function FireEvent(id : string, data : XTFinishersEventData) {
		var index : int;
		
		index = FindId(id);
		if (index > 0) {
			NotifyListeners(index, data);
		}
	}
	
	private function AddListener(id : string, listener : XTFinishersPriorityListener) {
		var index : int;
		
		index = FindId(id);
		if (index < 0) {
			index = -(index + 1);
			InsertQueue(index, id);
		}
		
		queues[index].Add(listener);
	}
	
	private function NotifyListeners(index : int, data : XTFinishersEventData) {
		var i : int;
		
		for (i = 0; i < queues[index].Size(); i += 1) {
			queues[index].Get(i).OnEventTriggered(ids[index], data);
		}
	}
	
	private function FindId(id : string) : int {
		var max, min, current, comp : int;
		
		min = 0;
		max = ids.Size();
		current = (min + max) / 2;
		
		while (max > min) {
			comp = StrCmp(id, ids[current]);
			if (comp > 0) {
				min = current + 1;
			} else if (comp < 0) {
				max = current;
			} else {
				return current;
			}
			current = (min + max) / 2;
		}
		return -current - 1;
	}
	
	private function InsertQueue(index : int, id : string) {
		var i : int;
	
		queues.PushBack(new XTFinishersPriorityListenerQueue in this);
		ids.PushBack(id);
		
		for (i = queues.Size() - 1; i > index; i -= 1) {
			SwapQueues(i, i - 1);
			SwapIds(i, i - 1);
		}
	}
	
	private function SwapQueues(pos1 : int, pos2 : int) {
		var temp : XTFinishersPriorityListenerQueue;
		
		temp = queues[pos1];
		queues[pos1] = queues[pos2];
		queues[pos2] = temp;
	}
	
	private function SwapIds(pos1 : int, pos2 : int) {
		var temp : string;
		
		temp = ids[pos1];
		ids[pos1] = ids[pos2];
		ids[pos2] = temp;
	}
	
	public function CreateActionContextData(context : XTFinishersActionContext) : XTFinishersActionContextData {
		var data : XTFinishersActionContextData;
		data = new XTFinishersActionContextData in this;
		data.SetData(context);
		return data;
	}
	
	public function CreateSlowdownSegmentData(segment : XTFinishersSlowdownSegment, optional success : bool) : XTFinishersSlowdownSegmentData {
		var data : XTFinishersSlowdownSegmentData;
		data = new XTFinishersSlowdownSegmentData in this;
		data.SetData(segment, success);
		return data;
	}
}

class XTFinishersPriorityListenerQueue {
	private var queue : array<XTFinishersPriorityListener>;
	
	public function Size() : int {
		return queue.Size();
	}
	
	public function Add(listener : XTFinishersPriorityListener) {
		queue.PushBack(listener);
		InsertionSort();
	}
	
	public function AddGroup(listeners : array<XTFinishersPriorityListener>) {
		var i : int;
		
		if (listeners.Size() < 25) {
			for (i = 0; i < listeners.Size(); i += 1) {
				Add(listeners[i]);
			}
		} else {
			for (i = 0; i < listeners.Size(); i += 1) {
				queue.PushBack(listeners[i]);
			}
			QuickSort(0, queue.Size() - 1);
		}
	}
	
	public function Get(index : int) : XTFinishersPriorityListener {
		return queue[index];
	}
	
	private function Find(priority : int) : int {
		var max, min, current, comp : int;
		
		min = 0;
		max = queue.Size();
		current = (min + max) / 2;
		
		while (max > min) {
			comp = priority - queue[current].GetPriority();
			if (comp > 0) {
				min = current + 1;
			} else if (comp < 0) {
				max = current;
			} else {
				return current;
			}
			current = (min + max) / 2;
		}
		return -current - 1;
	}
	
	private function Swap(i : int, j : int) {
		var temp : XTFinishersPriorityListener;
		
		temp = queue[i];
		queue[i] = queue[j];
		queue[j] = temp;
	}
	
	private function InsertionSort() {
		var i : int;
		
		for (i = queue.Size() - 1; i > 0; i -= 1) {
			if (queue[i].GetPriority() - queue[i - 1].GetPriority() >= 0) {
				return;
			} else {
				Swap(i, i - 1);
			}
		}
	}
	
	private function QuickSort(min : int, max : int) {
		var partitionIndex : int;
		
		if (max > min) {
			partitionIndex = QuickSortPartition(min, max);
			QuickSort(min, partitionIndex);
			QuickSort(partitionIndex + 1, max);
		}
	}
	
	private function QuickSortPartition(min : int, max : int) : int {
		var pivot, i, j : int;
		
		pivot = queue[min].GetPriority();
		i = min - 1;
		j = max + 1;
		while (true) {
			do {
				j -= 1;
			} while (queue[j].GetPriority() <= pivot);
			do {
				i += 1;
			} while (queue[i].GetPriority() >= pivot);
			if (i < j) {
				Swap(i, j);
			} else {
				return j;
			}
		}
		return -1; // to satisfy the compiler.
	}
}

abstract class XTFinishersPriorityListener {
	private var priority : int;
	
	public function Init(priorityArg : int) {
		priority = priorityArg;
	}
	
	public function GetPriority() : int {
		return priority;
	}
	
	public function OnEventTriggered(id : string, data : XTFinishersEventData);
}

abstract class XTFinishersEventData {}

class XTFinishersActionContextData extends XTFinishersEventData {
	public var context : XTFinishersActionContext;
	
	public function SetData(context : XTFinishersActionContext) {
		this.context = context;
	}
}

abstract class XTFinishersAbstractActionStartEventListener extends XTFinishersPriorityListener {
	public final function OnEventTriggered(id : string, data : XTFinishersEventData) {
		var actionContextData : XTFinishersActionContextData;
		var context : XTFinishersActionContext;
		
		actionContextData = (XTFinishersActionContextData)data;
		context = actionContextData.context;
		OnActionStartTriggered(context);
		actionContextData.SetData(context);
	}
	
	public function OnActionStartTriggered(out context : XTFinishersActionContext);
}

abstract class XTFinishersAbstractActionEndEventListener extends XTFinishersPriorityListener {
	public final function OnEventTriggered(id : string, data : XTFinishersEventData) {
		var actionContextData : XTFinishersActionContextData;
		var context : XTFinishersActionContext;
		
		actionContextData = (XTFinishersActionContextData)data;
		context = actionContextData.context;
		OnActionEndTriggered(context);
		actionContextData.SetData(context);
	}
	
	public function OnActionEndTriggered(out context : XTFinishersActionContext);
}

abstract class XTFinishersAbstractReactionStartEventListener extends XTFinishersPriorityListener {
	public final function OnEventTriggered(id : string, data : XTFinishersEventData) {
		var actionContextData : XTFinishersActionContextData;
		var context : XTFinishersActionContext;
		
		actionContextData = (XTFinishersActionContextData)data;
		context = actionContextData.context;
		OnReactionStartTriggered(context);
		actionContextData.SetData(context);
	}
	
	public function OnReactionStartTriggered(out context : XTFinishersActionContext);
}

abstract class XTFinishersAbstractReactionEndEventListener extends XTFinishersPriorityListener {
	public final function OnEventTriggered(id : string, data : XTFinishersEventData) {
		var actionContextData : XTFinishersActionContextData;
		var context : XTFinishersActionContext;
		
		actionContextData = (XTFinishersActionContextData)data;
		context = actionContextData.context;
		OnReactionEndTriggered(context);
		actionContextData.SetData(context);
	}
	
	public function OnReactionEndTriggered(out context : XTFinishersActionContext);
}

abstract class XTFinishersAbstractFinisherEventListener extends XTFinishersPriorityListener {
	public final function OnEventTriggered(id : string, data : XTFinishersEventData) {
		var actionContextData : XTFinishersActionContextData;
		var context : XTFinishersActionContext;
		
		actionContextData = (XTFinishersActionContextData)data;
		context = actionContextData.context;
		OnFinisherTriggered(context);
		actionContextData.SetData(context);
	}
	
	public function OnFinisherTriggered(out context : XTFinishersActionContext);
}

abstract class XTFinishersAbstractDismemberEventListener extends XTFinishersPriorityListener {
	public final function OnEventTriggered(id : string, data : XTFinishersEventData) {
		var actionContextData : XTFinishersActionContextData;
		var context : XTFinishersActionContext;
		
		actionContextData = (XTFinishersActionContextData)data;
		context = actionContextData.context;
		OnDismemberTriggered(context);
		actionContextData.SetData(context);
	}
	
	public function OnDismemberTriggered(out context : XTFinishersActionContext);
}

abstract class XTFinishersAbstractFinisherCamEventListener extends XTFinishersPriorityListener {
	public final function OnEventTriggered(id : string, data : XTFinishersEventData) {
		var actionContextData : XTFinishersActionContextData;
		var context : XTFinishersActionContext;
		
		actionContextData = (XTFinishersActionContextData)data;
		context = actionContextData.context;
		OnFinisherCamTriggered(context);
		actionContextData.SetData(context);
	}
	
	public function OnFinisherCamTriggered(out context : XTFinishersActionContext);
}

class XTFinishersSlowdownSegmentData extends XTFinishersEventData {
	var segment : XTFinishersSlowdownSegment;
	var success : bool;
	
	public function SetData(segment : XTFinishersSlowdownSegment, optional success : bool) {
		this.segment = segment;
		this.success = success;
	}
}

abstract class XTFinishersAbstractSlowdownEventListener extends XTFinishersPriorityListener {
	private function HandleSequenceStart(data : XTFinishersActionContextData) {
		var context : XTFinishersActionContext;
		
		context = data.context;
		OnSlowdownSequenceStartTriggered(context);
		data.SetData(context);
	}
	
	private function HandleSequenceEnd(data : XTFinishersActionContextData) {
		var context : XTFinishersActionContext;
		
		context = data.context;
		OnSlowdownSequenceEndTriggered(context);
		data.SetData(context);
	}
	
	private function HandleSegmentStart(data : XTFinishersSlowdownSegmentData) {
		OnSlowdownSegmentStart(data.segment);
	}
	
	private function HandleSegmentEnd(data : XTFinishersSlowdownSegmentData) {
		OnSlowdownSegmentEnd(data.segment, data.success);
	}
	
	public final function OnEventTriggered(id : string, data : XTFinishersEventData) {
		switch (id) {
		case theGame.xtFinishersMgr.consts.SLOWDOWN_SEQUENCE_START_EVENT_ID :
			HandleSequenceStart(((XTFinishersActionContextData)data));
			break;
		case theGame.xtFinishersMgr.consts.SLOWDOWN_SEQUENCE_END_EVENT_ID :
			HandleSequenceEnd(((XTFinishersActionContextData)data));
			break;
		case theGame.xtFinishersMgr.consts.SLOWDOWN_SEGMENT_START_EVENT_ID :
			HandleSegmentStart(((XTFinishersSlowdownSegmentData)data));
			break;
		case theGame.xtFinishersMgr.consts.SLOWDOWN_SEGMENT_END_EVENT_ID :
			HandleSegmentEnd(((XTFinishersSlowdownSegmentData)data));
			break;
		}
	}
	
	public function OnSlowdownSequenceStartTriggered(out context : XTFinishersActionContext);
	public function OnSlowdownSequenceEndTriggered(out context : XTFinishersActionContext);
	
	public function OnSlowdownSegmentStart(segment : XTFinishersSlowdownSegment);
	public function OnSlowdownSegmentEnd(segment : XTFinishersSlowdownSegment, success : bool);
}