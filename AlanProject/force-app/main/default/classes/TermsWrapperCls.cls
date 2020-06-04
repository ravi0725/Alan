/*****************************************************************************************
    Name    : TermsWrapperCls 
    Desc    : TermsWrapperCls class is a wrapper class. It is used to work on Terms records
              displayed on Terms page.                               
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta            2/28/2014          Created
******************************************************************************************/
public class TermsWrapperCls {
     
     public Term__c cTerms {get;set;}
     public Integer rowIndex {get;set;}
     public Boolean isSelected {get;set;}
     
     /**
     * Method name  : TermsWrapperCls 
     * Description  : Its a parameterised Constructor of the Controller class - Initializes all the variables.
     *                
     * Return Type  : Void
     * Parameter    : Term__c
     **/
     public TermsWrapperCls (Term__c cTerms ){
        this.cTerms = cTerms;
     }
}