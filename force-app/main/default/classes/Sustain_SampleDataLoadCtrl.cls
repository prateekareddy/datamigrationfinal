/**
 * @description       : 
 * @author            : Accenture
 * @group             : 
 * @last modified on  : 09-23-2021
 * @last modified by  : Accenture
**/
public without sharing class Sustain_SampleDataLoadCtrl {
    private static final string CurrentClassName = 'Sustain_SampleDataLoadCtrl';
    
    public without sharing class FromJSON {
        public String Name;
    }
    
    @AuraEnabled
    public static List < String > fetchLookUpValues(String searchKeyWord,List<String> allAssetRecords) {
        List <String> returnList = new List < String > ();
        if(searchKeyWord.length()==1){
            return returnList;
        }else{
            try{
                for(String assetName: allAssetRecords){
                    if(assetName.containsIgnoreCase(searchKeyWord)){
                        returnList.add(assetName) ;
                    }
                }
                return returnList;
            }catch(exception ex){
                ex.getMessage();
                return null;
            }
        }
    }
    
    @AuraEnabled
    public static void createDataLoadReq(List<String> orgAssetData){
        string CurrentMethodName = 'createDataLoadReq';
        map<String, list<Object_Mappings__c>>objMap = new  map<String, list<Object_Mappings__c>>();
        Map<String,List<Field_Mappings__c>> fldMap = new Map<String,List<Field_Mappings__c>> ();
        Data_Load_Request__c dataRec = new Data_Load_Request__c();
        try{
            List<String> orgAssetIds = new List<String>();
            
            List<sustain_app__Asset__c> assets = database.query('Select id,Name from sustain_app__Asset__c Where Name IN :orgAssetData Limit 1000');
            for(sustain_app__Asset__c orgData : assets){
                orgAssetIds.add(orgData.Id);
            }
            
            dataRec.Request_Job_Name__c = 'Sample Data Load';
            dataRec.Start_Date_Time__c = system.now();
            dataRec.Data_Load_Type__c = 'Sample Data Load';
            dataRec.Status__c = 'In Progress';
            Database.insert(dataRec);
            if(String.isNotBlank(dataRec.Id) && String.isNotEmpty(dataRec.Id)){
                List<Sustain_SampleLoadObjects__mdt> datalist = [select Source_Object__c, Sequence_Number__c from Sustain_SampleLoadObjects__mdt where Sequence_Number__c=1 order by Sequence_Number__c];
                    double sequence = double.valueOf(datalist[0].Sequence_Number__c);
                    String objName = datalist[0].Source_Object__c;
                    string sqlStr = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c,Batch_Size__c from Object_Mappings__c where Source_Object__c=:objName and Status__c = \'Not Started\' AND Object_Type__c != \'custom\' and mapping_included__c=true  order by sequence_number__c,Target_Object__c nulls last';
                    system.debug('createDataLoadReq sql -->' + sqlStr);
                    list<Object_Mappings__c> objMappingList = Database.query(sqlStr);
                    list<id> recordIds =  new list<id>();
                    Integer batchSize = 200;
                    for(Object_Mappings__c obj : objMappingList) {
                        recordIds.add(obj.id);
                        string key = obj.Source_Object__c + '-' +obj.Source_Record_Type__c.replaceAll('sustain_app__','').replaceAll('Sustain_app__','');
                        if(objMap.keyset().contains(key)) {
                            objMap.get(key).add(obj);                           
                        } else {
                            list<Object_Mappings__c> tempList = new list<Object_Mappings__c>();
                            tempList.add(obj);
                            objMap.put(key,tempList);
                            batchSize = obj.Batch_Size__c != null ? obj.Batch_Size__c.intValue() : 200 ;
                        }
                    }
                    String querySql = 'SELECT id, Object_Mapping__c,Reference_To__c,Source_Field__c,Target_Field__c,Object_Mapping__r.Source_Object__c,Object_Mapping__r.Source_Record_Type__c,Source_Field_Type__c,Object_Mapping__r.Target_Object__c,Object_Mapping__r.Target_Record_Type__c,New_Field__c FROM Field_Mappings__c where Object_Mapping__c in :recordIds  and mapping_included__c=true and calculated__c=false order by Object_Mapping__c asc';  
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
                    Sustain_FinalDataLoadBatch nextBatch = new Sustain_FinalDataLoadBatch(objMap, fldMap, Integer.valueof(datalist[0].Sequence_Number__c), orgAssetIds, dataRec.id);
                    database.executeBatch(nextBatch, (batchSize != null && batchSize !=0) ? batchSize : 200);
            } 
            
        }catch(Exception e){
             dataRec.Status__c = 'Failed';
             update dataRec;
            System.debug('An exception occurred: ' + e.getMessage());
            user us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
            List<String> emailAddress = new List<String>();
            emailAddress.add(us.email);            
            Sustain_SendNotification sendData =new Sustain_SendNotification();
            sendData.sendEmailNotification('Sustain_Error_FinalDataLoadEmails',emailAddress);    
        }  
    }
    
    @AuraEnabled
    public static List<String> getOrgAssetData(){
        string CurrentMethodName = 'getOrgAssetData';
        List<String> allOrgAssetData = new List<String>();
        try{
            for(sustain_app__Asset__c data : [Select id,Name from sustain_app__Asset__c where Migration_Status__c != 'Completed' AND sustain_app__ParentAsset__c = null Limit 1000]){
                allOrgAssetData.add(data.Name);
            }
            allOrgAssetData.sort();            
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
        } 
        return allOrgAssetData;
    }
    
    @AuraEnabled
    public static Data_Load_Request__c getlatestDataLoad(){
      
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
    public static void deleteDataLoadReq(){
        string CurrentMethodName = 'deleteDataLoadReq';
        try{
            Data_Load_Request__c dataRec = new Data_Load_Request__c();
            dataRec.Request_Job_Name__c = 'Delete Data Load';
            dataRec.Start_Date_Time__c = system.now();
            dataRec.Data_Load_Type__c = 'Delete Data Load';
            datarec.Status__c= 'Not Started';
            Database.insert(dataRec);
            if(String.isNotBlank(dataRec.Id) && String.isNotEmpty(dataRec.Id)){
                List<Object_Mappings__c> objMapList = new List<Object_Mappings__c>();
                for(Object_Mappings__c objMap :[SELECT Id, Name,Status__c FROM Object_Mappings__c where Status__c != 'Not Started'LIMIT 1000]){
                    objMap.Status__c= 'Not Started';
                    objMapList.add(objMap);
                }
                database.update(objMapList);

                List<Object_Mappings__c> objMap = [SELECT Id, Name,Status__c, Target_Object__c,Target_Record_Type__c,Source_Object__c, Source_Record_Type__c FROM Object_Mappings__c where 
                         Mapping_Included__c = true AND Object_Type__c !=:'custom' AND Status__c = 'Not Started' order by Delete_Sequence_No__c ASC nulls first LIMIT 1];                    
                
                if(objMap.size() > 0){
                    Sustain_DeleteTargetRecordsBatch batchRecords = new Sustain_DeleteTargetRecordsBatch(dataRec, objMap[0], false);
                    ID batchProcessId = database.executeBatch(batchRecords, 1000);
                }
                               
            }
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
        }       
    }

    @AuraEnabled
    public static void deleteErrorDataLoadReq(Boolean isErrorDataOnly){
        string CurrentMethodName = 'deleteErrorDataLoadReq';
        try{
            Data_Load_Request__c dataRec = new Data_Load_Request__c();
            dataRec.Request_Job_Name__c = 'Delete Error Only Data Load';
            dataRec.Start_Date_Time__c = system.now();
            dataRec.Data_Load_Type__c = 'Delete Data Load';
            datarec.Status__c= 'Not Started';
            Database.insert(dataRec);
            if(String.isNotBlank(dataRec.Id) && String.isNotEmpty(dataRec.Id)){
                List<Object_Mappings__c> objMapList = new List<Object_Mappings__c>();
                for(Object_Mappings__c objMap :[SELECT Id, Name,Status__c FROM Object_Mappings__c where Status__c != 'Completed' LIMIT 1000]){
                    objMap.Status__c= 'Not Started';
                    objMapList.add(objMap);
                }
                database.update(objMapList);

                List<Object_Mappings__c> objMap = [SELECT Id, Name,Status__c, Target_Object__c,Target_Record_Type__c,Source_Object__c, Source_Record_Type__c FROM Object_Mappings__c where 
                         Mapping_Included__c = true AND Object_Type__c !=:'custom' AND Status__c = 'Not Started' order by Delete_Sequence_No__c ASC nulls first LIMIT 1];                    
                
                if(objMap.size() > 0){
                    Sustain_DeleteTargetRecordsBatch batchRecords = new Sustain_DeleteTargetRecordsBatch(dataRec, objMap[0], isErrorDataOnly);
                    ID batchProcessId = database.executeBatch(batchRecords, 1000);
                }              
            }
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
        }        
    }

    @AuraEnabled
    public static boolean checkRunningJobIsSampleFinal(){
        boolean loadStatus=true ;
        try{
           
              Data_Load_Request__c dataRecStatus = [Select id,Name,End_Date_Time__c,Status__c,LastModifiedDate,Request_Job_Name__c,Data_Load_Type__c from Data_Load_Request__c order by LastModifiedDate desc Limit 1];
                if(dataRecStatus.Data_Load_Type__c == 'Complete Data Load' || dataRecStatus.Data_Load_Type__c == 'Sample Data Load'){
                       loadStatus = false;
                } 
                
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
        } 
        system.debug('loadStatus-->'+loadStatus);
        return loadStatus;
    }
    
}