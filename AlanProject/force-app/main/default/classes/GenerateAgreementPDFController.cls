/*
* Author:         Ankur
* Last Update:    Aug 8, 2017
* Version:        1.0
* Description:    Generate PDF and attach it to Case
*
* History:      

    Aug 8, 2017 Version - 1.0 - Kumar: Created web service to generate PDF and attach it to Case
*/
global class GenerateAgreementPDFController { 
    
    //Method call from custom button ti publish multiple Download Files
	webservice static string generateAgreementPDF(string caseId){
        // Create PDF
        Blob reportPdf;
		
        try {
            system.debug('---------caseId--------' + caseId);
            if(caseId != null && caseId != ''){
            	PageReference pgRef = new PageReference('/apex/AgreementPDF?id=' + caseId);
                if(!Test.isRunningTest())reportPdf = pgRef.getContentAsPDF();
                else reportPdf = blob.valueOf('Test');
                Attachment att = new Attachment();
                att.Name = 'Agreement PDF ' + Date.today().format() + '.pdf';
                att.ParentId = caseId;
                att.ContentType = 'application/pdf';
                att.Body = reportPdf;
                insert att;
                system.debug('-----------------' + att.Id);
                return '/servlet/servlet.FileDownload?file=' + att.Id;
            }else{
                return 'Error : Invalid Case Id.';
            }
        }catch(Exception ex){
            return 'Error : ' + ex.getMessage();
        }
    }
}