public class SearchIssueController{
    public String searchString{get;set;}
    String searchText = '';
    Map<Integer,List<Case>> csMap{get;set;}
    public List<Case> csList{get;set;}
    public case cs{get;set;}
    public case Issue{get;set;}
    public boolean resultFlag{get;set;}
    public string selectedIssueSFDCId{get;set;}
    public string selectedIssueTFSId{get;set;}

    public String newIssueURL{get;set;}
    //Pagging variables
    public Integer currentPage{get;set;}
    public Integer totalPage{get;set;}
    public Integer perPageRecords{get;set;}
    public Integer totalRecords{get;set;}

    public List<SelectOption> prodList{get;set;}
    public String selectedProduct{get;set;}

    public String division{get;set;}
    public String defectTypeId{get;set;}
    public Map<String,XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean> tfsIdWorkItemMap;

    public String JIRAProjectKeyMapped {get;set;}

    public SearchIssueController(ApexPages.StandardController controller){
        totalRecords = 0;
        totalPage = 0;
        currentPage = 1;
        perPageRecords = Integer.valueOf(VF_Page_Paggination_Config__c.getAll().get('Search_Defect').Records_Per_Page__c);
        resultFlag = false;
        csList = new List<Case>();
        csMap = new Map<Integer,List<Case>>();
        cs = [SELECT Id, Record_Type_Name__c, TFS_Id__c, Product__c, Type, Subject, Defect__c, TFS_Status__c, ContactId, Product_Group__c FROM Case WHERE Id =: controller.getId()];
        if(Label.GCCM_Support_Case_Record_Type == cs.Record_Type_Name__c){
            division = 'GCCM';
            defectTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(Label.GCCM_Support_Issue_Record_Type).getRecordTypeId();
        }


        Issue = new Case();
        if(cs.Defect__c != null){
            Issue = [SELECT Id, TFS_Status__c, Product__c, CaseNumber, TFS_Id__c, Subject, Type, Fixed_in_Build__c, Confirmed_in_Build__c, TFS_Close_Date__c, Features__c, Description FROM Case WHERE Id =: cs.Defect__c];
        }
        else
            Issue.RecordTypeId = defectTypeId;

        searchString = '';

        prodList = new List<SelectOption>();
        List<String> prdList = new List<String>();
        for(TFS_Project_Config__c tfs : TFS_Project_Config__c.getAll().values()){
            if( tfs.Run_Integration__c || tfs.Run_JIRA_Integration__c ){
                prdList.add(tfs.Name);
            }
        }
		prdList.sort();
        prodList.add(new SelectOption('','--None--'));
        for(String prdName : prdList){
            prodList.add(new SelectOption(prdName,prdName));
        }

        newIssueURL = '/500/e?retURL=/500/o&RecordType=' + defectTypeId
                + '&' + Label.Temp_Case_Id + '=' + cs.Id
                + '&ent=Case';

        Set<String> setJIRAProjectMapped = new Set<String>();
        for(PPM_JIRA_Issue_Type__c ppm : PPM_JIRA_Issue_Type__c.getAll().values()){
          if( ppm.JIRA_Project_Key__c != null){
            setJIRAProjectMapped.add( ppm.JIRA_Project_Key__c );
          }
        }
        if(setJIRAProjectMapped.size() > 0){
          JIRAProjectKeyMapped = String.valueOf( setJIRAProjectMapped );
        }
    }


    public void SearchIssue(){
        resultFlag = false;
        Issue.Product__c = selectedProduct;
        if(Issue.Product__c != null && Issue.Type != null && searchString != null && searchString != ''){
            csMap = new Map<Integer,List<Case>>();
            csList = new List<Case>();
            totalRecords = 0;
            totalPage = 0;
            currentPage = 1;
            String prolianceQuery = '';
            String query = 'select Id,CaseNumber,Found_In_Build__c,Description,Product__c,Subject,TFS_Id__c,TFS_Status__c,Type,Steps_to_Reproduce__c,Workaround__c,Resolution__c from Case where';
            if(Issue.Product__c != null)
                query = query + ' Product__c = \'' + Issue.Product__c + '\' and';

            if(Issue.Type != null)
                query = query + ' Type = \'' + Issue.Type + '\' and';
            prolianceQuery = query;
            if(searchString != null && searchString != ''){
                searchText = '%' + searchString + '%';
                query = query + ' (Subject like \'' + searchText + '\' OR';
                query = query + ' Status like \'' + searchText + '\' OR';
                query = query + ' Found_In_Build__c like \'' + searchText + '\' OR';
                query = query + ' TFS_ID__c like \'' + searchText + '\') and';
            }
            query = query + ' RecordTypeId = \'' + defectTypeId + '\'';
            prolianceQuery = prolianceQuery + ' RecordTypeId = \'' + defectTypeId + '\'';
            system.debug('------query--------' + query);
            system.debug('------prolianceQuery--------' + prolianceQuery);
            set<Id> csIds = new set<Id>();
            for(Case tempCS : database.query(query)){
                csIds.add(tempCs.Id);
                if(csMap.get(currentPage) == null)
                    csMap.put(currentPage,new List<Case>());
                csMap.get(currentPage).add(tempCS);
                if(csMap.get(currentPage).size() >= VF_Page_Paggination_Config__c.getAll().get('Search_Defect').Records_Per_Page__c){
                    currentPage++;
                }
                totalRecords++;
            }

            if(TFS_Project_Config__c.getAll().get(Issue.Product__c) != null ? TFS_Project_Config__c.getAll().get(Issue.Product__c).Division__c != 'Proliance'  : false ){
                searchTFSIssue(csIds);
            }else{
                for(Case tempCS : database.query(prolianceQuery)){
                    system.debug('-------------------' + tempCS.Description);
                    system.debug('-------------------' + tempCS.Steps_to_Reproduce__c);
                    system.debug('-------------------' + tempCS.Workaround__c);
                    system.debug(+ '-------------------' + tempCS.Resolution__c);
                    if((tempCS.Description != Null ? tempCS.Description.contains(searchString) : false) ||
                      (tempCS.Steps_to_Reproduce__c != Null ? tempCS.Steps_to_Reproduce__c.contains(searchString) : false) ||
                      (tempCS.Workaround__c != Null ? tempCS.Workaround__c.contains(searchString) : false) ||
                       (tempCS.Resolution__c != Null ? tempCS.Resolution__c.contains(searchString): false) ){
                        csIds.add(tempCs.Id);
                        if(csMap.get(currentPage) == null)
                            csMap.put(currentPage,new List<Case>());
                        csMap.get(currentPage).add(tempCS);
                        if(csMap.get(currentPage).size() >= VF_Page_Paggination_Config__c.getAll().get('Search_Defect').Records_Per_Page__c){
                            currentPage++;
                        }
                        totalRecords++;
                    }
                }
            }
            system.debug(Issue+ '------searchText--------' + searchText);
            system.debug(csMap + '------csMap.size()--------' + csMap.size());

            if(csMap.size() > 0){
                csList.addAll(csMap.get(1));
                totalPage = csMap.size();
                currentPage = 1;
                resultFlag = true;
            }
            system.debug(resultFlag + '-----csList--------' + csList);
            system.debug('----currentPage----'+currentPage);
            system.debug('----totalPage----'+totalPage);
            system.debug('----perPageRecords----'+perPageRecords);
        }else{
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Product,Type and Search text is mandatory.'));
        }
    }

    public void searchTFSIssue(set<Id> csIds){
        try{
            system.debug(Issue.Type + '-------------------' + Issue.Product__c + '-----------' + searchText);
            xmlnsOracleComTfssfdcTnvSearch.TnvSfdcOutboundSearchtoTfsBPELProcess_pt temp = new xmlnsOracleComTfssfdcTnvSearch.TnvSfdcOutboundSearchtoTfsBPELProcess_pt();
            xmlnsOracleComTfssfdcTnvSearch.SearchParamsType SearchParams = new xmlnsOracleComTfssfdcTnvSearch.SearchParamsType();
            if(TFS_Project_Config__c.getAll().get(Issue.Product__c) != null)
                SearchParams.projectName = TFS_Project_Config__c.getAll().get(Issue.Product__c).Project_Name__c;
            else
                SearchParams.projectName = TFS_Project_Config__c.getAll().get('Default').Project_Name__c;

            SearchParams.issueType = (Issue.Type != null ? Issue.Type : '');
            SearchParams.searchValue = (searchString != null ? searchString : '');
            SearchParams.Division = division;


            system.debug('---------SearchParams----------' + SearchParams);
            xmlnsOracleComTfssfdcTnvSearch.SearchParamsResultType result = new xmlnsOracleComTfssfdcTnvSearch.SearchParamsResultType();
            if(!Test.isRunningTest()){
                result = temp.process(SearchParams);
                system.debug('---------result----------' + result);
            }
            else{ // Running Test
                result.tfsWorkItemBean = new List<XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean>();
                result.resultCount = '1';

                XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean tData = new XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean();
                tData.assignedTo = 'Suresh';
                tData.tfsId = '12345';
                tData.tittle = 'test';
                tData.description = 'test Desc';
                result.tfsWorkItemBean.add(tData);
            }

            tfsIdWorkItemMap = new Map<String,XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean>();
            Map<String,Id> tfsIdCaseMap = new Map<String,Id>();
            for(XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean workItem : result.tfsWorkItemBean){
                system.debug('---------workItem----------' + workItem);
                if(workItem.TFSID != null && workItem.TFSID != '')tfsIdWorkItemMap.put(workItem.TFSID,workItem);
            }

            if(tfsIdWorkItemMap.size() > 0){
                for(Case cs : [Select Id,TFS_Id__c,CaseNumber from Case where TFS_Id__c in : tfsIdWorkItemMap.keySet()]){
                    tfsIdCaseMap.put(cs.TFS_Id__c,cs.Id);
                }

                system.debug('---------tfsIdCaseMap----------' + tfsIdCaseMap);
                Case csObj = new Case();
                for(XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean workItem : result.tfsWorkItemBean){
                    if(!csIds.contains(tfsIdCaseMap.get(workItem.TFSID))){
                        csObj = new Case();
                        if(tfsIdCaseMap.get(workItem.TFSID) != null)
                            csObj.Id = tfsIdCaseMap.get(workItem.TFSID);
                        if(csMap.get(currentPage) == null)
                            csMap.put(currentPage,new List<Case>());
                        csMap.get(currentPage).add(csObj);
                        csObj.TFS_ID__c = (workItem.TFSId != null ? workItem.TFSId : '');
                        String description = workItem.Description;
                        if(description != null){
                            system.debug('---------------'+ description);
                            description = description.replaceAll('<br>', '\n');
                            description = description.replaceAll('<*br*/>', '\n');
                            description = description.replaceAll('<div>', '\n');
                            description = description.replaceAll('<p>', '\n');
                            system.debug('------description------' + description);
                            system.debug('---------------'+ description);
                            string HTML_TAG_PATTERN = '<.*?>';
                            pattern myPattern = pattern.compile(HTML_TAG_PATTERN);
                            system.debug('---------------'+ description);
                            matcher myMatcher = myPattern.matcher(description);
                            description = myMatcher.replaceAll('');
                            description = description.replaceAll('&nbsp;', '');
                            description = description.replaceAll(description.substringAfter('##'),'').replaceAll('##','');
                        }
                        system.debug('---------------');
                        csObj.Description = description.subString(0,(description.length() > 32000 ? 32000 : description.length()));
                        system.debug('---------------'+ workItem.tittle);
                        csObj.Subject = (workItem.tittle != null ? workItem.tittle.subString(0,(workItem.tittle.length() > 255 ? 255 : workItem.tittle.length())) : '');
                        system.debug('---------------'+ workItem.foundInBiuld);
                        csObj.Type = (Issue.Type != null ? Issue.Type : '');
                        csObj.Found_In_Build__c = (workItem.foundInBiuld != null ? workItem.foundInBiuld : '');
                        system.debug('---------------'+ workItem.state);
                        csObj.TFS_Status__c = (workItem.state != null ? workItem.state : '');
                        csObj.Product__c = Issue.Product__c;

                        if(csMap.get(currentPage).size() >= VF_Page_Paggination_Config__c.getAll().get('Search_Defect').Records_Per_Page__c){
                            currentPage++;
                        }
                        totalRecords++;
                    }
                }
            }

            system.debug(csMap + '------csMap.size()--------' + csMap.keySet()+'------'+currentPage);
        }catch(Exception ex){

        }
    }


    public void changeIssue(){
        cs.Defect__c = null;
        update cs;
        Issue = new Case();
        Issue.RecordTypeId = defectTypeId;
        searchString = '';
    }

    public void previous(){
        currentPage--;
        if(csMap.containsKey(currentPage)){
            csList = new List<Case>();
            csList.addAll(csMap.get(currentPage));
            if(csList.size()>0){
                resultFlag = true;
            }else{
                resultFlag = false;
            }
        }
    }

    public void first(){
        currentPage = 1;
        if(csMap.containsKey(currentPage)){
            csList = new List<Case>();
            csList.addAll(csMap.get(currentPage));
            if(csList.size()>0){
                resultFlag = true;
            }else{
                resultFlag = false;
            }

        }
    }

    public void next(){
        currentPage++;
        if(csMap.containsKey(currentPage)){
            csList = new List<Case>();
            csList.addAll(csMap.get(currentPage));
            if(csList.size()>0){
                resultFlag = true;
            }else{
                resultFlag = false;
            }
        }
        system.debug(resultFlag + '-----csList--------' + csList);
    }

    public void last(){
        currentPage = totalPage;
        if(csMap.containsKey(currentPage)){
            csList = new List<Case>();
            csList.addAll(csMap.get(currentPage));
            if(csList.size()>0){
                resultFlag = true;
            }else{
                resultFlag = false;
            }

        }
    }

    public void AttachIssueToCase(){
        if(selectedIssueSFDCId != null){
            cs.defect__c = selectedIssueSFDCId;
            update cs;

            Issue = new Case();
            if(cs.Defect__c != null){
                Issue = [select Id,TFS_Status__c,Product__c,CaseNumber,TFS_Id__c, Subject,Type,Fixed_in_Build__c,Confirmed_in_Build__c,
                       TFS_Close_Date__c,Features__c,Description from Case where Id =: cs.Defect__c];
            }
        }
    }

    public void createIssueFromTFS(){
        if(selectedIssueTFSId != null && tfsIdWorkItemMap.containsKey(selectedIssueTFSId)){
            XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean workItem = tfsIdWorkItemMap.get(selectedIssueTFSId);
            Case csObj = new Case();
            csObj.TFS_ID__c = (workItem.TFSId != null ? workItem.TFSId : '');
            system.debug('------------' + workItem.Description);
            String description = workItem.Description;
            if(description != null){
                description = description.replaceAll('<br>', '\n');
                description = description.replaceAll('<*br*/>', '\n');
                description = description.replaceAll('<div>', '\n');
                description = description.replaceAll('<p>', '\n');
                system.debug('------description------' + description);
                string HTML_TAG_PATTERN = '<.*?>';
                pattern myPattern = pattern.compile(HTML_TAG_PATTERN);
                matcher myMatcher = myPattern.matcher(description);
                description = myMatcher.replaceAll('');
                description = description.replaceAll('&nbsp;', '');
                description = description.replaceAll(description.substringAfter('##'),'').replaceAll('##','');
            }
            csObj.Description = description.subString(0,(description.length() > 32000 ? 32000 : description.length()));
            system.debug('------------' + workItem.tittle);
            csObj.Subject = (workItem.tittle != null ? workItem.tittle.subString(0,(workItem.tittle.length() > 255 ? 255 : workItem.tittle.length())) : '');
            system.debug('------------' + Issue.Type);
            csObj.Type = (Issue.Type != null ? Issue.Type : '');
            system.debug('------------' + workItem.foundInBiuld );
            csObj.Found_In_Build__c = (workItem.foundInBiuld != null ? workItem.foundInBiuld : '');
            system.debug('------------' + workItem.state );
            csObj.TFS_Status__c = (workItem.state != null && workItem.state != '' ? workItem.state : '');
            csObj.Integration_Exception_Message__c = 'Success';
            csObj.Product__c = Issue.Product__c;
            csObj.RecordTypeId = defectTypeId;
            CaseHandler.sendTFSItegration = false;
            insert csObj;

            cs.Defect__c = csObj.Id;
            update cs;

            Issue = [select Id,TFS_Status__c,Product__c,CaseNumber,TFS_Id__c, Subject,Type,Fixed_in_Build__c,Confirmed_in_Build__c,
                       TFS_Close_Date__c,Features__c,Description from Case where Id =: cs.Defect__c];
        }
    }

    public void pushIssueToJIRA(){
      if(selectedIssueSFDCId != null){
        List<Case> lstCaseUpdate = new List<Case>();
        cs.defect__c = selectedIssueSFDCId;
        lstCaseUpdate.add(cs);

        Case IssueUpdate = [SELECT Id, TFS_Id__c FROM Case WHERE Id =: selectedIssueSFDCId LIMIT 1];
        IssueUpdate.TFS_Id__c = null;
        IssueUpdate.Is_JIRA_Linked__c = true;
        lstCaseUpdate.add(IssueUpdate);
        update lstCaseUpdate;

        Issue = [SELECT Id, TFS_Status__c, Product__c, CaseNumber, TFS_Id__c, Subject, Type, Fixed_in_Build__c, Confirmed_in_Build__c, TFS_Close_Date__c, Features__c, Description FROM Case WHERE Id =: selectedIssueSFDCId];
      }
    }
}