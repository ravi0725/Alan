public class CSVReader { 
    private integer position = 0;
    private static string COMMA = ',';
    private static string NL = '\n';
    private static string QUOTE = '"';
    private static string DOUBLE_QUOTE = '""';

    public static List<sObject> ReadLine(List<String> rows,List<string> fields,Import_Data__c data){
        List<sObject> objRecordsList = new List<sObject>();
        for(String line : rows) {
            integer startPos = 0;
            Integer position = 0;
            string currentValue;
            integer cAt, nlAt, foundAt;
            Integer csvStringLength = line.length();
            List<String> cleanFields = new List<String>();
            while (position < csvStringLength){
                cAt = line.indexOf( COMMA, position );
                nlAt = line.indexOf( NL, position );
                foundAt = Math.min( cAt, nlAt );
                if( foundAt == -1 )
                    foundAt = Math.max( cAt, nlAt );
                
                
                if (foundAt == -1)
                {
                    currentValue = line.substring(startPos);
                    position = csvStringLength;
                }
                else
                {
                    currentValue = line.substring(startPos, foundAt );
                    position = foundAt + 1;
                }
                
                
                if( !currentValue.startsWith( QUOTE ) )
                {
                    cleanFields.add( currentValue );
                    
                    if( foundAt == nlAt )
                        break;
                    
                    startPos = position;
                }
                else if( currentValue.endsWith( QUOTE ) && !currentValue.endsWith( DOUBLE_QUOTE ) )
                {
                    if( currentValue.indexOf( DOUBLE_QUOTE ) == -1 )
                        cleanFields.add( currentValue.substring( 1, currentValue.length() - 1 ) );
                    else
                        cleanFields.add( currentValue.substring( 1, currentValue.length() - 1 ).replace( DOUBLE_QUOTE, QUOTE ) );
                    
                    if( foundAt == nlAt )
                        break;
                    
                    startPos = position;
                }
            }
            
            Schema.SObjectType convertType = Schema.getGlobalDescribe().get(data.Object__c);
            Sobject genericObject = convertType.newSObject();
            system.debug('--genericObject--'+genericObject);
            for(Integer i=0; i<cleanFields.size(); i++){
                system.debug('--field--'+fields[i]+'  --value--'+cleanFields[i]);
                string datatype = '';
                datatype = XMLUtility.getDataType(data.Object__c,fields[i]);
                if(cleanFields[i] != ''){
                    if(dataType == 'TEXT' || dataType == 'REFERENCE'){
                        genericObject.put(fields[i],cleanFields[i]);
                    }else if(dataType == 'DATETIME'){
                        genericObject.put(fields[i],(cleanFields[i]== null ? null : DateTime.parse(cleanFields[i])));
                    }else if(dataType == 'DATE'){
                        genericObject.put(fields[i],(cleanFields[i]== null ? null : date.parse(cleanFields[i])));
                    }else if(dataType == 'DECIMAL'){
                        genericObject.put(fields[i],(cleanFields[i]== null ? null : Decimal.valueOf(cleanFields[i])));
                    }else if(dataType == 'BOOLEAN' && cleanFields[i]!= null && cleanFields[i]!= ''){
                        if(cleanFields[i].equals('Yes') || cleanFields[i].equals('YES') || 
                           cleanFields[i].equals('1') || cleanFields[i].equals('true') ||
                           cleanFields[i].equals('True') || cleanFields[i].equals('TRUE'))
                           genericObject.put(fields[i],true);
                        else
                           genericObject.put(fields[i],false);
                    }
                }
                //genericObject.put(fields[i],cleanFields[i]);    
            }
            objRecordsList.add(genericObject);
            system.debug('--objRecordsList--'+objRecordsList);
        }
        return objRecordsList;
    }
}