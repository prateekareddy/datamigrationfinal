/**
 * @description       : 
 * @author            : Accenture
 * @group             : 
 * @last modified on  : 10-10-2021
 * @last modified by  : Accenture
**/
global class Sustain_CreateSourceIDFieldsBatch implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts {
    
    private static final string CurrentClassName = 'Sustain_CreateSourceIDFieldsBatch';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT id,Name,Target_Object__c FROM Object_Mappings__c where Object_Type__c != \'custom\'' ;
        return Database.getQueryLocator(query);
    }
    
    // Execute method
    global void execute(Database.BatchableContext BC, List<Object_Mappings__c > scope) {
        string CurrentMethodName = 'execute';
        try{
            Set<String> objNames = new Set<String>();
            Set<String> processedObjNames = new Set<String>();
            Integer count = 0;
            
            for(Object_Mappings__c obj: scope){
                
                if(!processedObjNames.contains(obj.Target_Object__c)){
                    objNames.add(obj.Target_Object__c);
                }
                
                processedObjNames.add(obj.Target_Object__c);
                count++;
                 
                if(objNames.size() == 10 || count == scope.size()){
                    Sustain_MigrateCustomFieldsController.createField( objNames, 'Source_Record_ID__c', 255, 'Text', 'Source Record ID', userInfo.getSessionID());
                    objNames = new Set<String>();
                }
            }
            /*Sustain_MigrateCustomFieldsController.createField( Sustain_UtilConstants.SCFirstCoreObjectNames, 'Source_Record_ID9__c', 255, 'Text', 'Source Record ID', userInfo.getSessionID());
            Sustain_MigrateCustomFieldsController.createField( Sustain_UtilConstants.SCSecondCoreObjectNames, 'Source_Record_ID9__c', 255, 'Text', 'Source Record ID', userInfo.getSessionID());
            Sustain_MigrateCustomFieldsController.createField( Sustain_UtilConstants.SCThirdCoreObjectNames, 'Source_Record_ID9__c', 255, 'Text', 'Source Record ID', userInfo.getSessionID());
            Sustain_MigrateCustomFieldsController.createField( Sustain_UtilConstants.SCFourCoreObjectNames, 'Source_Record_ID9__c', 255, 'Text', 'Source Record ID', userInfo.getSessionID());
            */
            
        } catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
        }        
    }
    
    // Finish Method
    global void finish(Database.BatchableContext BC) {        
        User us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
        List<String> emailAddress = new List<String>();
        emailAddress.add(us.email);    
        Sustain_SendNotification sendData =new Sustain_SendNotification();        
        sendData.sendChatterNotification('MetadataEmails');
        sendData.sendEmailNotification('Sustain_MetadataEmails',emailAddress);
    }
}