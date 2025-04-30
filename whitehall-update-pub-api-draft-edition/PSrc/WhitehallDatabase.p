machine WhitehallDatabase
{
    var record:int;
    start state WaitingForTransactions {
        entry {
            record = 0;
        }
        on eWhitehallOpenDatabaseTransactionRequest do (client: Whitehall) {
            send client, eWhitehallOpenDatabaseTransactionResponse;
            goto TransactionInProgress;
        }
    }

    state TransactionInProgress {
        on eWhitehallUpdateDatabaseRequest do (client: Whitehall) {
            record = 1;
            send client, eWhitehallUpdateDatabaseResponse;
        }

        on eWhitehallCommitDatabaseTransactionRequest do (client: Whitehall) {
            send client, eWhitehallCommitDatabaseTransactionResponse;
            goto TransactionComplete;
        }

        on eWhitehallRollbackDatabaseTransactionRequest do (client: Whitehall) {
            record = 0;
            send client, eWhitehallRollbackDatabaseTransactionResponse;
            goto TransactionComplete;
        }
    }

    state TransactionComplete {

    }
}