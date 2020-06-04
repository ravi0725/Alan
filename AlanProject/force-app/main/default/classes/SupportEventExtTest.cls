@isTest
private class SupportEventExtTest{

static testmethod void testSupportEvent(){
ID oid = UserInfo.getUserId();
DateTime StatT = system.Now();
DateTime EndT = system.now().addminutes(30);
Event Ev = new Event(Subject='Sample Event', Type='Other',OwnerID=oid,StartDateTime=StatT,EndDateTime=EndT);
insert Ev;
ApexPages.currentPage().getParameters().put('Id',Ev.id);
ApexPages.StandardController controller = new ApexPages.StandardController(Ev);
SupportEventExt bsExt = new SupportEventExt(controller);
bsExt.PerformDML();

}
}