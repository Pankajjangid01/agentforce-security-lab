public with sharing class CreateIncidentApex {

    public class Request {
        @InvocableVariable(required=true)
        public String employeeId;
        @InvocableVariable(required=true)
        public String description;
    }

    public class Result {
        @InvocableVariable
        public String incidentId;
    }

    @InvocableMethod(label='Create IT Incident' description='Creates an IT incident record for a verified employee')
    public static List<Result> createIncident(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            String key = req.employeeId == null ? '' : req.employeeId.trim();
            Integer matches = String.isBlank(key) ? 0
                : [SELECT COUNT() FROM User WHERE EmployeeNumber = :key AND IsActive = true WITH SYSTEM_MODE];

            if (matches == 0) {
                r.incidentId = 'Employee not found. No incident was created.';
            } else {
                Case c = new Case();
                c.Subject = ('IT incident - ' + key).abbreviate(255);
                c.Description = req.description;
                c.Origin = 'Web';
                c.Priority = 'High';
                Database.insert(c, AccessLevel.SYSTEM_MODE);
                Case created = [SELECT CaseNumber FROM Case WHERE Id = :c.Id WITH SYSTEM_MODE LIMIT 1];
                r.incidentId = created.CaseNumber;
            }
            results.add(r);
        }
        return results;
    }
}