machine PublishingApi
{
    var record: int;

    start state WaitingForRequests {
        entry {
            record = 0;
        }
        on ePublishingApiRequest do (client: Whitehall) {
            if ($) {
                record = 1;
                send client, ePublishingApiResponse, SUCCESS;
            }
            else {
                if ($) {
                    record = 1;
                }
                send client, ePublishingApiResponse, TIMEOUT;
            }
            
        }
    }
}