public class invokewebserviceForSearchBeforeCreate
{
    public invokewebserviceForSearchBeforeCreate(){}
    public class myexception extends Exception{}
    public list<trimblecorpComCmdm_v2.OrganizationPartyType> SearchForAccount(string leadName,string billingstreet,string billingcity,string billingstate,string billingcountry,string billingpostalcode,string company,string phonenumber)
    {
    	list<trimblecorpComCmdm_v2.OrganizationPartyType> responselist = new list<trimblecorpComCmdm_v2.OrganizationPartyType>();
    	
    	system.debug('leadName====='+leadName+'======billingstreet===='+'=====billingcity==='+billingcity+'======billingstate====='+billingstate+'======billingcountry====='+billingcountry+'====billingpostalcode===='+billingpostalcode+'======phonenumber===='+phonenumber+'====company===='+company);	
                 

            trimblecorpComCmdm_v2.HeaderType reqvar = new trimblecorpComCmdm_v2.HeaderType();
            reqvar.sourceSystem = 'SFDC';
            reqvar.destinationSytem = 'FCH';
            reqvar.operation = 'fetch';
            
            trimblecorpComCmdm_v2.OrganizationPartyResultType  respvar = new trimblecorpComCmdm_v2.OrganizationPartyResultType();
            
            String PartyId = '';
            String Parent_PartyId = '';
            String OrganizationName = company;
            String LifecycleStage_c = '';
            String CustomerLevel_c = '';
            String Channel_c = '';
            String PrimaryRegion_c = '';
            String GlobalOptOut_c = '';
            String RestrictedPartyIndicator_c = '';
            String DUNSNumberC = '';
            String VerticalClassification_c = '' ;
            String CreditStatus_c = '';
            String BilltoUsage_c = '';
            String ShiptoUsage_c = '';
            String EndUser_c = '';
            String Installedat_c = '';
            String SelltoFlag= '';
            String PrimaryPhoneNumber = phonenumber;
            //String EmailAddress = '';
            String PrimaryEMail_c = '';
            String AccountOwnerEmail_c = '';
            //trimblecorpComCmdm_v2.Email_element Email = new trimblecorpComCmdm_v2.Email_element();
            //email.EmailAddress = '';
            String ValidatedFlag = '';
            String EnterprisePartyNumber = '';
            String AccountName = '';
            String Language = '';
            
            
            trimblecorpComCmdm_v2.LocationType  location = new trimblecorpComCmdm_v2.LocationType();
            list<string> addlist = billingstreet.split('[\n\r]');
	        //system.debug('addlist====='+addlist);
	        //system.debug('addlist====='+addlist.size());
	        
	        for (Integer i = 0; i < addlist.size(); i++) {
				if (addlist.get(i).equals('')) {
					addlist.remove(i);
					i--; //Decrement counter since we removed an empty item from the list
				}
			}
	        
	        system.debug('addlist====='+addlist);
	        system.debug('addlist====='+addlist.size());
	        
	        if(addlist!=null && addlist.size()>0)
            {
            	if(addlist.size()>4)
            	throw new myexception('Maximum of 4 lines allowed for Street Address.Please enter only 4 lines of address');
            }
                        
            integer listsize = addlist.size();
            
            location.Address1 = (addlist!=null && addlist.size()>0)?addlist[0]:'';
            location.Address2 = (addlist!=null && addlist.size()>0)?(listsize>=2?addlist[1]:''):'';
            location.Address3 = (addlist!=null && addlist.size()>0)?(listsize>=3?addlist[2]:''):'';
            location.Address4 = (addlist!=null && addlist.size()>0)?(listsize>=4?addlist[3]:''):'';
            
            
                        
            location.city = billingcity;
            location.state = billingstate;
            location.county = '';
            location.country = billingcountry;
            location.postalcode = billingpostalcode;
            
            trimblecorpComCmdm_v2.PartySite_element PartySite = new trimblecorpComCmdm_v2.PartySite_element();
            PartySite.Location = location;
            system.debug('PartySite====='+PartySite);
            
            trimblecorpComCmdm_v2.OriginalSystemReferenceType[] OriginalSystemReference = new trimblecorpComCmdm_v2.OriginalSystemReferenceType[]{};
            trimblecorpComCmdm_v2.OriginalSystemReferenceType OriginalSystemReference1 = new trimblecorpComCmdm_v2.OriginalSystemReferenceType();
            OriginalSystemReference1.OrigSystem = 'SFDC';
            OriginalSystemReference1.OrigSystemReference = '';
            
            OriginalSystemReference.ADD(OriginalSystemReference1);            
            
            xmlnsTrimbleComTrimblenavigationFch_v2.searchOrganizationParty_pt  targetportvar= new xmlnsTrimbleComTrimblenavigationFch_v2.searchOrganizationParty_pt();
            targetportvar.timeout_x = 120000;
            try{
            	respvar.OrganizationParty = targetportvar.process(PartyId, Parent_PartyId, EnterprisePartyNumber,AccountName,OrganizationName, LifecycleStage_c, CustomerLevel_c, Channel_c, PrimaryRegion_c, GlobalOptOut_c, RestrictedPartyIndicator_c, DUNSNumberC,Language, VerticalClassification_c, CreditStatus_c, BilltoUsage_c, ShiptoUsage_c, EndUser_c, Installedat_c, SelltoFlag, PrimaryPhoneNumber, PrimaryEMail_c,AccountOwnerEmail_c, ValidatedFlag,PartySite,OriginalSystemReference);
            	System.debug('respvar====='+respvar);	
            }
            catch(exception ex)
            {
            	system.debug('ex===='+ex);
            }
            
            if(respvar.OrganizationParty!=null)
            responselist = respvar.OrganizationParty;             

        
        
        return responselist;
    }
}