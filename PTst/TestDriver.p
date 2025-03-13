machine TestWhitehallLeasing
{
  var app: WhitehallApp;
  var editionIds: set[int];
  var numUsers: int;
  var numEditions: int;
  var i: int;

  start state Init {
    entry {
      numEditions = 5;
      i = 0;
      while (i < numEditions) {
        editionIds += (i + 1);
        i = i + 1;
      }

      app = new WhitehallApp();
      announce eMonitor_LeaseAppliedSafelyInitialize;

      numUsers = 3;
      i = 0;
      while (i < numUsers) {
        new Client((app = app, userId = i, editionIds = editionIds, numTransactions = 10));
        i = i + 1;
      }
    }
  }
}