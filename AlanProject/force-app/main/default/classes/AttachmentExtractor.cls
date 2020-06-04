global with sharing class AttachmentExtractor implements Iterator<String>, Iterable<String>
{
    private List<String> strList;
    public AttachmentExtractor(List<String> stList){
        strList = new List<String>();
        strList.addAll(stList);
        system.debug('---strList---'+strList);
    }
    global Boolean hasNext(){
        system.debug('---strList---'+strList.size());
        return strList.size() > 0 ? true : false;
    }
    
    global String next(){
        String col = strList.get(0);
        strList.remove(0);
        system.debug('---col---'+col);
        return col;
    }
    global Iterator<String> Iterator(){
        return this;   
    }
}