event eMonitor_LeaseAppliedSafelyInitialize;
event eWhitehallLeaseGranted: int;
event eWhitehallLeaseReleased: int;
event eWhitehallLeaseTimedOut: int;

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
      }
    }
}

spec DeadLeasesTimeout observes eWhitehallLeaseGranted, eWhitehallLeaseReleased, eWhitehallLeaseTimedOut {
  var leases: set[int];
  start state Init {
    entry {
      goto LeasesClear;
    }
  }

  hot state LeasesHeld
  {
    on eWhitehallLeaseGranted do (editionId: int) {
      leases += (editionId);
    }

    on eWhitehallLeaseReleased do (editionId: int) {
      leases -= (editionId);
      if (sizeof(leases) == 0) {
        goto LeasesClear;
      }
    }

    on eWhitehallLeaseTimedOut do (editionId: int) {
      leases -= (editionId);
      if (sizeof(leases) == 0) {
        goto LeasesClear;
      }
    }
  }

  cold state LeasesClear {
    on eWhitehallLeaseGranted do (editionId: int){
      leases += (editionId);
      goto LeasesHeld;
    }

    // This can happen in the event that a lease times out whilst Whitehall is in the process of writing to the edition.
    // In that case we can ignore the timeout.
    ignore eWhitehallLeaseTimedOut;
  }
}
