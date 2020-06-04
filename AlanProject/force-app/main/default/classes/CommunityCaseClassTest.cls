@isTest
Private class CommunityCaseClassTest{

    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static Case cs;
    
    static void setUpData(){
    
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        cs = new Case();
        cs.Origin='Phone';
        cs.Status = 'Open';
        cs.status_reason__c='New Unassigned';
        cs.Subject ='XYZ';
        cs.Description='Xyz Description';
        insert cs;
    }   

    private static testmethod void testNewCase(){
        
        setUpData();
        Test.startTest();
            CommunityCaseClass cont = new CommunityCaseClass(new Apexpages.StandardController(cs));
            cont.newCase();
        Test.stopTest();
        
    }       
}