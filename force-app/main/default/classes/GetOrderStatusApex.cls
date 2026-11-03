public with sharing class GetOrderStatusApex {

    public class Request {
        @InvocableVariable(required=true)
        public String orderId;
    }

    public class Result {
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String estimatedDelivery;
        @InvocableVariable
        public String trackingNumber;
    }

    @InvocableMethod(label='Get Order Status' description='Looks up order status from the external orders API')
    public static List<Result> getOrderStatus(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            try {
                HttpRequest httpReq = new HttpRequest();
                httpReq.setEndpoint('callout:NC_OrderAPI/orders/' + EncodingUtil.urlEncode(req.orderId, 'UTF-8'));
                httpReq.setMethod('GET');
                httpReq.setTimeout(10000);
                HttpResponse res = new Http().send(httpReq);

                if (res.getStatusCode() == 200) {
                    Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    r.status = String.valueOf(body.get('status'));
                    r.estimatedDelivery = String.valueOf(body.get('estimatedDelivery'));
                    r.trackingNumber = String.valueOf(body.get('trackingNumber'));
                } else if (res.getStatusCode() == 404) {
                    r.status = 'Order not found';
                } else {
                    r.status = 'Order service returned an error';
                }
            } catch (Exception e) {
                r.status = 'Order service unavailable';
            }
            results.add(r);
        }
        return results;
    }
}