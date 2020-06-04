public class UpdateIssueOwneronCase {

@InvocableMethod
    Public static void IssueOwnerupdate(List<case> caseList){
        set<id> parentcaseId = new set<Id>();
        for(case cs:caseList){
            if(cs.Defect__c != null && cs.Priority1_Follow_up__c == TRUE){
                parentcaseId.add(cs.Defect__c);
            }
        }
        if(parentcaseid.size() > 0 ){
        List<Case> caseslistold = [SELECT Id, OwnerId, Owner.email FROM Case WHERE Id in : parentcaseId];
        for(Id csIdtoUpdate:parentcaseId){
            if(caseslistold.size() > 0){
               for(Case cas:caseslistold){
               for(case cs:caseList){
               cs.Product_Lead__c=cas.ownerId;
               cs.P1_Product_Lead_Email__c = cas.Owner.email;
                        }
                    }
                }
            }
        }
    }

}