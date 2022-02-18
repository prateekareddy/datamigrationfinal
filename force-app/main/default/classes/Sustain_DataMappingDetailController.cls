public class Sustain_DataMappingDetailController {
    private static final string CurrentClassName = 'Sustain_DataMappingDetailController';
    public class mainWrapper {
        @AuraEnabled
        public list<totalRcdCountwrapper> totalDataList;
        @AuraEnabled
        public totalCountwrapper totalCounts ;
        public mainWrapper(list<totalRcdCountwrapper> totalDataList, totalCountwrapper totalCounts) {
            this.totalDataList= totalDataList;
            this.totalCounts = totalCounts;
        }
    }
    
    public class totalCountwrapper{
        @AuraEnabled
        public integer totalObject;
        @AuraEnabled
        public integer totalFileds;
        @AuraEnabled
        public integer removedFileds;
        @AuraEnabled
        public integer pendingReview;      
        
        @AuraEnabled
        public long dataRecords;
        @AuraEnabled
        public string estLoadTime;     
        
        public totalCountwrapper(integer totalObject, integer totalFileds, integer removedFileds, integer pendingReview,
                                 long dataRecords,string estLoadTime){
                                     this.totalObject = totalObject;
                                     this.totalFileds = totalFileds;
                                     this.removedFileds = removedFileds;  
                                     this.pendingReview = pendingReview;  
                                     this.dataRecords = dataRecords;
                                     this.estLoadTime = estLoadTime;    
                                 }
        
    }
    
    public class totalRcdCountwrapper{
        integer totaFields;
        integer totaFieldsMapped;
        @AuraEnabled
        public id recordId;
        @AuraEnabled
        public string sourceObjLabel;
        @AuraEnabled
        public string recordType;
        @AuraEnabled
        public string destObjLabel;
         @AuraEnabled
        public string destObjApi;
        @AuraEnabled
        public string fieldsMapped;  
        @AuraEnabled
        public boolean status;
        
        public totalRcdCountwrapper(integer totaFields,integer totaFieldsMapped, string sourceObjLabel, string recordType, string destObjLabel,
                                    boolean status,id recordId,string destObjApi){
                                        this.sourceObjLabel = sourceObjLabel;
                                        this.recordType = recordType;
                                        this.destObjLabel = destObjLabel;  
                                        this.fieldsMapped = totaFieldsMapped+'/'+totaFields;
                                        this.status = status;   
                                        this.recordId =  recordId;
                                        this.destObjApi = destObjApi;
                                    }
        
    }
    
    @AuraEnabled
    public static mainWrapper getDataMappingDetails() {        
        totalRcdCountwrapper recordObj = null;
        
        totalRcdCountwrapper recObj1 = null;
        totalRcdCountwrapper recObj2 = null;
        
        list<totalRcdCountwrapper> totalDataList = new list<totalRcdCountwrapper> ();
        list<totalRcdCountwrapper> tempDataList1 = new list<totalRcdCountwrapper> ();
        list<totalRcdCountwrapper> tempDataList2 = new list<totalRcdCountwrapper> ();
        
        list<Object_Mappings__c> objDetails  = [select id, Source_Object__c,Total_Records__c,Target_Object__c,Source_Object_Label__c,Source_Recordtype_Label__c,  
                Destination_Object_Label__c , Total_Fields__c,Total_To_Review_Fields__c,Removed_Field_Mapping_Count__c  from Object_Mappings__c where 
                Mapping_Included__c=true AND Total_Mapping_Eligible_Field__c > 0 AND  Check_Source_And_Target__c ='true' 
                order by Removed_Field_Mapping_Count__c DESC, Source_Object_Label__c ASC];
        integer totalFieldsCount = 0;
       
        integer totalPendingReview = 0;
        integer totalRemovedFileds = 0;
        integer totaFieldsMapped = 0;
        long totalRecodCount = 0;
        Integer totalObjectCount = 0;

        Set<String> sourceObjects = new Set<String>(); 
        list<string> objName = new list<string>();
        
        if(objDetails != null) {
           
            for (Object_Mappings__c obj : objDetails) {
                totalFieldsCount+=Integer.valueOf(obj.Total_Fields__c);
                totalPendingReview+= Integer.valueOf(obj.Total_To_Review_Fields__c);
                totalRemovedFileds+=Integer.valueOf(obj.Removed_Field_Mapping_Count__c);
                totaFieldsMapped = Integer.valueOf(obj.Total_Fields__c) - Integer.valueOf(obj.Removed_Field_Mapping_Count__c);
                boolean status = totaFieldsMapped == Integer.valueOf(obj.Total_Fields__c) ? true : false;
                
                recordObj = new totalRcdCountwrapper(Integer.valueOf(obj.Total_Fields__c), totaFieldsMapped, obj.Source_Object_Label__c, 
                            obj.Source_Recordtype_Label__c, obj.Destination_Object_Label__c,status, obj.id,obj.Target_Object__c);
                if(obj.Total_Records__c != null){
                    totalRecodCount = totalRecodCount + long.valueOf(obj.Total_Records__c);
                }
                objName.add(obj.Source_Object__c);
                totalDataList.add(recordObj) ;
                if(!sourceObjects.contains(obj.Source_Object__c)){
                    totalObjectCount++;
                    sourceObjects.add(obj.Source_Object__c);
                }
            }
        }
             
        totalCountwrapper totalCountObj  = new totalCountwrapper(totalObjectCount, totalFieldsCount, totalRemovedFileds, totalPendingReview,totalRecodCount,'');
        mainWrapper resultObj = new mainWrapper(totalDataList, totalCountObj);  
        return resultObj;
    }
    
    @AuraEnabled
    public static boolean updateMigrationStatus(String stepNo){
        string CurrentMethodName = 'updateMigrationStatus';
        string stage=Sustain_UtilConstants.stepStageMap.get(stepNo);
        try{    
            Migration_Status__c ms = Migration_Status__c.getOrgDefaults();
            ms.Current_Migration_Stage__c = stage;
            update ms;
            return true;
        }catch(Exception ex){
            Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName);
            return false;
        }       
    }
    @testVisible
    private static Long getTotalRecordCount(List<String> objNames) {
        long totalRcdCount = 0;
        try {
            if(objNames != null) {
                for(String objName :objNames) {
                    string query = 'select count() from '+ objName;
                    totalRcdCount+= database.countQuery(query);
                }
            }
        }catch(exception e) {
            system.debug('error-->' + e.getmessage());
        }
        return totalRcdCount;
    }
}