/************************************************************************************
* Name          :    AccountProductAuthorizationController
* Description   :    
* Author        :    Ashfaq

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
9/5/2013                   Ashfaq                  Created
*/

public class AccountProductAuthorizationController {
   Public Id AccountID; 
   public List<Account_Product_Authorization__c> authorizationList{get;set;} 
   public List<Account_Product_Authorization__c> oldAuthorizationList;
   
   public AccountProductAuthorizationController(ApexPages.StandardSetController controller){
       authorizationList = new List<Account_Product_Authorization__c>();
       oldAuthorizationList = new List<Account_Product_Authorization__c>();
       
       authorizationList.add(new Account_Product_Authorization__c());
       authorizationList.add(new Account_Product_Authorization__c());
       authorizationList.add(new Account_Product_Authorization__c());
       authorizationList.add(new Account_Product_Authorization__c());
       authorizationList.add(new Account_Product_Authorization__c());
       AccountID = ApexPages.CurrentPage().getParameters().get('id');
       //authorizationList = [Select Id, Product_Authorization__c, User__c from Account_Product_Authorization__c];   
       system.debug('oldAuthorizationList-->' + oldAuthorizationList);
   }
   
   public pageReference save(){
   	
   	
   	
   	//To check if the duplicate user is selected on visualforce page
   	  Set<String> authSet = new Set<String>(); 
   	  for(Account_Product_Authorization__c auth : authorizationList){
		   if(auth.User__c != null && !authSet.add(auth.User__c)){
		   	  ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Duplicate Users Not Allowed.');
              ApexPages.addMessage(msg); 
              return null;
		   }	   	  	 
   	  }
   	   //To check if the user is already exist in database
   	  oldAuthorizationList = [Select Id, User__c, User__r.Name from Account_Product_Authorization__c where Account__c =: AccountID];
   	  String userName = '';
   	  boolean flag = false;
   	  for(Account_Product_Authorization__c oldauth : oldAuthorizationList){
   	  	  if(authSet.contains(oldauth.User__c)){
   	  	  	 userName = userName + oldauth.User__r.Name + ',';
   	  	  	 flag = true;
   	  	  }
   	  }
   	  if(flag){
   	  	 userName = userName.subString(0, userName.lastIndexOf(','));
   	  	 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'User ' + userName + ' already exists');
         ApexPages.addMessage(msg); 
         return null;
   	  }
   	 
   	 
   	  List<Account_Product_Authorization__c> authList = new List<Account_Product_Authorization__c>(); 
      for(Account_Product_Authorization__c auth : authorizationList){
      	  if(auth.User__c != null && auth.Product_Authorization__c != null){
      	  	 auth.Account__c = AccountID;
      	  	 authList.add(auth);
      	  }
      }
      
      insert authList;
      
      PageReference pageReference = new PageReference('/'+AccountID); 
      return pageReference ;
      
   }
   
   public PageReference saveMore(){
   	Set<String> authSet = new Set<String>(); 
   	  for(Account_Product_Authorization__c auth : authorizationList){
		   if(auth.User__c != null && !authSet.add(auth.User__c)){
		   	  ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Duplicate Users Not Allowed.');
              ApexPages.addMessage(msg); 
              return null;
		   }	   	  	 
   	  }
   	  
   	   //To check if the user is already exist in database
   	  oldAuthorizationList = [Select Id, User__c, User__r.Name from Account_Product_Authorization__c where Account__c =: AccountID];
   	  String userName = '';
   	  boolean flag = false;
   	  for(Account_Product_Authorization__c oldauth : oldAuthorizationList){
   	  	  if(authSet.contains(oldauth.User__c)){
   	  	  	 userName = userName + oldauth.User__r.Name + ',';
   	  	  	 flag = true;
   	  	  }
   	  }
   	  if(flag){
   	  	 userName = userName.subString(0, userName.lastIndexOf(',')-1);
   	  	 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'User ' + userName + ' already exists');
         ApexPages.addMessage(msg); 
         return null;
   	  }
   	 
   	 
      List<Account_Product_Authorization__c> authList = new List<Account_Product_Authorization__c>(); 
      for(Account_Product_Authorization__c auth : authorizationList){
      	  if(auth.User__c != null && auth.Product_Authorization__c != null){
      	  	 auth.Account__c = AccountID;
      	  	 authList.add(auth);
      	  }
      }
      
      insert authList;
      
      PageReference pageReference = new PageReference('/apex/AccountProductAuthorization?scontrolCaching=1&id='+AccountID); 
      pageReference.setRedirect(true);
      return pageReference;
   }
   
   public PageReference cancel(){
      PageReference pageReference = new PageReference('/'+AccountID); 
      return pageReference ;
   }
   

    
}