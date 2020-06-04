@isTest
public class TestNewContactOverrideController {
    public static User createUser(string prefix , string languageCode){
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = prefix + 'Admin' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = prefix + 'ur', Email=uniqueUserName,
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey=languageCode,
                          LocaleSidKey=languageCode, ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName , Division__c = 'MEP NA');
        return u;
    }
    
    public static  testmethod void TestNewContactOverrideController(){
        for(String prefix : 'en_US,de,es,fr,it,ja,sv,ko,zh_CN,pt_BR,nl_NL,da,th,fi,ru,no'.split(',')){
            System.runAs(createUser(prefix , prefix)) {
                NewContactOverrideController temp = new NewContactOverrideController(null);
                temp.continueContactCreation();
            }
        }
    }
}