@isTest
public class CustomAccountLookupController_Test{

    static testmethod void Test1(){
        CustomAccountLookupController calc = new CustomAccountLookupController();
        calc.searchString = 'Test';
        calc.search();
        calc.getFormTag();
        calc.getTextBox();
    }
}