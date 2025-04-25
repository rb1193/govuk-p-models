machine TestPubApiOptimisticLocking
{
  var app: App;
  var editionIds: set[int];
  var numClients: int;
  var numEditions: int;
  var numVersions: int;
  var i: int;

  start state Init {
    entry {
      numEditions = 3;

      app = new App(numEditions);
      announce eMonitor_LockAppliedSafelyInitialize, numEditions;

      numClients = 2;
      i = 0;
      while (i < numClients) {
        new Client((app = app, numEditions = numEditions, numVersions = 5));
        i = i + 1;
      }
    }
  }
}