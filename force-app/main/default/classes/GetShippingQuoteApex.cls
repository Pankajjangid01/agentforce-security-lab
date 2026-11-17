public with sharing class GetShippingQuoteApex {

    public class Request {
        @InvocableVariable(required=true label='Postal Code' description='Destination postal code')
        public String postalCode;
        @InvocableVariable(required=true label='Weight (kg)' description='Package weight in kilograms')
        public Decimal weightKg;
    }

    public class Result {
        @InvocableVariable public String status;
        @InvocableVariable public String carrier;
        @InvocableVariable public Decimal price;
        @InvocableVariable public String currencyCode;
        @InvocableVariable public Integer etaDays;
    }

    @InvocableMethod(label='Get Shipping Quote' description='Calls the external shipping quote tool and returns carrier, price and ETA')
    public static List<Result> getQuote(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            try {
                HttpRequest httpReq = new HttpRequest();
                httpReq.setEndpoint('callout:NC_ExternalTool/tools/shipping-quote');
                httpReq.setMethod('POST');
                httpReq.setHeader('Content-Type', 'application/json');
                httpReq.setTimeout(10000);
                httpReq.setBody(JSON.serialize(new Map<String, Object>{
                    'postalCode' => req.postalCode,
                    'weightKg' => req.weightKg
                }));
                HttpResponse res = new Http().send(httpReq);
                if (res.getStatusCode() == 200) {
                    Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    r.carrier = String.valueOf(body.get('carrier'));
                    r.price = Decimal.valueOf(String.valueOf(body.get('price')));
                    r.currencyCode = String.valueOf(body.get('currency'));
                    r.etaDays = Integer.valueOf(String.valueOf(body.get('etaDays')));
                    r.status = 'Quote received';
                } else {
                    r.status = 'External tool returned an error (' + res.getStatusCode() + ')';
                }
            } catch (Exception e) {
                r.status = 'External tool unavailable';
            }
            results.add(r);
        }
        return results;
    }
}
