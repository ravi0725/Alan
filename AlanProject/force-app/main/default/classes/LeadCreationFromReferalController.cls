/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public class LeadCreationFromReferalController{
     
    public String referralId;    
    public LeadCreationFromReferalController(ApexPages.StandardController controller){
        referralId = ApexPages.CurrentPage().getParameters().get('id');
        //referralId = controller.getId();
       
    }
    
    public PageReference redirectURL(){
       List<Referral__c> referralList = new List<Referral__c>();
      
       referralList = [Select Id, Name, Contact_First_Name__c, Contact_Last_Name__c, Phone__c, Company__c, Email__c, Description__c, Street__c, City__c, State_Province__c, Country__c, Zip_Postal_Code__c,Product_Type__c,Ownerid,owner.name from Referral__c where id=:referralId];
       if(referralList.size() > 0){
          Referral__c referral  = new Referral__c();
          referral = referralList.get(0);
          PageReference p = new PageReference('/00Q/e');
          Map<String, String> m = p.getParameters();
          //m.putAll(createDefaultValues());
          //m.put('nooverride', '1');
          m.put('retURL', referralId);
          m.put('CF00Nc0000000yqiP_lkid', referralId);
          m.put('CF00Nc0000000yqiP', referral.Name);
          m.put('name_firstlea2', referral.Contact_First_Name__c);
          m.put('name_lastlea2', referral.Contact_Last_Name__c);
          m.put('lea8', referral.Phone__c);
          m.put('lea3', referral.Company__c);
          m.put('lea11', referral.Email__c);
          m.put('00Ni00000086M4A', referral.Description__c);
          m.put('lea16street', referral.Street__c);
          m.put('lea16city', referral.City__c);
          m.put('lea16state', referral.State_Province__c);
          m.put('lea16country', referral.Country__c);
          m.put('lea16zip', referral.Zip_Postal_Code__c);
          m.put('lea5', 'External Referral');
          m.put('00Ni0000005rewv', 'GCCM');
          m.put('00Ni0000005rewu', referral.Product_Type__c);
          m.put('00Nc0000000kQs1', 'GCCM - '+referral.Product_Type__c);
          m.put('CF00Nc0000000ysJg_lkid', referral.ownerid);
          m.put('CF00Nc0000000ysJg', referral.owner.Name);
          /**if(referral.Product_Type__c =='Vico'){
             m.put('00Nc0000000kQs1', 'GCCM - Vico');
          }
          if(referral.Product_Type__c =='Prolog'){
             m.put('00Nc0000000kQs1', 'GCCM - Prolog');
          }
          if(referral.Product_Type__c =='WinEst'){
             m.put('00Nc0000000kQs1', 'GCCM - WinEst');
          }
          if(referral.Product_Type__c =='Modelogix'){
             m.put('00Nc0000000kQs1', 'GCCM - Modelogix');
          }
          if(referral.Product_Type__c =='GC Field'){
             m.put('00Nc0000000kQs1', 'GCCM - GC Field');
          }
           if(referral.Product_Type__c =='VDC Services'){
             m.put('00Nc0000000kQs1', 'GCCM - VDC Services');
          }**/
          m.put('ent', 'Lead');
          m.put('nooverride', '1');
          return p;
         
       }
       return null;
    }  
}