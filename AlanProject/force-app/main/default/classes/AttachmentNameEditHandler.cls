public with sharing class AttachmentNameEditHandler extends AttachmentTriggerBaseHandler{
    
    public static Map<String,APTS_Agreement_Name_Format__c> mapSupportedNameFormat = APTS_Agreement_Name_Format__c.getAll();
    public static string AGREEMENT = 'Agreement';
    public static string PROPOSAL = 'Proposal';
    
    public AttachmentNameEditHandler(List<Attachment> lstNewAttachment, List<Attachment> oldNewAttachment){
        super(lstNewAttachment,oldNewAttachment);
    }
    
    public override void execute(){
        String PriceListDivision ='NoPriceList';
        String OpptyName='Oppty';
        String ParentName = 'Name';
        Boolean isUpdatedManually = false;
        
        List<Apttus__APTS_Agreement__c>AggList = new List<Apttus__APTS_Agreement__c>();
        List<Apttus_Proposal__Proposal__c>PropList = new List<Apttus_Proposal__Proposal__c>();
        set<ID>ParentId = new Set<ID>();
        for(Attachment att : lstNewAttachment){
            ParentId.add(att.parentId);
        }
        AggList =[select Id, Name, Apttus__Related_Opportunity__r.Name,Apttus_CMConfig__PriceListId__r.Division__c from Apttus__APTS_Agreement__c where id in:ParentId];
        PropList = [select Id, Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Opportunity__r.Name,Apttus_QPConfig__PriceListId__r.Division__c from Apttus_Proposal__Proposal__c where id in:ParentId];
        if(AggList.size()>0){
            PriceListDivision = AggList.get(0).Apttus_CMConfig__PriceListId__r.Division__c;
            OpptyName = AggList.get(0).Apttus__Related_Opportunity__r.Name;
            ParentName = AggList.get(0).Name;
        }
        else if(PropList.size()>0)
        {
            PriceListDivision = PropList.get(0).Apttus_QPConfig__PriceListId__r.Division__c;
            OpptyName = PropList.get(0).Apttus_Proposal__Opportunity__r.Name;
            ParentName = PropList.get(0).Apttus_Proposal__Proposal_Name__c;
        }
        
        Set<String> setTemplateName = new Set<String>();
        Set<Id> setParentId = new Set<Id>();
        
        Map<Attachment,String> mapAttwithTempName = new Map<Attachment,String>(); 
        Map<String,String> TempwithLang = new Map<String,String>(); 
        Map<id,String> mapParentIdwithQuoteName = new Map<id,String>();
        
        for(Attachment att : lstNewAttachment){
            //Check if added attachment is related to Proposal or Agreement
            if(att.ParentId.getSobjectType() != Apttus__APTS_Agreement__c.SobjectType 
               && att.ParentId.getSobjectType() != Apttus_Proposal__Proposal__c.SobjectType){
                   continue;
               }
            
            // Add Parent id 
            setParentId.add(att.ParentId);
            
            system.debug('original att.Name ==>'+att.Name);
            
            //Find Template name from Attachment
            String TemplateName = getTemplateName(att.Name);
            mapAttwithTempName.put(att,TemplateName);
            
            
            // Suresh Update
            Date sysDate = Date.newinstance(system.today().year(), system.today().month(), system.today().day());
            String sObjectType = att.ParentId.getSobjectType() == Apttus__APTS_Agreement__c.SobjectType ? AGREEMENT : PROPOSAL;
            isUpdatedManually = ApttusExpectedFormat(att.Name, ParentName, TemplateName, String.valueOf(sysDate), sObjectType);
            system.debug(' isUpdatedManually ================================================>>>>'+isUpdatedManually);
            //
            
            setTemplateName.add(TemplateName);
        }
        
        //Collect Template with Language
        TempwithLang = getTemplatebyName(setTemplateName);
        
        system.debug('TempwithLang ===>'+TempwithLang);
        
        //Collect Name from Parent Name
        mapParentIdwithQuoteName = getNamebyParentId(setParentId,setTemplateName);
        
        // get Quote or Agreement name from Parent Id
        for(Attachment att : lstNewAttachment){
            if(att.ParentId.getSobjectType() != Apttus__APTS_Agreement__c.SobjectType 
               && att.ParentId.getSobjectType() != Apttus_Proposal__Proposal__c.SobjectType) {
                   continue;
               }
            
            string DocType='';
            if(att.Name.indexof('.',0) != -1)
                DocType = att.Name.right(4);
            system.debug('>>>>>>>>DocType>>>>>>'+DocType);
            if(!DocType.startswith('.'))
                DocType ='.docx';
            String Type = att.ParentId.getSobjectType() == Apttus__APTS_Agreement__c.SobjectType ? AGREEMENT : PROPOSAL;
            
            
            /*
* String Name = getAgrrementName(att.Name,mapParentIdwithQuoteName.get(att.ParentId),TempwithLang,Type);
* system.debug('Name ====>'+Name);
* system.debug('=='+mapParentIdwithQuoteName.get(att.ParentId));
system.debug('=='+Name);
*/
            system.debug('>>>>>>>>PriceListDivision>>>>>>'+PriceListDivision);
            system.debug('>>>>>>>>mapParentIdwithQuoteName>>>>>>'+mapParentIdwithQuoteName.get(att.ParentId));
            system.debug('>>>>>>>>DocType>>>>>>'+DocType);
            
            if(isUpdatedManually){
                Date myDate = Date.newinstance(system.today().year(), system.today().month(), system.today().day());
                String sDate = String.valueOf(myDate);
                if(PriceListDivision!= Null && PriceListDivision !='' && (PriceListDivision.contains('MEP') || PriceListDivision.contains('Plancal')))
                    att.Name = ((mapParentIdwithQuoteName.get(att.ParentId)==null) ? ' ' :mapParentIdwithQuoteName.get(att.ParentId))+DocType;
                else if(PriceListDivision!= Null && PriceListDivision !='' && (PriceListDivision.contains('GCCM')))
                    att.Name = OpptyName +'_'+sDate+DocType;
            }
        }
    }
    
    // Suresh Update
    private Boolean ApttusExpectedFormat(String inputName, String ParentName, String TemplateName, String systemDate, String sObjectType){
        inputName = inputName.replaceAll('(\\.docx|\\.doc|\\.pdf|\\.rtf)', '');
        system.Debug(' Input Template Name ---------------------->'+inputName);
        ParentName = ParentName.replaceAll('/', '_').replaceAll('\\\\', '_');
        TemplateName = TemplateName.replaceAll('/', '_').replaceAll('\\\\', '_');
        system.debug(' ParentName ===>'+ParentName);
        
        String apttusFormat = '';
        
        if(sObjectType == 'PROPOSAL'){
            apttusFormat = ParentName + '_' + TemplateName + '_' + systemDate;
            system.debug('apttusFormat ------------------------------>'+apttusFormat);
            if(apttusFormat == inputName){
                return true;
            }
        }
        else{ // Agreement
            if(inputName.contains('_Original_')){
                apttusFormat = ParentName + '_Original_' + TemplateName + '_' + systemDate;
                system.debug('apttusFormat ------------------------------>'+apttusFormat);
                
                if(apttusFormat == inputName){
                    return true;
                }
            }
            else if(inputName.contains('_Regenerated_')){
                apttusFormat = ParentName + '_Regenerated_' + TemplateName + '_' + systemDate;
                system.debug('apttusFormat ------------------------------>'+apttusFormat);
                
                if(apttusFormat == inputName){
                    return true;
                }
            }   
        }
        return false;
    }
    ////
    
    
    private String getAgrrementName(String attName,String strQuoteName,Map<String,String> TempwithLang, String Type){
        
        String TemplateName = getTemplateName(attName);
        String Name;
        
        // If we get Template name from attachment
        if(TempwithLang.get(TemplateName) != null){
            
            if(mapSupportedNameFormat.get(TempwithLang.get(TemplateName)) != null){
                if(Type.equals(PROPOSAL)){
                    Name = mapSupportedNameFormat.get(TempwithLang.get(TemplateName)).Proposal__c;
                }else{ 
                    Name = mapSupportedNameFormat.get(TempwithLang.get(TemplateName)).Agreement__c;
                }
            }
        }
        else 
            Name = TemplateName;  
        return Name;
    }
    
    private map<Id,String> getNamebyParentId(set<Id> parentId,Set<String> TemplateName){
        map<Id,String> mapParentVsName = new map<Id,String>();
        system.debug('>>>TemplateName>>>>>'+TemplateName);
        //Parent can be Aggreement
        Date myDate = Date.newinstance(system.today().year(), system.today().month(), system.today().day());
        String sDate = String.valueOf(myDate);
        String CHdate = system.today().day()+'-'+system.today().month()+'-'+system.today().Year();
        for(Apttus__APTS_Agreement__c objAgg:[Select Id,Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Name,Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Enterprise_Party_Number__c,Apttus_QPComply__RelatedProposalId__r.Oracle_Account_Number__c,Apttus_CMConfig__PriceListId__r.Name, Apttus__FF_Agreement_Number__c,Name from Apttus__APTS_Agreement__c where Id in : parentId]){
            if(objAgg.Apttus_CMConfig__PriceListId__r.Name!= Null && objAgg.Apttus_CMConfig__PriceListId__r.Name!='' && (objAgg.Apttus_CMConfig__PriceListId__r.Name.contains('TIBV DE')||objAgg.Apttus_CMConfig__PriceListId__r.Name.contains('TIBV NL')||objAgg.Apttus_CMConfig__PriceListId__r.Name.contains('TIBV AT')||objAgg.Apttus_CMConfig__PriceListId__r.Name.contains('TIBV UK')))
                mapParentVsName.put(objAgg.Id,sDate+'-'+objAgg.Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Enterprise_Party_Number__c+'-'+objAgg.Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Name+' - '+'-'+new list<string>(TemplateName)[0]+'-'+objAgg.Name);
            else if(objAgg.Apttus_CMConfig__PriceListId__r.Name!= Null && objAgg.Apttus_CMConfig__PriceListId__r.Name!='' && (objAgg.Apttus_CMConfig__PriceListId__r.Name.contains('TIBV CH')))
                mapParentVsName.put(objAgg.Id,objAgg.Apttus_QPComply__RelatedProposalId__r.Oracle_Account_Number__c+'-'+objAgg.Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Name+'-'+new list<string>(TemplateName)[0]+'-'+CHdate);
            else if(objAgg.Apttus_CMConfig__PriceListId__r.Name!= Null && objAgg.Apttus_CMConfig__PriceListId__r.Name!='' && (objAgg.Apttus_CMConfig__PriceListId__r.Name.contains('TIBV FR')))
                mapParentVsName.put(objAgg.Id,sDate+'-'+objAgg.Apttus_QPComply__RelatedProposalId__r.Oracle_Account_Number__c+'-'+objAgg.Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Name+'-'+objAgg.Name+'-'+new list<string>(TemplateName)[0]);
            else
                mapParentVsName.put(objAgg.Id,sDate+'-'+objAgg.Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Enterprise_Party_Number__c+'-'+objAgg.Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Name+' - '+'-'+new list<string>(TemplateName)[0]+'-'+objAgg.Name);
                
        }
        
        //Parent can be Proposal 
        for(Apttus_Proposal__Proposal__c objProposal:[Select Id,Apttus_QPConfig__BillToAccountId__r.Enterprise_Party_Number__c,Oracle_Account_Number__c,Apttus_QPConfig__PriceListId__r.Name,Apttus_QPConfig__BillToAccountId__r.Name, Name,Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where Id in : parentId]){
            if(objProposal.Apttus_QPConfig__PriceListId__r.Name!=Null && objProposal.Apttus_QPConfig__PriceListId__r.Name!='' && (objProposal.Apttus_QPConfig__PriceListId__r.Name.contains('TIBV DE')||objProposal.Apttus_QPConfig__PriceListId__r.Name.contains('TIBV NL')||objProposal.Apttus_QPConfig__PriceListId__r.Name.contains('TIBV AT')||objProposal.Apttus_QPConfig__PriceListId__r.Name.contains('TIBV UK')))
                mapParentVsName.put(objProposal.Id,sDate+'-'+objProposal.Apttus_QPConfig__BillToAccountId__r.Enterprise_Party_Number__c+'-'+objProposal.Apttus_QPConfig__BillToAccountId__r.Name+'-'+new list<string>(TemplateName)[0]+'-'+objProposal.Name);
            else if(objProposal.Apttus_QPConfig__PriceListId__r.Name!=Null && objProposal.Apttus_QPConfig__PriceListId__r.Name!='' && (objProposal.Apttus_QPConfig__PriceListId__r.Name.contains('TIBV CH')))
                mapParentVsName.put(objProposal.Id,objProposal.Oracle_Account_Number__c+'-'+objProposal.Apttus_QPConfig__BillToAccountId__r.Name+'-'+new list<string>(TemplateName)[0]+'-'+CHdate);
            else if(objProposal.Apttus_QPConfig__PriceListId__r.Name!=Null && objProposal.Apttus_QPConfig__PriceListId__r.Name!='' && (objProposal.Apttus_QPConfig__PriceListId__r.Name.contains('TIBV FR')))
                mapParentVsName.put(objProposal.Id,sDate+'-'+objProposal.Oracle_Account_Number__c+'-'+objProposal.Apttus_QPConfig__BillToAccountId__r.Name+'-'+objProposal.Name+'-'+new list<string>(TemplateName)[0]);
            else 
                mapParentVsName.put(objProposal.Id,sDate+'-'+objProposal.Apttus_QPConfig__BillToAccountId__r.Enterprise_Party_Number__c+'-'+objProposal.Apttus_QPConfig__BillToAccountId__r.Name+'-'+new list<string>(TemplateName)[0]+'-'+objProposal.Name);
                
        }
        
        return mapParentVsName;
    }
    
    private Map<String,String> getTemplatebyName(Set<String> setTemplateName){
        Map<String,String> mapTemplateWithLang = new Map<String,String>();
        
        for(Apttus__APTS_Template__c objAptTemp : [Select Name,Apttus__Language__c from Apttus__APTS_Template__c where Name in: setTemplateName]){
            
            system.debug('Templname ===>'+objAptTemp.Name+'==='+objAptTemp.Id+'==='+objAptTemp.Apttus__Language__c);
            
            // If there is no language mentioned. It will be English
            if(objAptTemp.Apttus__Language__c == null){
                objAptTemp.Apttus__Language__c = 'English';
            }
            
            mapTemplateWithLang.put(objAptTemp.name,objAptTemp.Apttus__Language__c);
        }
        
        return mapTemplateWithLang;
    }
    
    /*Patter of Attachement Name
= ProposalName _TemplateName_Date.extension
e.g. Renewal Contract#1_Manhattan Trimble Proposal US_2016-06-13.doc
*/
    private String getTemplateName(String strTemplateName){
        List<String> TempList = new List<String>();
        if(strTemplateName.Contains('_Regenerated')){
            strTemplateName = strTemplateName.remove('_Regenerated');
        }
        system.debug('>>>>>>>>>>strTemplateName>>>>>'+strTemplateName);
        system.debug(strTemplateName.split('_').size());
        TempList = strTemplateName.split('_');
        if(strTemplateName.split('_').size()==3)
            strTemplateName = TempList[1];
        else if(strTemplateName.split('_').size()==4)
            strTemplateName = TempList[2];
        else if(strTemplateName.split('_').size()==5)
            strTemplateName = TempList[3];
       /* else
   strTemplateName =strTemplateName.subString(strTemplateName.IndexOf(strTemplateName.split('_')[1]),strTemplateName.IndexOf(strTemplateName.split('_')[2])-1);*/
        return strTemplateName;
    }
}