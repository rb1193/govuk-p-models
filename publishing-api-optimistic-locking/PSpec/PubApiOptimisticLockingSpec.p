event eMonitor_LockAppliedSafelyInitialize: int;

spec LockAppliedSafely observes eMonitor_LockAppliedSafelyInitialize, eResponse
{
  var editionVersions: map[int,int];
  var i: int;
  start state Init {

    on eMonitor_LockAppliedSafelyInitialize goto WaitForEvents with (numEditions: int) {
      i = 0;
      while (i < numEditions) {
          editionVersions[i] = 0;
          i = i + 1;
      }
    }
  }

  state WaitForEvents {
    on eResponse do (resp: tResponse) {
      if (resp.status == SUCCESS) {
        assert (editionVersions[resp.editionId] <= resp.previousVersion), format("Request should only succeed if previous version is equal to or greater than latest known version of edition");
        
      }
      if (resp.status == CONFLICT) {
        assert (editionVersions[resp.editionId] > resp.previousVersion), format("Request should return a conflict error if latest known version is greater than the previous version from the request");
      }
      editionVersions[resp.editionId] = resp.currentVersion;
    }
  }
}

spec EnsureAllTransactionsAreProcessed observes eRequest, eResponse {
  var pendingTransactions: int;
  start state Init {
    on eRequest goto WaitForResponses with { pendingTransactions = pendingTransactions + 1; }
  }

  hot state WaitForResponses
  {
    on eResponse do {
      pendingTransactions = pendingTransactions - 1;
      if(pendingTransactions == 0)
      {
        goto AllTransactionsFinished;
      }
    }

    on eRequest do { pendingTransactions = pendingTransactions + 1; }
  }

  cold state AllTransactionsFinished {
    on eRequest goto WaitForResponses with { pendingTransactions = pendingTransactions + 1; }
  }
}
