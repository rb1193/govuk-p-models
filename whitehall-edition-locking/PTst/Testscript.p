test tcWhitehallLeasing [main=TestWhitehallLeasing]:
  assert LeaseAppliedSafely, DeadLeasesTimeout in
  (union WhitehallModule, { TestWhitehallLeasing });