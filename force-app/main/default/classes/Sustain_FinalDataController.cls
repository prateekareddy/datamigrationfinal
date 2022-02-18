/**
 * @description       : 
 * @author            : Accenture
 * @group             : 
 * @last modified on  : 09-29-2021
 * @last modified by  : Accenture
**/
public class Sustain_FinalDataController {
    
    private static final string CurrentClassName = 'Sustain_FinalDataController';
    
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
        @AuraEnabled
        public String totalRecCount;
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
        @AuraEnabled
        public string Objstatus;        
        @AuraEnabled
        public string sourceObjRecType;
        @AuraEnabled
        public string sourceObjApi;
        
        public totalRcdCountwrapper(integer totaFields,integer totaFieldsMapped, string sourceObjLabel, string recordType, string destObjLabel,
                                    boolean status,id recordId,string destObjApi, string totalRecCount,string Objstatus,string sourceObjRecType,string sourceObjApi){
                                        this.sourceObjLabel = sourceObjLabel;
                                        this.recordType = recordType;
                                        this.destObjLabel = destObjLabel;  
                                        this.fieldsMapped = totaFieldsMapped+'/'+totaFields;
                                        this.status = status;   
                                        this.recordId =  recordId;
                                        this.destObjApi = destObjApi;
                                        this.totalRecCount =totalRecCount;
                                        this.Objstatus=Objstatus;
                                        this.sourceObjRecType=sourceObjRecType;
                                        this.sourceObjApi=sourceObjApi;
                                    }
        
    }
    
    @AuraEnabled
    public static mainWrapper getDataMappingDetails() {        
        totalRcdCountwrapper recordObj = null;
        list<totalRcdCountwrapper> totalDataList = new list<totalRcdCountwrapper> ();
      
        list<Object_Mappings__c> objDetails  = [select id, Source_Object__c,Status__c,Target_Object__c,Source_Object_Label__c,Total_Records__c,Source_Recordtype_Label__c,Source_Record_Type__c, Destination_Object_Label__c    , Total_Fields__c,Total_To_Review_Fields__c,Removed_Field_Mapping_Count__c  from Object_Mappings__c where Mapping_Included__c=true order by sequence_number__c ASC nulls last];
        integer totalRecCount =0;
        integer totalFieldsCount = 0;
        integer totalObjCount = 0;
        integer totalPendingReview = 0;
        integer totalRemovedFileds = 0;
        integer totaFieldsMapped = 0;
        long totalRecodCount = 0;
        list<string> objName = new list<string>();
        if(objDetails != null) {
            totalObjCount = objDetails?.size();
            system.debug('totalObjCount-->'+totalObjCount);
            for (Object_Mappings__c obj : objDetails) {
                system.debug('inside Object_Mappings__c for-->');
                totalFieldsCount+=Integer.valueOf(obj.Total_Fields__c);
                totalPendingReview+= Integer.valueOf(obj.Total_To_Review_Fields__c);
                totalRemovedFileds+=Integer.valueOf(obj.Removed_Field_Mapping_Count__c);
                totaFieldsMapped = Integer.valueOf(obj.Total_Fields__c) - Integer.valueOf(obj.Removed_Field_Mapping_Count__c);
                if(obj.Total_Records__c != null)
                    totalRecCount = Integer.valueOf(obj.Total_Records__c);
                boolean status = totaFieldsMapped == Integer.valueOf(obj.Total_Fields__c) ? true : false;
                system.debug('status-->'+status);
                recordObj = new totalRcdCountwrapper(Integer.valueOf(obj.Total_Fields__c), totaFieldsMapped, obj.Source_Object_Label__c, 
                                                     obj.Source_Recordtype_Label__c,obj.Destination_Object_Label__c,status, obj.id,obj.Target_Object__c,obj.Total_Records__c,obj.Status__c,obj.Source_Record_Type__c, obj.Source_Object__c);
                objName.add(obj.Source_Object__c);
                totalDataList.add(recordObj) ;
            }
            system.debug('outside Object_Mappings__c for-->');
        }
        totalRecodCount = getTotalRecordCount(objName);
        totalCountwrapper totalCountObj  = new totalCountwrapper(totalObjCount, totalFieldsCount, totalRemovedFileds, totalPendingReview,totalRecodCount,'');
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
    @AuraEnabled
    public static Data_Load_Request__c getLatestDataLoad(){
        try{
            List<Data_Load_Request__c> dataRecStatus = [Select id,Name,End_Date_Time__c,Status__c,Data_Load_Type__c,LastModifiedDate from Data_Load_Request__c order by CreatedDate desc Limit 1];
            if(dataRecStatus.size()>0){
                return dataRecStatus[0];
            }
            else{
                return null;
            }
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
            return null;
        } 
        
    }
    @AuraEnabled
    public STATIC boolean startFinalDataLoad(){
        String CurrentMethodName = 'startFinalDataLoad';
        map<String, list<Object_Mappings__c>>objMap = new  map<String, list<Object_Mappings__c>>();
        Map<String,List<Field_Mappings__c>> fldMap = new Map<String,List<Field_Mappings__c>> ();
        Data_Load_Request__c dataRec = new Data_Load_Request__c();
        try{
            List<String> orgAssetIds = new List<String>();         
            system.debug('startFinalDataLoad');
            dataRec.Request_Job_Name__c = 'Complete Data Load';
            dataRec.Start_Date_Time__c = system.now();
            dataRec.Data_Load_Type__c = 'Complete Data Load';
            dataRec.Status__c = 'In Progress';
            integer seqNo;
            Database.insert(dataRec);
            if(String.isNotBlank(dataRec.Id)){  
                seqNo = Sustain_Utils.getSequebnceNo(1);
                string sqlStr = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c,Batch_Size__c from Object_Mappings__c where Sequence_Number__c=:seqNo and Status__c = \'Not Started\' AND Object_Type__c != \'custom\' and mapping_included__c=true order by  sequence_number__c,Target_Object__c nulls last';
                system.debug('createDataLoadReq sql -->' + sqlStr);
                list<Object_Mappings__c> objMappingList = Database.query(sqlStr);
                if(objMappingList != null && objMappingList.size() > 0) {                    
                    list<id> recordIds =  new list<id>();
                    Integer batchSize = 200;
                    if(objMappingList != null) {
                        for(Object_Mappings__c obj : objMappingList) {
                            recordIds.add(obj.id);
                            string rectype = obj.Source_Record_Type__c != null ? obj.Source_Record_Type__c.replaceAll('sustain_app__','').replaceAll('Sustain_app__','') : '';
                            string key = obj.Source_Object__c + '-' + rectype;
                            if(objMap.keyset().contains(key)) {
                                objMap.get(key).add(obj);
                            } else {
                                list<Object_Mappings__c> tempList = new list<Object_Mappings__c>();
                                tempList.add(obj);
                                objMap.put(key,tempList);
                                batchSize = obj.Batch_Size__c != null ? obj.Batch_Size__c.intValue() : 200 ;
                            }
                        }
                        String querySql = 'SELECT id, Object_Mapping__c,Reference_To__c,Source_Field__c,Target_Field__c,Object_Mapping__r.Source_Object__c,Object_Mapping__r.Source_Record_Type__c,Source_Field_Type__c,Object_Mapping__r.Target_Object__c,Object_Mapping__r.Target_Record_Type__c,New_Field__c FROM Field_Mappings__c where Object_Mapping__c in :recordIds and mapping_included__c=true and Calculated__c = false order by Object_Mapping__c asc';  
                        list<Field_Mappings__c> fldList = database.query(querySql);  
                        if(fldList != null) {
                            for(Field_Mappings__c eachFld : fldList) {
                                if(fldMap.keyset().contains( eachFld.Object_Mapping__c)) {
                                    fldMap.get(eachFld.Object_Mapping__c).add(eachFld);
                                } else {
                                    list<Field_Mappings__c> tempList = new list<Field_Mappings__c>();
                                    tempList.add(eachFld);
                                    fldMap.put( eachFld.Object_Mapping__c,tempList);                        
                                }
                            }
                        } 
                        Sustain_FinalDataLoadBatch nextBatch = new Sustain_FinalDataLoadBatch(objMap, fldMap,seqNo  , orgAssetIds, dataRec.id);
                        database.executeBatch(nextBatch, (batchSize != null && batchSize !=0) ? batchSize : 200);
                    } else {
                        string sqlStr1 = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c,Batch_Size__c from Object_Mappings__c where Status__c = \'Not Started\' AND Object_Type__c = \'custom\' and mapping_included__c=true order by  sequence_number__c,Target_Object__c nulls last limit 1';    
                        list<Object_Mappings__c> customObjectList = Database.query(sqlStr1);
                        if(customObjectList!=null && customObjectList.size() > 0){                
                            Sustain_UpdateCustomObjectRefBatch nextcustBatch = new Sustain_UpdateCustomObjectRefBatch(customObjectList[0], 'FinalDataLoad');
                            database.executeBatch(nextcustBatch, (customObjectList[0].Batch_Size__c != null && customObjectList[0].Batch_Size__c.intValue() !=0) ? customObjectList[0].Batch_Size__c.intValue() : 200);
                        } else {
                            dataRec.Status__c = 'Completed';
                            update dataRec; 
                        }
                    }
                } else {                    
                    dataRec.Status__c = 'Completed';
                    update dataRec; 
                }
            } 
        }catch(Exception e){
            dataRec.Status__c = 'Failed';
            update dataRec;  
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);          
            System.debug('An exception occurred: ' + e.getMessage());
            return false;
        }  
        return true;
        
    }
    @AuraEnabled
    public static void deleteDataLoadReq(){
        Sustain_SampleDataLoadCtrl.deleteDataLoadReq();
    }

    @AuraEnabled
    public static void deleteErrorDataLoadReq(Boolean isErrorRevertOnly){
        Sustain_SampleDataLoadCtrl.deleteErrorDataLoadReq(isErrorRevertOnly);
    }
    
   @AuraEnabled
    public static Id getREportIdByObjName(string srcApiName, string srcRcdType) {
        system.debug('srcApiName--->'+srcApiName);
        List<Sustain_Report_Object__mdt> value= [select Report_Developer_Name__c from Sustain_Report_Object__mdt where Source_Object_Name__c= :srcApiName LIMIT 1];
        if(value.size() > 0){
            List<Report> reportIds = [SELECT Id FROM Report where DeveloperName =:value[0].Report_Developer_Name__c limit 1] ;
            if(reportIds.size()> 0){
                system.debug('reportIds.Id--->' +reportIds[0].Id);
                return reportIds[0].Id;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    @AuraEnabled
    public static boolean checkRunningJobIsSampleFinal(){
        boolean loadStatus=true ;
        try{
           
              Data_Load_Request__c jobName = [Select id,Name,End_Date_Time__c,Status__c,LastModifiedDate,Request_Job_Name__c,Data_Load_Type__c from Data_Load_Request__c order by LastModifiedDate desc Limit 1];
                if(jobName.Data_Load_Type__c == 'Complete Data Load' || jobName.Data_Load_Type__c == 'Sample Data Load'){
                
                       loadStatus = false;
                } 
                
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
        } 
        system.debug('loadStatus-->'+loadStatus);
        return loadStatus;
    }
    
}