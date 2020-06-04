/* Class Name  : CaseDeleteSchedule
 * Created By  : Prajakta S
 * Description : This is a schedulable class for SPAMCaseDeleteBatch that 
 *               provides list of case records to be deleted
 */

public class CaseDeleteSchedule implements Schedulable {
public void execute(SchedulableContext sc) {
// The query used by the batch job.
Group grp = [select Id from Group where Name = 'SPAM' and Type = 'Queue'];
String query = 'select id from Case where OwnerId = \'' + grp.Id + '\''  ;

SPAMCaseDeleteBatch caseDelBatch = new SPAMCaseDeleteBatch (query);
Id BatchProcessId = Database.ExecuteBatch(caseDelBatch );
}
}