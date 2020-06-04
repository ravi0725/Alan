/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : 
 * History     :  

 * [30.4.2015] Ankur Patel  Created
 */
 @isTest(seeAllData = true)
public class TestBatchDeleteProposalEmailTemplate{
    public static testmethod void TestBatchDeleteProposalEmailTemplate1(){
        test.startTest();
        BatchDeleteProposalEmailTemplate temp = new BatchDeleteProposalEmailTemplate ();
        system.schedule('TestClassSchedule' , '0 0 * * * ?' , temp);
        test.StopTest();
    }
}