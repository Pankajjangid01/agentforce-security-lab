public with sharing class CreateOrderRecordApex {

    public class Request {
        @InvocableVariable(required=true)
        public String orderNumber;
        @InvocableVariable(required=true)
        public String accountName;
        @InvocableVariable(required=true)
        public String totalAmount;
    }

    public class Result {
        @InvocableVariable
        public String orderId;
    }

    @InvocableMethod(label='Create Order Record' description='Creates a draft Order record')
    public static List<Result> createOrder(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            String acc = req.accountName == null ? '' : req.accountName.trim();
            List<Account> accounts = [SELECT Id FROM Account WHERE Name = :acc WITH SYSTEM_MODE LIMIT 1];
            if (!accounts.isEmpty()) {
                Order o = new Order();
                o.AccountId = accounts[0].Id;
                o.EffectiveDate = Date.today();
                o.Status = 'Draft';
                o.OrderReferenceNumber = req.orderNumber.trim();
                o.Description = 'Created by Order Processor agent. Total amount: ' + req.totalAmount;
                Database.insert(o, AccessLevel.SYSTEM_MODE);
                r.orderId = o.Id;
            }
            results.add(r);
        }
        return results;
    }
}