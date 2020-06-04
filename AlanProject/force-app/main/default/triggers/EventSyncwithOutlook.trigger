/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : This trigger is used to update the Descrption Field of Event record on Insert, Update and Delete of Customer Event record,
                 which is then synced to Outlook using SFDC for Outlook
 * History     :  

 * [02.DEC.2013] Srinivasan Babu  Created
 */
trigger EventSyncwithOutlook on Customer_Event__c (before insert,before delete,after insert, after update,before update) {
    //VARIABLES
    map<Id, Customer_Event__c> mapEventCustomerEve = new map<Id, Customer_Event__c>();
    list<Event> listUpdateEventDesc = new list<Event>();
    list<Event> listDelEventDesc = new list<Event>();
    Id ContId;
    list<Customer_Event__c> listCustEve = new list<Customer_Event__c>();
    String sDesc = ' ',Newstr=' ',sample=' ';
     Boolean SecCont = False;
     Integer a1,l;
    List<Contact> RelatedCont = new List<Contact>(); 
     Set<Id>CusEv = new Set<ID>();
   /* if(Trigger.Isbefore && Trigger.Isupdate)
     {
     for(customer_Event__c c : Trigger.New)
     {
     CusEv.add(c.id);
     }
      RelatedCont = [select id from contact where customer_Event__c =:CusEv];
     for(customer_Event__c c :trigger.New)
      {
      if(RelatedCont.size()==0)
      c.Contact_Names__c=' ';
      }
     }*/
    
    //Trigger event after Insert and after Update
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        //To get map of Event Id and associated Account and Contact values from Customer Event record 
        for(Customer_Event__c oCustEve : [select Id,
                                                 Event_Id__c,
                                                 Account__c,Account__r.Name,
                                                 Customer_Related_Contact__c,
                                                 Contact__c,
                                                 Customer_Related_Contact__r.Phone,
                                                 Customer_Related_Contact__r.Country_Code__c,
                                                 Customer_Related_Contact__r.Email
                                                 from  Customer_Event__c 
                                                 where Id IN: Trigger.newMap.keyset()]){
            mapEventCustomerEve.put(oCustEve.Event_Id__c, oCustEve);
        }
       
       
        
        system.debug('mapEventCustomerEve>>>'+mapEventCustomerEve);
        //To get the list of exisiting Cusotmer Event record based on Event Id
        listCustEve = [select Id, Event_Id__c,Account__c, Account__r.Name,Contact__c,Customer_Related_Contact__c ,Customer_Related_Contact__r.Email,Customer_Related_Contact__r.Phone,Customer_Related_Contact__r.Country_Code__c from Customer_Event__c where Event_Id__c IN: mapEventCustomerEve.keyset()];
        listCustEve.sort();
        List<Contact> RelContacts = new List<Contact>();
        Set<ID> CustEv = new Set<ID>();
        //Insert actions    or Update actions
        if(Trigger.isInsert || Trigger.isUpdate){
        for(Customer_Event__c ce : Trigger.New)
        {
        CustEv.add(ce.id);
        }
        RelContacts = [select id,Name,Country_Code__c,Phone,Email from Contact where Customer_Event__c in:CustEv];
         
         if(RelContacts.size()>0)
         SecCont = True;
        
         String ObjType=' ';
         
            //To update description field on Event based on Insert and Update of Customer Event record
            for(Event oEvent : [select Id, Description,Description_Not_Available__c,WhoId,Who.Name,WhatId,What.Name from Event where Id IN: mapEventCustomerEve.keyset()]){
             if(oEvent.WhatId!=null)
            ObjType = String.valueof(oEvent.WhatId).substring(0,3);
            system.debug('&^&^&^&^&^&^&^'+ObjType);
             system.debug('&^&^&^&^&^&^&^'+oEvent.WhatId);
           // Allows to Add only Account
            if(oEvent.WhatId!=null && ObjType=='001')
              sDesc = 'Related To: '+oEvent.What.Name+';';
            if(oEvent.WhoId!=null)
              sDesc =sDesc+' Name: '+ oEvent.Who.Name+';';
              
             
            if(oEvent.Description!=null)
               {
                    if(oEvent.Description.contains(mapEventCustomerEve.get(oEvent.Id).Account__r.Name)&& SecCont==True ){
                         integer delposition = 0;
                         String Acc =' ';
                        List<String>AccName= new List<String>();
                        AccName= oEvent.Description.split('Account Name:');
                        for(integer i=0;i<AccName.size();i++)
                             {
                            if(AccName[i].contains(mapEventCustomerEve.get(oEvent.Id).Account__r.Name))
                            {
                            delposition = i;
                            } 
                             }
                           AccName.remove(delposition);
                           // Reframing the Description 
                              
                         if(AccName.size()==1 && RelContacts.size()==0 )
                         oEvent.Description = oEvent.Description;
                         else
                          oEvent.Description = AccName[0];
                          for(Integer j = 1 ; j<=AccName.size()-1;j++)
                          {
                          oEvent.Description = oEvent.Description +'Account Name:'+AccName[j];
                         system.debug('Inside the Loop'+oEvent.Description);
                          }
                         
                           system.debug('****************'+AccName.size());
                           system.debug('****************'+AccName);
                           system.debug('****************'+delposition);
                            system.debug('****************'+oEvent.Description);
                       String TotalCont=' ';
                        oEvent.Description=oEvent.Description.replaceall('Description:',' ');
                        String samp = 'Account Name: '+mapEventCustomerEve.get(oEvent.Id).Account__r.Name+';';
                         if(oEvent.Description.contains(samp))
                         oEvent.Description=oEvent.Description.replaceall(samp,' ');
                         sDesc = 'Description:  '+ oEvent.Description;
                        oEvent.Description = sDesc+ '  ' +'Account Name: ' +mapEventCustomerEve.get(oEvent.Id).Account__r.Name;
                        system.debug('mapEventCustomerEve.get(oEvent.Id).Customer_Related_Contact__c>>'+mapEventCustomerEve.get(oEvent.Id).Customer_Related_Contact__c);
                        if(RelContacts.size()>0){
                        for(contact c :RelContacts){
                        TotalCont = TotalCont + 'Contact Name: ' +c.Name + ', Country Code: ' +c.Country_Code__c + ', Phone: '+c.Phone +', Email: '+c.Email+' \n';
                        }
                        system.debug('&*&*&*&*&*&*&'+oEvent.Description);
                        system.debug('&*&*&*&*&*&*&'+TotalCont);
                          oEvent.Description = oEvent.Description+ '   '+TotalCont;
                       }
                        oEvent.Description = oEvent.Description + ';\n\n';   
                        
                    }
                   
                else
                {
                     String TotalCont=' ';
                     oEvent.Description=oEvent.Description.replaceall('Description:',' ');
                      String samp = 'Account Name: '+mapEventCustomerEve.get(oEvent.Id).Account__r.Name+';';
                         if(oEvent.Description.contains(samp))
                         oEvent.Description=oEvent.Description.replaceall(samp,' ');
                       // oEvent.Description=oEvent.Description.replaceall(sDesc,' ');
                        if(!oEvent.Description.contains('Account Name: '))
                       sDesc= 'Description:  '+oEvent.Description+';'+sDesc;
                       else
                        sDesc = 'Description:  '+oEvent.Description;
                        oEvent.Description = sDesc+ '  ' +'Account Name: ' +mapEventCustomerEve.get(oEvent.Id).Account__r.Name;
                        system.debug('mapEventCustomerEve.get(oEvent.Id).Customer_Related_Contact__c>>'+mapEventCustomerEve.get(oEvent.Id).Customer_Related_Contact__c);
                        if(RelContacts.size()>0){
                        for(contact c :RelContacts){
                        TotalCont = TotalCont + 'Contact Name: ' +c.Name + ', Country Code: ' +c.Country_Code__c + ', Phone: '+c.Phone +', Email: '+c.Email+' \n';
                        }
                          oEvent.Description = oEvent.Description+ '   '+TotalCont;
                       }
                        oEvent.Description = oEvent.Description + ';\n\n';  
                }
                
              }
                      
              if(oEvent.Description ==null)
              {
                      String TotalCont= ' ';
                     oEvent.Description_Not_Available__c=True;
                        oEvent.Description=sDesc+ ' Account Name: ' +mapEventCustomerEve.get(oEvent.Id).Account__r.Name;
                        system.debug('mapEventCustomerEve.get(oEvent.Id).Customer_Related_Contact__c>>'+mapEventCustomerEve.get(oEvent.Id).Customer_Related_Contact__c);
                        if(RelContacts.size()>0){
                        for(contact c :RelContacts){
                        TotalCont = TotalCont + 'Contact Name: ' +c.Name + ', Country Code: ' +c.Country_Code__c + ', Phone: '+c.Phone +', Email: '+c.Email+' \n';
                        }
                          oEvent.Description = oEvent.Description+ '   '+TotalCont;
                       }
               oEvent.Description = oEvent.Description + ';\n\n';
            
             
              }
            
              
           
              
              
                listUpdateEventDesc.add(oEvent);
            }
        }
        
        if(!listUpdateEventDesc.isEmpty()){
            update listUpdateEventDesc;
        }
    }
   
   //Delete actions
    if(Trigger.isBefore){
        if(Trigger.isDelete){
        String sdescdel=' ',ObjType=' ';
            // to get the latest record from Csutomer Event record and update the description on Event
            for(Customer_Event__c oCustEve : [select Id,
                                                 Event_Id__c,
                                                 Account__c,Account__r.Name,
                                                 Customer_Related_Contact__c,
                                                 Contact__c,
                                                 Customer_Related_Contact__r.Phone,
                                                 Customer_Related_Contact__r.Country_Code__c,
                                                 Customer_Related_Contact__r.Email                                               
                                                 from  Customer_Event__c 
                                                 where Id IN: Trigger.oldMap.keyset()]){
                mapEventCustomerEve.put(oCustEve.Event_Id__c, oCustEve);
            }
                    
            List<String> Temp = new List<String>();
           
            for(Event oEvent : [select Id, Description, WhatId,Description_Not_Available__c,What.Name,Who.Name,WhoId from Event where Id IN: mapEventCustomerEve.keyset()]){
            if(oEvent.WhatId!=null)
            ObjType = String.valueof(oEvent.WhatId).substring(0,3);
            if(oEvent.WhatId!=null && ObjType=='001')
             sDesc = 'Related To: '+oEvent.What.Name+';';
              if(oEvent.WhoId!=null)
              sDesc =sDesc+' Name: '+ oEvent.Who.Name+';';
             
              String OldValues=' '; 
              if(oEvent.Description !=null)
              {
              oEvent.Description = oEvent.Description.replace(';;;',';'); 
              oEvent.Description = oEvent.Description.replace(';;',';'); 
               List<String> OldValuesList = oEvent.Description.split(';');
           if(oEvent.WhatId!=null && ObjType=='001' && oEvent.WhoId!=null)
           {
            if(OldValuesList.size()>=3){
               for(Integer k = 0; k<=2;k++)
                   {
                   OldValues = OldValues + OldValuesList[k] +';';
                   }
               }
           }
           
           else if((oEvent.WhatId!=null && ObjType=='001' )|| oEvent.WhoId!=null)
           {
            if(OldValuesList.size()>=2){
               for(Integer k = 0; k<=1;k++)
                   {
                   OldValues = OldValues + OldValuesList[k] +';';
                   }
               }
           }
           else
           {
           OldValues = OldValuesList[0]+';';
           }
           }
               
                      
                if(oEvent.Description!=null && oEvent.Description.contains(mapEventCustomerEve.get(oEvent.Id).Account__r.Name )){
                         integer delposition = 0;
                         String TempStr=' ';
                         String oldStr=' ';
                         
                         List<String>AccName= new List<String>();
                        AccName= oEvent.Description.split('Account Name:');
                        for(integer i=0;i<AccName.size();i++)
                             {
                            if(AccName[i].contains(mapEventCustomerEve.get(oEvent.Id).Account__r.Name))
                            {
                            delposition = i;
                            } 
                             }
                 AccName.remove(delposition);
                  if(AccName.size()==1)
                  { 
                  oEvent.Description=oEvent.Description.replaceall('Description:',' ');
                  oEvent.Description =AccName[0];
                         }
                     else{    
                          for(Integer j = 1 ; j<AccName.size();j++)
                          {
                          system.debug('*******&*&*&*&*****'+AccName[j]);
                          TempStr = TempStr +'Account Name:'+AccName[j];
                         system.debug('*******&*&*&*&*****'+oEvent.Description);
                          }
                        oEvent.Description=oEvent.Description.replaceall('Description:',' ');
                       String Buffer = oEvent.Description.trim();
                          system.debug('888888888888'+Buffer); 
                          system.debug('888888888888'+oldvalues);
                        if(oEvent.Description_Not_Available__c == False)
                        oEvent.Description = oldvalues+'  '+ TempStr;
                        else if(Buffer.startswith('Account Name:') && oEvent.Description_Not_Available__c == True)
                        oEvent.Description = 'Description: '+TempStr;
                        else if((Buffer.startswith('Related To:')||Buffer.startswith('Name:')) && oEvent.Description_Not_Available__c == True)
                        oEvent.Description ='Description: '+ sDesc+TempStr ;
                                               
                        }
    
                    }
                listUpdateEventDesc.add(oEvent);
            }
            
            if(!listUpdateEventDesc.isEmpty()){
                update listUpdateEventDesc;
            }
       
            
        }
    
    }
}