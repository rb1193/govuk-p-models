test tcWhitehallConsistentWithPubApi [main=TestWhitehallConsistentWithPubApi]:
  assert WhitehallDatabaseIsConsistentWithPublishingApi, AllRequestsProcessed in
  (union GovukPublishingModule, { TestWhitehallConsistentWithPubApi, Whitehall });