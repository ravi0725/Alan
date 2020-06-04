@isTest 
public class TestSLAReportController
{

    public static testmethod void SLAReportTest()
    {
        SLAReportController sla = new SLAReportController (); 
        sla.slacase.accountId = '001i000001XutWyAAJ';
        sla.getReport();
        sla.exportReport();
    
    }

}