public with sharing class FindOrderApex {

    public class Request {
        @InvocableVariable(required=true label='Order Number' description='Order number such as 00000101, or the order reference number')
        public String orderNumber;
    }

    public class Result {
        @InvocableVariable public Boolean found;
        @InvocableVariable public String orderId;
    }

    @InvocableMethod(label='Find Order' description='Finds an order by order number or order reference number and returns its record Id')
    public static List<Result> findOrder(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            r.found = false;
            if (req != null && String.isNotBlank(req.orderNumber)) {
                String key = req.orderNumber.trim();
                List<Order> rows = [
                    SELECT Id FROM Order
                    WHERE OrderNumber = :key OR OrderReferenceNumber = :key
                    WITH SYSTEM_MODE
                    LIMIT 1
                ];
                if (!rows.isEmpty()) {
                    r.found = true;
                    r.orderId = String.valueOf(rows[0].Id);
                }
            }
            results.add(r);
        }
        return results;
    }
}
