machine TestWhitehallConsistentWithPubApi
{
    var app: Whitehall;
    var database: WhitehallDatabase;
    var publishingApi: PublishingApi;

    start state Init {
        entry {
            database = new WhitehallDatabase();
            publishingApi = new PublishingApi();
            app = new Whitehall((database = database, publishingApi = publishingApi));
        }
    }
}