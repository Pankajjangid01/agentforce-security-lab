public with sharing class ValidateOrderApex {

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
        public Boolean isValid;
        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Validate Order' description='Validates incoming order data')
    public static List<Result> validateOrder(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            r.isValid = false;
            String num = req.orderNumber == null ? '' : req.orderNumber.trim();

            if (!Pattern.matches('^[A-Za-z0-9-]{3,30}$', num)) {
                r.message = 'Invalid order number format.';
            } else {
                Decimal amount;
                try {
                    amount = Decimal.valueOf(req.totalAmount == null ? '' : req.totalAmount.trim());
                } catch (Exception e) {
                    amount = null;
                }
                if (amount == null || amount <= 0) {
                    r.message = 'Total amount must be a positive number.';
                } else {
                    String acc = req.accountName == null ? '' : req.accountName.trim();
                    Integer accCount = [SELECT COUNT() FROM Account WHERE Name = :acc WITH SYSTEM_MODE];
                    Integer dupCount = [SELECT COUNT() FROM Order WHERE OrderReferenceNumber = :num WITH SYSTEM_MODE];
                    if (accCount == 0) {
                        r.message = 'Account not found.';
                    } else if (dupCount > 0) {
                        r.message = 'Duplicate order number.';
                    } else {
                        r.isValid = true;
                        r.message = 'Order is valid.';
                    }
                }
            }
            results.add(r);
        }
        return results;
    }
}