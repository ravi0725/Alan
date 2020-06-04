/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : 
 * History     :  

 * [3.5.2015] Ankur Patel  Created
 */
 @isTest(seeAllData = true)
public class TestPartnerSOAPSforceCom_V1 {
    private static testmethod void TestPartnerSOAPSforceCom_V1_1(){
        partnerSoapSforceCom_v1.GetUserInfoResult temp1 = new partnerSoapSforceCom_v1.GetUserInfoResult();
        partnerSoapSforceCom_v1.login_element temp2 = new partnerSoapSforceCom_v1.login_element();
        partnerSoapSforceCom_v1.loginResponse_element temp3 = new partnerSoapSforceCom_v1.loginResponse_element();
        partnerSoapSforceCom_v1.LoginResult temp4 = new partnerSoapSforceCom_v1.LoginResult();
        partnerSoapSforceCom_v1.SessionHeader_element temp5 = new partnerSoapSforceCom_v1.SessionHeader_element();
        partnerSoapSforceCom_v1.Soap temp6 = new partnerSoapSforceCom_v1.Soap();
        Try{
            temp6.login('', '');
        }catch(Exception ex){
            
        }
    }
}