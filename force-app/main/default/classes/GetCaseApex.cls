public with sharing class GetCaseApex {

    public class Request {
        @InvocableVariable(required=true)
        public String caseId;
    }

    public class Result {
        @InvocableVariable
        public String caseNumber;
        @InvocableVariable
        public String subject;
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String description;
    }

    @InvocableMethod(label='Get Support Case' description='Retrieves a support case by Id or case number')
    public static List<Result> getCase(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            String key = req.caseId == null ? '' : req.caseId.trim();
            List<Case> found = new List<Case>();

            if (String.isNotBlank(key)) {
                if ((key.length() == 15 || key.length() == 18) && key.startsWith('500')) {
                    found = [SELECT CaseNumber, Subject, Status, Description FROM Case WHERE Id = :key WITH SYSTEM_MODE LIMIT 1];
                } else {
                    found = [SELECT CaseNumber, Subject, Status, Description FROM Case WHERE CaseNumber = :key WITH SYSTEM_MODE LIMIT 1];
                }
            }

            if (found.isEmpty()) {
                r.status = 'Not found';
            } else {
                r.caseNumber = found[0].CaseNumber;
                r.subject = found[0].Subject;
                r.status = found[0].Status;
                r.description = found[0].Description;
            }
            results.add(r);
        }
        return results;
    }
}