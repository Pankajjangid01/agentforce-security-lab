public with sharing class CreateCaseApex {

    public class Request {
        @InvocableVariable(required=true)
        public String subject;
        @InvocableVariable
        public String description;
        @InvocableVariable
        public String contactId;
    }

    public class Result {
        @InvocableVariable
        public String caseId;
        @InvocableVariable
        public String caseNumber;
    }

    @InvocableMethod(label='Create Support Case' description='Creates a new support case for the customer')
    public static List<Result> createCase(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Case c = new Case();
            c.Subject = req.subject;
            c.Description = req.description;
            c.Origin = 'Web';
            c.Status = 'New';
            if (String.isNotBlank(req.contactId) && req.contactId.length() >= 15) {
                c.ContactId = req.contactId;
            }
            Database.insert(c, AccessLevel.SYSTEM_MODE);

            Case created = [SELECT Id, CaseNumber FROM Case WHERE Id = :c.Id WITH SYSTEM_MODE LIMIT 1];
            Result r = new Result();
            r.caseId = created.Id;
            r.caseNumber = created.CaseNumber;
            results.add(r);
        }
        return results;
    }
}