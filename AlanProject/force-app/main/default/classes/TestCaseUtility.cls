@isTest(Seealldata=true)
public class TestCaseUtility
{
    public static  testmethod void caseUtility1()
    {
        Case c = new Case(Status = 'New', AccountId = '001i000001XutWy', RecordtypeId = '012i0000001EQuR', Priority = 'Medium', Subject = 'Test', Description = 'Test' );
       insert c;
       
       c.Status = 'SA Research In Progress';
       update c;
       
    }
}