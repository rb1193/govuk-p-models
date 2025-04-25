test tcPubApiLocking [main=TestPubApiOptimisticLocking]:
  assert LockAppliedSafely, EnsureAllTransactionsAreProcessed in
  (union PubApi, { TestPubApiOptimisticLocking });