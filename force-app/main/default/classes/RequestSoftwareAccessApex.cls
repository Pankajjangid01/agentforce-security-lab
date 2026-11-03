public with sharing class RequestSoftwareAccessApex {

    public class Request {
        @InvocableVariable(required=true)
        public String employeeId;
        @InvocableVariable(required=true)
        public String softwareName;
    }

    public class Result {
        @InvocableVariable
        public String requestId;
    }

    @InvocableMethod(label='Request Software Access' description='Logs a software access request for a verified employee')
    public static List<Result> requestAccess(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            String key = req.employeeId == null ? '' : req.employeeId.trim();
            Integer matches = String.isBlank(key) ? 0
                : [SELECT COUNT() FROM User WHERE EmployeeNumber = :key AND IsActive = true WITH SYSTEM_MODE];

            if (matches == 0) {
                r.requestId = 'Employee not found. No request was created.';
            } else {
                Case c = new Case();
                c.Subject = ('Software access request - ' + req.softwareName + ' - ' + key).abbreviate(255);
                c.Description = 'Software access requested through the IT Helpdesk agent. Employee: ' + key + '. Software: ' + req.softwareName;
                c.Origin = 'Web';
                c.Priority = 'Medium';
                Database.insert(c, AccessLevel.SYSTEM_MODE);
                Case created = [SELECT CaseNumber FROM Case WHERE Id = :c.Id WITH SYSTEM_MODE LIMIT 1];
                r.requestId = created.CaseNumber;
            }
            results.add(r);
        }
        return results;
    }
}