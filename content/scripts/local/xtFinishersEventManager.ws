
/*
	Event dispatcher for XTFinishers. Tracks and notifies event listeners. Listeners are added using the RegisterXXListener() functions. Events are triggered using the FireXXEvent functions.
	
	When an event is triggered, listeners are called in order according to the value returned by their GetPriority() function:
		- listener a is guaranteed to be called before listener b if and only if a.GetPriority() < b.GetPriority().
		- if a.GetPriority() == b.GetPriority() is true, there is no guarantee which one will be called first.
*/
class XTFinishersEventManager {
	private var actionEndListenerQueue, actionEndListenerQueue, reactionListenerQueue, finisherListenerQueue, dismemberListenerQueue, finisherCamListenerQueue, slowdownListenerQueue : XTFinishersPriorityListenerQueue;
	
	public function Init() {
		actionStartListenerQueue = new XTFinishersPriorityListenerQueue in this;
		actionEndListenerQueue = new XTFinishersPriorityListenerQueue in this;
		reactionListenerQueue = new XTFinishersPriorityListenerQueue in this;
		finisherListenerQueue = new XTFinishersPriorityListenerQueue in this;
		dismemberListenerQueue = new XTFinishersPriorityListenerQueue in this;
		finisherCamListenerQueue = new XTFinishersPriorityListenerQueue in this;
		slowdownListenerQueue = new XTFinishersPriorityListenerQueue in this;
	}
	
	public function GetSlowdownListenerQueueSize() : int {
		return slowdownListenerQueue.Size();
	}
	
	// register listeners
	
	public function RegisterActionStartListener(listener : XTFinishersAbstractActionStartEventListener) {
		actionStartListenerQueue.Add(listener);
	}
	
	public function RegisterActionEndListener(listener : XTFinishersAbstractActionEndEventListener) {
		actionEndListenerQueue.Add(listener);
	}
	
	public function RegisterReactionListener(listener : XTFinishersAbstractReactionEventListener) {
		reactionListenerQueue.Add(listener);
	}
	
	public function RegisterFinisherListener(listener : XTFinishersAbstractFinisherEventListener) {
		finisherListenerQueue.Add(listener);
	}
	
	public function RegisterDismemberListener(listener : XTFinishersAbstractDismemberEventListener) {
		dismemberListenerQueue.Add(listener);
	}
	
	public function RegisterFinisherCamListener(listener : XTFinishersAbstractFinisherCamEventListener) {
		finisherCamListenerQueue.Add(listener);
	}
	
	public function RegisterSlowdownListener(listener : XTFinishersAbstractSlowdownEventListener) {
		slowdownListenerQueue.Add(listener);
	}
	
	// fire events
	
	public function FireActionStartEvent(out context : XTFinishersActionContext) {
		var i : int;
		
		for (i = 0; i < actionStartListenerQueue.Size(); i += 1) {
			((XTFinishersAbstractActionStartEventListener)actionStartListenerQueue.Get(i)).OnActionStartTriggered(context);
		}
	}
	
	public function FireActionEndEvent(out context : XTFinishersActionContext) {
		var i : int;
		
		for (i = 0; i < actionStartListenerQueue.Size(); i += 1) {
			((XTFinishersAbstractActionEndEventListener)actionEndListenerQueue.Get(i)).OnActionEndTriggered(context);
		}
	}
	
	public function FireReactionStartEvent(out context : XTFinishersActionContext) {
		var i : int;
		
		for (i = 0; i < reactionListenerQueue.Size(); i += 1) {
			((XTFinishersAbstractReactionEventListener)reactionListenerQueue.Get(i)).OnReactionStartTriggered(context);
		}
	}
	
	public function FireReactionEndEvent(out context : XTFinishersActionContext) {
		var i : int;
		
		for (i = 0; i < reactionListenerQueue.Size(); i += 1) {
			((XTFinishersAbstractReactionEventListener)reactionListenerQueue.Get(i)).OnReactionEndTriggered(context);
		}
	}
	
	public function FireFinisherEvent(out context : XTFinishersActionContext) {
		var i : int;
		
		for (i = 0; i < finisherListenerQueue.Size(); i += 1) {
			((XTFinishersAbstractFinisherEventListener)finisherListenerQueue.Get(i)).OnFinisherTriggered(context);
		}
	}
	
	public function FireDismemberEvent(out context : XTFinishersActionContext) {
		var i : int;
		
		for (i = 0; i < dismemberListenerQueue.Size(); i += 1) {
			((XTFinishersAbstractDismemberEventListener)dismemberListenerQueue.Get(i)).OnDismemberTriggered(context);
		}
	}
	
	public function FireFinisherCamEvent(out context : XTFinishersActionContext) {
		var i : int;
		
		for (i = 0; i < finisherCamListenerQueue.Size(); i += 1) {
			((XTFinishersAbstractFinisherCamEventListener)finisherCamListenerQueue.Get(i)).OnFinisherCamTriggered(context);
		}
	}
	
	public function FireSlowdownTriggerEvent(out context : XTFinishersActionContext) {
		var i : int;
		
		for (i = 0; i < slowdownListenerQueue.Size(); i += 1) {
			((XTFinishersAbstractSlowdownEventListener)slowdownListenerQueue.Get(i)).OnSlowdownTriggered(context);
		}
	}
	
	public function FireSlowdownStartEvent(factor : float, duration : float, id : string) {
		var i : int;
		
		for (i = 0; i < slowdownListenerQueue.Size(); i += 1) {
			((XTFinishersAbstractSlowdownEventListener)slowdownListenerQueue.Get(i)).OnSlowdownStart(factor, duration, id);
		}
	}
	
	public function FireSlowdownEndEvent(success : bool, id : string) {
		var i : int;

		for (i = 0; i < slowdownListenerQueue.Size(); i += 1) {
			((XTFinishersAbstractSlowdownEventListener)slowdownListenerQueue.Get(i)).OnSlowdownEnd(success, id);
		}
	}
}

class XTFinishersEffectsSnapshot {
	private var effectsTable : array<bool>;
	
	public function Initialize(actor : CActor) {
		var effects : array<CBaseGameplayEffect>;
		var i : int;
		
		effectsTable.Grow(EnumGetMax('EEffectType') + 1);
		for (i=0; i<effectsTable.Size(); i+=1) {
			effectsTable[i] = false;
		}
		
		effects = actor.GetBuffs();
		for (i=0; i<effects.Size(); i+=1) {
			effectsTable[effects[i].GetEffectType()] = true;
		}
	}
	
	public function HasEffect(type : EEffectType) : bool {
		return effectsTable[type];
	}
}

struct XTFinishersActionContext {
	var action : W3DamageAction;
	var effectsSnapshot : XTFinishersEffectsSnapshot;
	var finisher : XTFinishersFinisherContext;
	var dismember : XTFinishersDismemberContext;
	var finisherCam : XTFinishersFinisherCamContext;
	var slowdown : XTFinishersSlowdownContext;
}

struct XTFinishersFinisherContext {
	var active : bool;										// will finisher be performed
	var auto : bool;										// is AUTOMATIC finisher
	var instantKill : bool;									// is INSTANT-KILL finisher
	var forced : bool;										// is FORCED finisher
};

struct XTFinishersDismemberContext {
	var active : bool;										// will dismember be performed
	var explosion : bool;									// is dismember explosion
	var camShake : bool;									// do camera shake
	var auto : bool;										// is AUTOMATIC finisher
	var forced : bool;										// is FORCED dismember
};

struct XTFinishersFinisherCamContext {
	var active : bool;										// will cinematic camera be activated
};

struct XTFinishersSlowdownContext {
	var isFinisher, isDismember : bool;						// whether finisher or dismember triggered slowdown
	var active : bool;										// will slowdown be performed
};

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

class XTFinishersPriorityListener {
	private var priority : int;
	
	public function Init(priorityArg : int) {
		priority = priorityArg;
	}
	
	public function GetPriority() : int {
		return priority;
	}
}

class XTFinishersAbstractActionStartEventListener extends XTFinishersPriorityListener {
	public function OnActionStartTriggered(out context : XTFinishersActionContext) {}
}

class XTFinishersAbstractActionEndEventListener extends XTFinishersPriorityListener {
	public function OnActionEndTriggered(out context : XTFinishersActionContext) {}
}

class XTFinishersAbstractReactionEventListener extends XTFinishersPriorityListener {
	public function OnReactionStartTriggered(out context : XTFinishersActionContext) {}
	public function OnReactionEndTriggered(out context : XTFinishersActionContext) {}
}

class XTFinishersAbstractFinisherEventListener extends XTFinishersPriorityListener {
	public function OnFinisherTriggered(out context : XTFinishersActionContext) {}
}

class XTFinishersAbstractDismemberEventListener extends XTFinishersPriorityListener {
	public function OnDismemberTriggered(out context : XTFinishersActionContext) {}
}

class XTFinishersAbstractFinisherCamEventListener extends XTFinishersPriorityListener {
	public function OnFinisherCamTriggered(out context : XTFinishersActionContext) {}
}

class XTFinishersAbstractSlowdownEventListener extends XTFinishersPriorityListener {
	public function OnSlowdownTriggered(out context : XTFinishersActionContext) {}
	
	// factor : time factor
	// duration : duration of slowdown
	// id : identifier string assigned to the slowdown session that started.
	public function OnSlowdownStart(factor : float, duration : float, id : string) {}
	
	// success : if the slowdown session timed out as intended (i.e. it was not terminated prematurely)
	// id : identifier string assigned to the slowdown session that ended.
	public function OnSlowdownEnd(success : bool, id : string) {}
}