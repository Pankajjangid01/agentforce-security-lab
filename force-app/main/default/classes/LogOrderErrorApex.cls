public with sharing class LogOrderErrorApex {

    public class Request {  
        @InvocableVariable
        public String orderNumber;
        @InvocableVariable
        public String errorMessage;
    }

    public class Result {
        @InvocableVariable
        public Boolean logged;
    }

    @InvocableMethod(label='Log Order Error' description='Writes an order processing error log (Case record)')
    public static List<Result> logError(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Case c = new Case();
            c.Subject = ('Order processing error - ' + (req.orderNumber == null ? 'unknown' : req.orderNumber)).abbreviate(255);
            c.Description = req.errorMessage;
            c.Origin = 'Web';
            c.Priority = 'High';
            Database.insert(c, AccessLevel.SYSTEM_MODE);
            Result r = new Result();
            r.logged = true;
            results.add(r);
        }
        return results;
    }
}