@isTest
public class CustomUserLookupController_Test{

    static testmethod void Test1(){
        
        CustomUserLookupController culc = new CustomUserLookupController();
        culc.search();
        //culc.saveUser();
        culc.getFormTag();
        culc.getTextBox();
    }
    
    
}