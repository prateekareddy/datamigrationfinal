/***************************************************************************************************************
* Name - Sustain_UpdateCustomObjectRefBatch 
* Description - This class is used as Batch clas Processing the custom ref field on custom objects where managed package object reffered.
* Author - Accenture (Bindhyachal)
* Created Date - 9/10/2021
* Last Modified By & Date - Accenture, 9/10/2021
* ***************************************************************************************************************/

global class Sustain_UpdateCustomObjectRefBatch implements Database.Batchable<sObject>,  Database.Stateful, Database.AllowsCallouts {    
    Object_Mappings__c objMapping;
    String errorMessage='';
    List<Field_Mappings__c> fieldMaps;
    String dataLoadType = '';
    private static final string CurrentClassName = 'Sustain_UpdateCustomObjectRefBatch';

    public Sustain_UpdateCustomObjectRefBatch( Object_Mappings__c objMap, String dlType){       
        this.objMapping = objMap;
        this.dataLoadType = dlType;
    }
    
    // Start Method    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        fieldMaps = [Select Id,  Mapping_Included__c, Name, Object_Mapping__c,
                     Object_Mapping__r.Source_Object__c, Reference_To__c, Source_Field__c, Source_Field_Label__c, Source_Field_Type__c, Target_Field__c,
                     Target_Field_Label__c, Target_Field_Type__c  from Field_Mappings__c where Object_Mapping__c =:objMapping.Id AND Mapping_Included__c = true];
        String query = Sustain_UpdateCustomObjectRelationship.getSOQLString(fieldMaps);        
        return Database.getQueryLocator(query);
        
    }
    
    // Execute method
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        string CurrentMethodName = 'execute';
        try {
            
            List<Sobject> recordsToBeUpdate = Sustain_UpdateCustomObjectRelationship.updateCustomObjectRecords(scope, fieldMaps);
            Database.update(recordsToBeUpdate, false);
        } catch(exception e) {
            errorMessage = e.getMessage();
            system.debug('Sustain_CreateMetadataBatch:error-->' + e);
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
            user us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
            List<String> emailAddress = new List<String>();
            emailAddress.add(us.email);            
            Sustain_SendNotification sendData =new Sustain_SendNotification();
            sendData.sendEmailNotification('Sustain_Error_FinalDataLoadEmails',emailAddress);     
        }
    }
    
    // Finish Method
    global void finish(Database.BatchableContext BC) {
        string CurrentMethodName = 'finish';
        try{           
            if(String.isBlank(errorMessage)){                   
                objMapping.Status__c = 'Completed';
            }else{                    
                objMapping.Status__c = 'Error';   
            }
                  
            update objMapping;
            List<Object_Mappings__c> customObjectList = Sustain_UpdateCustomObjectRelationship.getCustomObjectMappingtoUpdate();
            if(customObjectList.size() >0){
                Sustain_UpdateCustomObjectRefBatch nextcustBatch = new Sustain_UpdateCustomObjectRefBatch(customObjectList[0], dataLoadType);
                database.executeBatch(nextcustBatch,(customObjectList[0].Batch_Size__c != null && customObjectList[0].Batch_Size__c.intValue() !=0) ? customObjectList[0].Batch_Size__c.intValue() : 200 );     
            }else{
                Data_Load_Request__c dataLoadReq = [Select id, Name, End_Date_Time__c,Status__c from Data_Load_Request__c order by CreatedDate DESC limit 1];
                System.debug('Error Message '+errorMessage);
                system.debug('end of batch');
                integer  totalRcrdCount = database.countQuery('SELECT count() FROM Object_Mappings__c where mapping_included__c=true');
                integer  processedRcrdCount = database.countQuery('SELECT count() FROM Object_Mappings__c where mapping_included__c=true and status__c =\'Completed\'');
                String emailTemplate = '';
                if(totalRcrdCount == processedRcrdCount) {
                    dataLoadReq.Status__c = 'Completed';
                    emailTemplate = 'Sustain_FinalDataLoadEmails';
                } else if(processedRcrdCount == 0) {
                    dataLoadReq.Status__c = 'Failed';
                    emailTemplate = 'Sustain_Error_FinalDataLoadEmails';
                } else {
                    dataLoadReq.Status__c = 'Partial Complete';
                    emailTemplate = 'Sustain_SampleDataLoadEmails';
                }
                dataLoadReq.End_Date_Time__c = System.now();
                try {
                    update dataLoadReq;
                } catch(exception e) {
                     system.debug('dataReq update error-->' + e);
                     Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
                }
                
                user us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
                List<String> emailAddress = new List<String>();
                emailAddress.add(us.email);
                
                Sustain_SendNotification sendData =new Sustain_SendNotification();
                sendData.sendChatterNotification('MetadataEmails');
                if('FinalDataLoad'.equalsIgnoreCase(dataLoadType)){
                    sendData.sendEmailNotification(emailTemplate, emailAddress);
                    sendData.sendChatterNotification('FinalDataLoadEmails');
                }
            }
        }catch(Exception ex){
            Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName);     
            user us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
            List<String> emailAddress = new List<String>();
            emailAddress.add(us.email);            
            Sustain_SendNotification sendData =new Sustain_SendNotification();
            sendData.sendEmailNotification('Sustain_Error_FinalDataLoadEmails',emailAddress);            
        } 
    }
}