event eMonitor_LeaseAppliedSafelyInitialize;

spec LeaseAppliedSafely observes eLeaseRequestResponse, eWriteRequestResponse, eMonitor_LeaseAppliedSafelyInitialize
{
    var leases: map[int, int];
    start state Init {
      on eMonitor_LeaseAppliedSafelyInitialize goto WaitForEvents;
    }

    state WaitForEvents {
      on eLeaseRequestResponse do (resp: tLeaseResponse){
          if (resp.status == SUCCESS) {
              leases[resp.editionId] = resp.userId;
          }
      }

      on eWriteRequestResponse do (resp: tWriteResponse) {
        if (resp.status == SUCCESS) {
          assert (resp.editionId in leases && leases[resp.editionId] == resp.userId),
            format("Write requests should not be accepted when user does not hold the lease");
          leases -= resp.editionId;
        }
        if (resp.status == ERROR) {
          assert (!(resp.editionId in leases) || leases[resp.editionId] != resp.userId),
            format("Write requests should be accepted when user holds the lease");
        }
      }
    }
}

/**************************************************************************
Every received transaction from a client must be eventually responded back.
Note, the usage of hot and cold states.
***************************************************************************/
spec Progress observes eWriteRequestReceived, eWriteRequestResponse {
  var pendingTransactions: int;
  start state Init {
    on eWriteRequestReceived goto WaitForResponses with { pendingTransactions = 1; }
  }

  hot state WaitForResponses
  {
    on eWriteRequestResponse do {
      pendingTransactions = pendingTransactions - 1;
      if(pendingTransactions == 0)
      {
        goto AllTransactionsFinished;
      }
    }

    on eWriteRequestReceived do { pendingTransactions = pendingTransactions + 1; }
  }

  cold state AllTransactionsFinished {
    on eWriteRequestReceived goto WaitForResponses with { pendingTransactions = pendingTransactions + 1; }
  }
}
