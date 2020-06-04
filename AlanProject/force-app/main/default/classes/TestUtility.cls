Public Class TestUtility{

    /*
    * Utility Method to create dummy response for xmlnsTrimbleComTrimblenavigationFch_v2 searchOrganizationParty WS 
    */
    Public trimblecorpComCmdm_v2.OrganizationPartyResultType generateMockResponseFor_trimblecorpComCmdm_v2(){    
    
        trimblecorpComCmdm_v2.OrganizationPartyResultType orgPartyType = new trimblecorpComCmdm_v2.OrganizationPartyResultType();
        trimblecorpComCmdm_v2.OrganizationPartyType[] orgPartyList= new trimblecorpComCmdm_v2.OrganizationPartyType[]{};
        trimblecorpComCmdm_v2.OrganizationPartyType orgPartyInst = new trimblecorpComCmdm_v2.OrganizationPartyType();
                
        trimblecorpComCmdm_v2.LocationType locObj = new trimblecorpComCmdm_v2.LocationType();
        locObj.Address1='Test 1';
        locObj.Address2='Test 2';
        locObj.Address3='Test 3';
        locObj.Address4='Test 4';
        locObj.City='Pune';
        locObj.State='Maharastra';
        locObj.Province='Test';
        locObj.Country='India';
        locObj.postalCode='100100';
        
        trimblecorpComCmdm_v2.PartySite_element PartySiteEle = new trimblecorpComCmdm_v2.PartySite_element();
        PartySiteEle.Location = locObj; 
        
        orgPartyInst.PartySite = PartySiteEle;
        orgPartyInst.PartyId ='300000000000000';
        orgPartyInst.OrganizationName='Test-Test';
        orgPartyInst.LifecycleStage_c='Prospect';
        orgPartyInst.CustomerLevel_c='Standard';
        orgPartyInst.GlobalOptOut_c='No';
        orgPartyInst.RestrictedPartyIndicator_c='Not Restricted';
        orgPartyInst.BilltoUsage_c='Yes';
        orgPartyInst.ShiptoUsage_c='Yes';
        orgPartyInst.EndUser_c='No';
        orgPartyInst.Installedat_c='No';
        orgPartyInst.SelltoFlag='Yes';       
        orgPartyList.add(orgPartyInst);
                
        orgPartyType.OrganizationParty =orgPartyList;   
        
        return orgPartyType;    
     } 
    
    /*
    * Utility Method to create dummy response for trimblecorpComTnvcussfdcoutboundWsdl_v1   
    */
    Public trimblecorpComTnvcussfdcoutbound_v1.tnvcusSFDCOutboundOutput_element generateMockResponseFor_trimblecorpComTnvcussfdcoutboundWsdl_v1(){  
        
        trimblecorpComTnvcussfdcoutbound_v1.tnvcusSFDCOutboundOutput_element outElem = new trimblecorpComTnvcussfdcoutbound_v1.tnvcusSFDCOutboundOutput_element();
        outElem.status = 'Success';
        outElem.message ='Success';    
        return outElem;
        
    }
    
     /*
    * Utility Method to create dummy response for trimblecorpComTnvcussfdcoutboundWsdl_v1   
    */
    Public trimblecorpComTnvcussfdcoutbound_v1.tnvcusSFDCOutboundOutput_element generateMockResponseFor_tnvcusSFDCOutboundInput_element(){  
        trimblecorpComTnvcussfdcoutbound_v1.tnvcusSFDCOutboundOutput_element outElem = new trimblecorpComTnvcussfdcoutbound_v1.tnvcusSFDCOutboundOutput_element();
        outElem.status = 'Success';
        outElem.message ='Success';    
        return outElem; 
        
    }
    
     /*
    * Utility Method to create dummy response for trimblecorpComTnvcussfdcoutboundWsdl_v1   
    */
    Public trimblecorpComTnvreceiveexternalerrors.Response generateMockResponseFor_trimblecorpCom(){  
        trimblecorpComTnvreceiveexternalerrors.Response outElem = new trimblecorpComTnvreceiveexternalerrors.Response();
        outElem.status = 'Success';
        outElem.message ='Success';    
        return outElem; 
        
    }
 
    
}