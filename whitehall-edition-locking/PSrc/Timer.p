/*****************************************************************************************
The timer state machine models the non-deterministic behavior of an OS timer
******************************************************************************************/

/************************************************
Events used to interact with the timer machine
************************************************/
event eStartTimer;
event eCancelTimer;
event eTimeOut: int;
event eDelayedTimeOut;

machine Timer {
  // user/client of the timer
  var client: machine;
  var editionId: int;

  start state Init {
    entry (payload: (_client : machine, _editionId: int)) {
      client = payload._client;
      editionId = payload._editionId;
      goto TimerRunning;
    }
  }

  state TimerRunning {
    entry {
      if($) {
        send client, eTimeOut, editionId;
        raise halt;
      } else {
        send this, eDelayedTimeOut;
      }
    }

    on eDelayedTimeOut goto TimerRunning;
    on eCancelTimer do {
      raise halt;
    }
  }
}

/************************************************
Functions or API's to interact with the OS Timer
*************************************************/
// create timer
fun CreateTimer(client: machine, editionId: int) : Timer {
  return new Timer((_client = client, _editionId = editionId));
}

// cancel timer
fun CancelTimer(timer: Timer) {
  send timer, eCancelTimer;
}