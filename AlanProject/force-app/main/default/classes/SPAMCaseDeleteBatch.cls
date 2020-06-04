/* Class Name  : SPAMCaseDeleteBatch
 * Created By  : Prajakta S
 * Description : This batch class will delete all cases owned by SPAM queue
 */

public class SPAMCaseDeleteBatch implements Database.Batchable <sObject> {
public final String query;
public SPAMCaseDeleteBatch(String q) {
query = q;
}
public Database.QueryLocator start(Database.BatchableContext BC){
return Database.getQueryLocator(query);
}
public void execute(Database.BatchableContext BC,List<Case> lstCases){
delete lstCases;
}
public void finish(Database.BatchableContext BC){
}
}