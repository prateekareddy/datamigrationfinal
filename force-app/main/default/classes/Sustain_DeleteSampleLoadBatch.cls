global class Sustain_DeleteSampleLoadBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    
    private List<string> orgAsstId;
    Private Data_Load_Request__c dataLoadReq;
    String errorMessage = null;
    private final String CUSTOM = 'custom';
    private Object_Mappings__c currentObjMap;
    private Boolean isErrorDataOnly = false;

    private static final string CurrentClassName = 'Sustain_DeleteSampleLoadBatch';

    public Sustain_DeleteSampleLoadBatch(Data_Load_Request__c dlReq, Object_Mappings__c objMap, Boolean isErrorOnly){
        this.dataLoadReq = dlReq;
        this.currentObjMap = objMap;
        this.isErrorDataOnly = isErrorOnly;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String soqlStr = 'Select Id, Target_SFDC_ID__c,  Migration_Status__c, Error_Details__c  FROM ' + currentObjMap.Source_Object__c;
        
        if(isErrorDataOnly){
            soqlStr = soqlStr + ' where Migration_Status__c =  \'Error Occurred\'';
        }
        
        String recordTypeName = currentObjMap.Source_Record_Type__c;
        if(currentObjMap.Source_Record_Type__c != null && currentObjMap.Source_Record_Type__c != 'Master'){
            if(isErrorDataOnly){
                soqlStr = soqlStr + ' and recordType.DeveloperName =\'' + recordTypeName + '\'';
            }else{
                soqlStr = soqlStr + ' where recordType.DeveloperName =\'' + recordTypeName + '\'';
            }
            
        }
        System.debug('soqlStr '+soqlStr);
        return Database.getQueryLocator(soqlStr);
    }
    
    // Execute method
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        string CurrentMethodName = 'execute';
        system.debug('value of scope'+scope);
        try{
            Set<String> processedID = new Set<String>();
            List<SObject> objListtobeCleared = new List<SObject>();
            String currentObjectName = Label.Sustain_Name_Space_Prefix+currentObjMap.Source_Object__c;
            for(SObject obj: scope){
                System.debug('processedID '+processedID);
                if(!processedID.contains(obj.Id) && (obj.get('Target_SFDC_ID__c') != null || obj.get('Migration_Status__c') != null || 
                    obj.get('Error_Details__c') != null )){
                    
                    sObject clearObj = Schema.getGlobalDescribe().get(currentObjectName).newSObject();
                    clearObj.put('Target_SFDC_ID__c', '');
                    clearObj.put('Migration_Status__c', '');
                    clearObj.put('Error_Details__c', '');
                    clearObj.put('Id', obj.get('Id'));
                    objListtobeCleared.add(clearObj);
                    processedID.add(obj.Id);
                }
                System.debug('objListtobeCleared Inside'+objListtobeCleared);                
            }          

            System.debug('objListtobeCleared '+objListtobeCleared);
            if(objListtobeCleared.size() > 0){
                List<Database.SaveResult> updateResults = Database.update(objListtobeCleared, false);
                for(Integer i=0;i<updateResults.size();i++){
                    if (!updateResults.get(i).isSuccess()){  
                        Database.Error error = updateResults.get(i).getErrors().get(0);                    
                        errorMessage = error.getMessage();
                        System.debug('errorMessage '+errorMessage);
                        break;
                    }                    
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
        if(String.isBlank(errorMessage)){     
            currentObjMap.Status__c= 'Delete Completed';
        }else{
            currentObjMap.Status__c = 'Delete Error';    
        }       

        update currentObjMap;
        
        for(Object_Mappings__c objMap :[SELECT Id, Name,Status__c, Target_Object__c,Source_Object__c, Source_Record_Type__c FROM Object_Mappings__c where Mapping_Included__c = true AND 
                    Object_Type__c !=:CUSTOM AND Status__c = 'Not Started' order by Delete_Sequence_No__c ASC nulls first  LIMIT 1]){
            isLastObj = false;
            Sustain_DeleteSampleLoadBatch batchRecords = new Sustain_DeleteSampleLoadBatch(dataLoadReq, objMap, isErrorDataOnly);
            ID batchProcessId = database.executeBatch(batchRecords, 1000);
        }

        System.debug('Error Message '+errorMessage);
        System.debug('isLastObj '+isLastObj);

        if(isLastObj){
            dataLoadReq.End_Date_Time__c = system.now();
            if(String.isBlank(errorMessage)){     
                dataLoadReq.Status__c = 'Completed';
            }else{
                dataLoadReq.Status__c = 'Failed';    
            }
            Database.update(dataLoadReq);
                
            List<Object_Mappings__c> objMapList = new List<Object_Mappings__c>();
            String soqlDelete = 'SELECT Id, Name,Status__c FROM Object_Mappings__c';
            if(isErrorDataOnly){
                soqlDelete += ' where Status__c != \'Completed\' LIMIT 1000';
            }else{
                soqlDelete += ' where Status__c != \'Not Started\' LIMIT 1000';
            }

            for(Object_Mappings__c objMap : database.query(soqlDelete)){
                objMap.Status__c= 'Not Started';
                objMapList.add(objMap);
            }
            database.update(objMapList); 
            user us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
            List<String> emailAddress = new List<String>();
            emailAddress.add(us.email);
                
            Sustain_SendNotification sendData =new Sustain_SendNotification();
            sendData.sendEmailNotification('Sustain_DeleteMigratedDataEmails',emailAddress);
            if(isErrorDataOnly){
                Sustain_FinalDataController.startFinalDataLoad();
            }
        }          
    }   
}