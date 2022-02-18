/**
 * @description       : 
 * @author            : Accenture
 * @group             : 
 * @last modified on  : 10-10-2021
 * @last modified by  : Accenture
**/
global class Sustain_CreateSourceIDFieldsBatch implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts {
    
    private static final string CurrentClassName = 'Sustain_CreateSourceIDFieldsBatch';
    public boolean noErrorExist = true;

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
            
        } catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
            noErrorExist = false;
        }        
    }
    
    // Finish Method
    global void finish(Database.BatchableContext BC) {    
        User us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
        List<String> emailAddress = new List<String>();
        emailAddress.add(us.email);    
        Sustain_SendNotification sendData =new Sustain_SendNotification();    
        if(noErrorExist){    
            Migration_Status__c ms = Migration_Status__c.getInstance(UserInfo.getOrganizationId());
            if(ms==null){
                ms = new Migration_Status__c();                              
            }
            ms.Current_Migration_Stage__c   = 'Org Data Scan Output'; 
            ms.Ready_To_Launch__c = false;
            ms.MetaData_Created__c = false;
            ms.Source_Record_ID_Metadata_Created__c = true;
            upsert ms;   
            sendData.sendChatterNotification('MetadataEmails');
            sendData.sendEmailNotification('Sustain_MetadataEmails',emailAddress);
        }else{
            sendData.sendEmailNotification('Sustain_MetadataErrorEmails',emailAddress);
        }
    }
}