public class ObjMappingListWrapper{
    @AuraEnabled
    public List<Object_Mappings__c> customObjList;
    @AuraEnabled
    public List<Object_Mappings__c> stdObjList;
    @AuraEnabled
    public List<Object_Mappings__c> stdObjwithCustFieldList;
    @AuraEnabled
    public Map<String,String> coreObjectMap;
}