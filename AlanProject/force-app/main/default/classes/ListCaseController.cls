//This controller is used for Planning Priority VF based Email Template - GCCM
//This controller finds the related cases (SI) based on defect__c field on a Case record 
//This controller interacts with VF Component and VF Component interacts (relatedcases) with VF Email Template (Priority_Case_Template_Ad)

public class ListCaseController {

public Id cId {get;set;}
public String recType {get;set;}

public List<Case> getCases (){
    List<Case> cases;
    try{
        Id recordTypeId = [select Id from RecordType where name =:recType][0].Id;
        
        cases = [SELECT CaseNumber,Id, defect__c, RecordTypeId,Product__c, Owner.name, Product.name,Application__c, Status,Subject,description,
        Fixed_in_Build_PLM__c FROM Case where //RecordTypeId =:recordTypeId and// 
         defect__c=:cId];
    }catch(Exception e){
        cases = new List<Case>();
        System.debug('Error '+e.getStackTraceString());
    }
    return cases;
}
}