global with sharing class Sustain_DeleteTargetRecordsBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
    private List<string> orgAsstId;
    Private Data_Load_Request__c dataLoadReq;
    String errorMessage = null;
    private final String CUSTOM = 'custom';
    private Object_Mappings__c currentObjMap;
    private Boolean isErrorDataOnly = false;
    private static final string orgAssetObjAPI='sustain_app__Asset__c';
    private static final string carbonFootPrintObjAPI='sustain_app__ConsumptionReport__c';

    private static final string CurrentClassName = 'Sustain_DeleteTargetRecordsBatch';

    global Sustain_DeleteTargetRecordsBatch(Data_Load_Request__c dlReq, Object_Mappings__c objMap, Boolean isErrorOnly){
        this.dataLoadReq = dlReq;
        this.currentObjMap = objMap;
        this.isErrorDataOnly = isErrorOnly;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        dataLoadReq.Status__c = 'In Progress';
        update dataLoadReq;
       
        String soqlStr = 'Select Id ';
        if(currentObjMap.Source_Object__c.equals(orgAssetObjAPI) && currentObjMap.Target_Object__c.equals('StnryAssetEnvrSrc') ){
            soqlStr += ',ParentEnvironmentalSourceId ';      
        } else if(currentObjMap.Source_Object__c.equals(orgAssetObjAPI) && (currentObjMap.Target_Object__c.equals('VehicleAssetEmssnSrc') || currentObjMap.Target_Object__c.equals('Scope3EmssnSrc'))){ 
            soqlStr += ',ParentEmissionSourceId ';
        } else if(currentObjMap.Source_Object__c.equals(carbonFootPrintObjAPI) && currentObjMap.Target_Object__c.equals('StnryAssetCrbnFtprnt')){
            soqlStr += ',PrevYrAnnlCarbonFootprintId ';
        }
        
        soqlStr += 'FROM ' + currentObjMap.target_Object__c + ' where Source_Record_ID__c != null';

        if(isErrorDataOnly){
            String sqlSource = 'Select Id from ' + currentObjMap.Source_Object__c + ' where Migration_Status__c =  \'Error Occurred\'';
            Map<Id, Sobject> sourceRecordMap = new Map<Id, Sobject>(database.query(sqlSource));
            Set<Id> sourceRecordIDs = sourceRecordMap.keySet();
            System.debug('sourceRecordIDs '+sourceRecordIDs);
            System.debug('sourceRecordMap '+sourceRecordMap);
            soqlStr += ' and Source_Record_ID__c IN: sourceRecordIDs';
        }
        
        String recordTypeName = currentObjMap.target_Record_Type__c ;
        if(currentObjMap.target_Record_Type__c != null && currentObjMap.target_Record_Type__c != 'Master'){
            soqlStr = soqlStr + ' and recordType.DeveloperName =\'' + recordTypeName + '\'';
        }
        
        System.debug('soqlStr -->'+soqlStr);
        return Database.getQueryLocator(soqlStr);
    }
    
    // Execute method
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        string CurrentMethodName = 'execute';
        system.debug('value of scope'+scope);
        try{ 
            List<Database.DeleteResult> deleteResults;
            
            if(currentObjMap.Target_Object__c.equals('StnryAssetEnvrSrc')  || currentObjMap.Target_Object__c.equals('VehicleAssetEmssnSrc') || 
                currentObjMap.Target_Object__c.equals('Scope3EmssnSrc') || currentObjMap.Target_Object__c.equals('StnryAssetCrbnFtprnt')){                
                String parentFieldName = '';          
                List<Sobject> parentSobjectList = new List<Sobject>();
                List<Sobject> childSobjectList = new List<Sobject>();
                if(currentObjMap.Source_Object__c.equals(orgAssetObjAPI) && currentObjMap.Target_Object__c.equals('StnryAssetEnvrSrc') ){
                    parentFieldName = 'ParentEnvironmentalSourceId';      
                } else if(currentObjMap.Source_Object__c.equals(orgAssetObjAPI) && (currentObjMap.Target_Object__c.equals('VehicleAssetEmssnSrc') || currentObjMap.Target_Object__c.equals('Scope3EmssnSrc'))){ 
                    parentFieldName = 'ParentEmissionSourceId';
                } else if(currentObjMap.Source_Object__c.equals(carbonFootPrintObjAPI) && currentObjMap.Target_Object__c.equals('StnryAssetCrbnFtprnt')){
                    parentFieldName = 'PrevYrAnnlCarbonFootprintId';
                }
                for(Sobject sob: scope){
                    if(parentFieldName != '' && sob.get(parentFieldName) == null){
                        childSobjectList.add(sob);    
                    }else{
                        parentSobjectList.add(sob);
                    }
                }
                if(childSobjectList.size() > 0){
                    deleteResults = Database.delete(childSobjectList, false);
                }

                if(parentSobjectList.size() > 0){
                    List<Database.DeleteResult> tempdeleteResults = Database.delete(parentSobjectList, false);
                    deleteResults.addAll(tempdeleteResults);
                }
            }else{
               deleteResults = Database.delete(scope, false);
            }
            
            for(Integer i=0;i<deleteResults.size();i++){
                if (!deleteResults.get(i).isSuccess()){    
                    Database.Error error = deleteResults.get(i).getErrors().get(0);                  
                    errorMessage = error.getMessage();
                    System.debug('errorMessage '+errorMessage);
                    break;
                }                    
            } 
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
            errorMessage = e.getMessage();
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        } 
    }

    // Finish Method
    global void finish(Database.BatchableContext BC) {
        Boolean isLastObj = true;
        list<Object_Mappings__c> updateList = new List<Object_Mappings__c>();
        String currentObj = currentObjMap.target_object__c;
        String soqlStr = 'SELECT Id,Target_Record_Type__c FROM Object_Mappings__c where Mapping_Included__c = true and Object_Type__c !=:CUSTOM AND Status__c = \'Not Started\' AND target_object__c =:currentObj';
        String recordTypeName = currentObjMap.Target_Record_Type__c;
        if(currentObjMap.target_Record_Type__c != null && currentObjMap.target_Record_Type__c != 'Master'){
            soqlStr = soqlStr + ' and Target_Record_Type__c =\'' + recordTypeName + '\'';
        }
        System.debug('soqlStr '+soqlStr );
        for(Object_Mappings__c each : database.query(soqlStr)) {
            if(String.isBlank(errorMessage)){     
                each.Status__c= 'Delete Completed';
            }else{
                each.Status__c = 'Delete Error';    
            }  
            updateList.add(each);
        }  
        update updateList;
        
        for(Object_Mappings__c objMap :[SELECT Id, Name,Status__c, Target_Object__c,Source_Object__c,Target_Record_Type__c, Source_Record_Type__c FROM Object_Mappings__c where 
            Mapping_Included__c = true AND Object_Type__c !=:CUSTOM AND Status__c = 'Not Started' order by Delete_Sequence_No__c ASC nulls first LIMIT 1]){
            isLastObj = false;
            Sustain_DeleteTargetRecordsBatch batchRecords = new Sustain_DeleteTargetRecordsBatch(dataLoadReq, objMap, isErrorDataOnly);
            ID batchProcessId = database.executeBatch(batchRecords, 1000);
        }
        
        if(isLastObj) {
            List<Object_Mappings__c> objMapList = new List<Object_Mappings__c>();
            String soqlDelete = 'SELECT Id, Name,Status__c FROM Object_Mappings__c';
            if(isErrorDataOnly){
                soqlDelete += ' where Status__c != \'Completed\' LIMIT 1000';
            }else{
                soqlDelete += ' where Status__c != \'Not Started\' LIMIT 1000';
            }
            System.debug('soqlDelete '+soqlDelete);
           
            for(Object_Mappings__c objMap : database.query(soqlDelete)){
                objMap.Status__c= 'Not Started';
                objMapList.add(objMap);
            }
            database.update(objMapList);

            for(Object_Mappings__c objMap :[SELECT Id, Name,Status__c, Target_Object__c,Source_Object__c,Target_Record_Type__c, Source_Record_Type__c FROM Object_Mappings__c where 
                    Mapping_Included__c = true AND Object_Type__c !=:CUSTOM AND Status__c = 'Not Started' /*AND Delete_Sequence_No__c != null*/ 
                    order by Delete_Sequence_No__c ASC LIMIT 1]){
                Sustain_DeleteSampleLoadBatch batchRecords = new Sustain_DeleteSampleLoadBatch(dataLoadReq, objMap, isErrorDataOnly);
                ID batchProcessId = database.executeBatch(batchRecords, 1000);
            }
        }  
    }          
}