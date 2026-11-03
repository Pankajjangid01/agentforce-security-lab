public with sharing class ResetPasswordApex {

    public class Request {
        @InvocableVariable(required=true)
        public String employeeId;
    }

    public class Result {
        @InvocableVariable
        public String result;
    }

    @InvocableMethod(label='Reset Password' description='Logs a password reset request for a verified employee (lab simulation)')
    public static List<Result> resetPassword(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            String key = req.employeeId == null ? '' : req.employeeId.trim();
            Integer matches = String.isBlank(key) ? 0
                : [SELECT COUNT() FROM User WHERE EmployeeNumber = :key AND IsActive = true WITH SYSTEM_MODE];

            if (matches == 0) {
                r.result = 'Employee not found. No reset was started.';
            } else {
                Case c = new Case();
                c.Subject = ('Password reset requested - ' + key).abbreviate(255);
                c.Description = 'Password reset requested through the IT Helpdesk agent for employee ' + key + '. (Lab simulation, no real password was changed.)';
                c.Origin = 'Web';
                c.Priority = 'Medium';
                Database.insert(c, AccessLevel.SYSTEM_MODE);
                Case created = [SELECT CaseNumber FROM Case WHERE Id = :c.Id WITH SYSTEM_MODE LIMIT 1];
                r.result = 'Password reset request logged. Reference ' + created.CaseNumber + '.';
            }
            results.add(r);
        }
        return results;
    }
}