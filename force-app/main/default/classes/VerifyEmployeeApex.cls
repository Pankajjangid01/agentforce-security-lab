public with sharing class VerifyEmployeeApex {

    public class Request {
        @InvocableVariable(required=true)
        public String employeeId;
    }

    public class Result {
        @InvocableVariable
        public Boolean isValid;
    }

    @InvocableMethod(label='Verify Employee' description='Checks the employee ID against active users')
    public static List<Result> verifyEmployee(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            String key = req.employeeId == null ? '' : req.employeeId.trim();
            Integer matches = 0;
            if (String.isNotBlank(key)) {
                matches = [SELECT COUNT() FROM User WHERE EmployeeNumber = :key AND IsActive = true WITH SYSTEM_MODE];
            }
            r.isValid = matches > 0;
            results.add(r);
        }
        return results;
    }
}