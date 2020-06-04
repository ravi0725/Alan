Public Class DlinkAccount{
    Public String AccId {get;set;}
    /*
* Method name  : DlinkAccount
* Description  : Constructor to initilize the values
* Return Type  : NA
* Parameter    : NA
*/  
    public DlinkAccount(){
        //get the Account id from the Account Detail Page
        AccId = System.currentPageReference().getParameters().get('id');  
        
    }
    /*
* Method name  : UpdateChildRecords
* Description  : Makes all the FCH ID Fields of Contact and Address as Blank
* Return Type  : NA
* Parameter    : NA
*/  
    public PageReference UpdateChildRecords(){
        List<String> accIdList = new List<String>();
        accIdList.add(AccId);
        AccountCreationCalloutEX.dLinkAccountFlag = true;
        AccountCreationCalloutEX.makeCallOut(accIdList,'DLink','NoOp','NoOp',new set<String>(),new set<String>(),new set<String>());
        PageReference pageRef = new PageReference('/'+AccId);
        return pageRef;
        
    }
}