public with sharing class NotifyFulfillmentApex {

    public class Request {
        @InvocableVariable(required=true)
        public String orderId;
        @InvocableVariable(required=true)
        public String orderNumber;
    }

    public class Result {
        @InvocableVariable
        public String status;
    }

    @InvocableMethod(label='Notify Fulfillment' description='Sends the order to the external fulfillment webhook')
    public static List<Result> notifyFulfillment(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            try {
                HttpRequest httpReq = new HttpRequest();
                httpReq.setEndpoint('callout:NC_Fulfillment/orders');
                httpReq.setMethod('POST');
                httpReq.setHeader('Content-Type', 'application/json');
                httpReq.setBody(JSON.serialize(new Map<String, String>{
                    'orderId' => req.orderId,
                    'orderNumber' => req.orderNumber
                }));
                httpReq.setTimeout(10000);
                HttpResponse res = new Http().send(httpReq);
                r.status = (res.getStatusCode() >= 200 && res.getStatusCode() < 300)
                    ? 'Fulfillment notified' : 'Fulfillment service returned an error';
            } catch (Exception e) {
                r.status = 'Fulfillment service unavailable';
            }
            results.add(r);
        }
        return results;
    }
}