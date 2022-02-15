// Wrapper class for org scan output data
public class OrgScanOutputWrapper {
    @AuraEnabled
    public Integer noOfSCObjects; 
    @AuraEnabled
    public Integer noOfCustomObjects; 
    @AuraEnabled
    public List<String> customObjectList;
    @AuraEnabled 
    public Integer noOfCustomFields;
    @AuraEnabled
    public Integer noOfObjectwithCustomFields; 
    @AuraEnabled
    public String packageVer;  
    @AuraEnabled
    public List<CustomObjectInfo> coInfoList;
}