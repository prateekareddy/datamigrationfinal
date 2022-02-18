/***************************************************************************************************************
* Name - Sustain_CreateMetadataBatch 
* Description - This class is used as Batch clas Processing the field mappings Records and create new fields.
* Author - Accenture (Bindhyachal)
* Created Date - 8/26/2021
* Last Modified By & Date - Accenture, 8/26/2021
* ***************************************************************************************************************/

global class Sustain_CreateMetadataBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    
    // Start Method
    private static final string CurrentClassName = 'Sustain_CreateMetadataBatch';
    public static String errorMessage='';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Set<String> staticFlds = Sustain_UtilConstants.STATICFIELDNAMES;
        String query = 'SELECT id,Name, Calculated__c, Comments__c, Source_Field__c,Target_Field_Label__c, Custom_Field__c, Mapping_Included__c, Object_Mapping__c, Object_Mapping__r.Source_Object__c, Object_Mapping__r.Object_Type__c, '+
            'Object_Mapping__r.Target_Object__c,Source_Field_Type__c, Target_Field__c, Reference_To__c, Target_Field_Type__c, To_Review__c FROM Field_Mappings__c '+
            'where ((New_Field__c = true AND Object_Mapping__r.Mapping_Included__c = true AND Mapping_Included__c = true AND Calculated__c = false) OR Source_Field__c IN:staticFlds ) AND Field_Created__c = false order By Object_Mapping__r.Source_Object__c ASC';
        System.debug('query--------------> ' + query);
        return Database.getQueryLocator(query);        
    }

    // Execute method
    global void execute(Database.BatchableContext BC, List<Field_Mappings__c> scope) {
        System.debug('Inside execute--------------> ');
        string CurrentMethodName = 'execute';
        Set<String> fieldsName = new Set<String>();
        Set<String> objectsName = new Set<String>();
        Set<String> trgtObject = new Set<String>();
        List<Object_Mappings__c> staticFieldMappingsObj = new List<Object_Mappings__c>();
        List<Field_Mappings__c> fieldMappingsObj = new List<Field_Mappings__c>();
        Set<String> staticFieldObj = new Set<String>();
        Map<String, List<Field_Mappings__c>> refFieldOnSourceMap = new Map<String, List<Field_Mappings__c>>();       
        
        try {
            Set<String> createdFields = new Set<String>();
            String sql = 'SELECT id,Name,Object_Mapping__r.Target_Object__c,Target_Field__c, Field_Created__c FROM Field_Mappings__c '
             +' where Field_Created__c = true and id in:scope order By Object_Mapping__r.Source_Object__c ASC';
            for(Field_Mappings__c fl: database.query(sql)){
                createdFields.add(fl.Object_Mapping__r.Target_Object__c+ '.' + fl.Target_Field__c);
            } 
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            List<String> apiNames = new List<String>();
            String uniqueKey = '';
            if(Sustain_UtilConstants.STATICFIELDNAMES.contains(scope[0].Source_Field__c) && scope[0].Source_Field__c != 'Source_Record_ID__c'){
                apiNames.add(scope[0].Object_Mapping__r.source_Object__c);
                uniqueKey = scope[0].Object_Mapping__r.source_Object__c.replace(Label.Sustain_Name_Space_Prefix, '') + '.' + scope[0].Target_Field__c.replace(Label.Sustain_Name_Space_Prefix, '');
            } else {
                apiNames.add(scope[0].Object_Mapping__r.Target_Object__c);
                uniqueKey = scope[0].Object_Mapping__r.Target_Object__c.replace(Label.Sustain_Name_Space_Prefix, '') + '.' + scope[0].Target_Field__c.replace(Label.Sustain_Name_Space_Prefix, '');
            }
            Schema.DescribeSObjectResult[] results = Schema.describeSObjects(apiNames);
            for(Schema.DescribeSobjectResult describeResult : results){
                System.debug('describeResult '+describeResult.getLabel());
                for(Schema.SobjectField field: describeResult.fields.getMap().values()){
                    if(describeResult.getName().replace(Label.Sustain_Name_Space_Prefix, '')+'.'+field.getDescribe().getName().replace(Label.Sustain_Name_Space_Prefix, '') == uniqueKey){
                        createdFields.add(describeResult.getName().replace(Label.Sustain_Name_Space_Prefix, '')+'.'+field.getDescribe().getName().replace(Label.Sustain_Name_Space_Prefix, ''));
                        break;
                    }
                    system.debug('fields--->' + describeResult.getName()+'.'+field.getDescribe().getName());
                }
            }

            system.debug('scope-->' + scope.size());

            for(Field_Mappings__c fmapping : scope){                
                if(!createdFields.contains(fmapping.Object_Mapping__r.Target_Object__c+ '.' + fmapping.Target_Field__c) 
                 && !createdFields.contains(fmapping.Object_Mapping__r.source_Object__c+ '.' + fmapping.Target_Field__c)){
                    if(!Sustain_UtilConstants.STATICFIELDNAMES.contains(fmapping.Source_Field__c) && fmapping.Object_Mapping__r.Object_Type__c != 'custom'){
                       fieldsName.add(fmapping.Source_Field__c.replace(Label.Sustain_Name_Space_Prefix, ''));                
                        system.debug('fmapping.Source_Field__c-->' + fmapping.Source_Field__c);  
                        objectsName.add(fmapping.Object_Mapping__r.Source_Object__c); 
                        trgtObject.add(fmapping.Object_Mapping__r.Target_Object__c); 
                        system.debug('objectsName-->' + objectsName);
                        system.debug('trgtObject-->' + trgtObject);
                        Sustain_MigrateCustomFieldsController.readCustomObjectSync(new list<String>(objectsName	), (new list<string>(trgtObject))[0], fieldsName, null);  
                    } else if(fmapping.Object_Mapping__r.Object_Type__c == 'custom' ){
                        List<Field_Mappings__c> fieldMapList = new List<Field_Mappings__c>();
                        System.debug('refFieldOnSourceMap '+refFieldOnSourceMap);
                        String key = fmapping.Object_Mapping__r.Source_Object__c+'.'+fmapping.Source_Field__c;
                        System.debug('inside key '+Key);
                        if(refFieldOnSourceMap != null && 
                            refFieldOnSourceMap.containsKey(key)){
                            System.debug('refFieldOnSourceMap.get(fmapping.Source_Field__c+fmapping.Object_Mapping__c) '+refFieldOnSourceMap.get(key));
                            fieldMapList = refFieldOnSourceMap.get(key);
                        }
                        System.debug('fieldMapList '+fieldMapList);
                        fieldMapList.add(fmapping);
                        refFieldOnSourceMap.put(key, fieldMapList);
                    } else{
                        System.debug('staticFieldObj '+staticFieldObj);
                        if(!staticFieldObj.contains(fmapping.Object_Mapping__c)){
                            staticFieldMappingsObj.add(fmapping.Object_Mapping__r);
                            fieldsName.add(fmapping.Source_Field__c); 
                            staticFieldObj.add(fmapping.Object_Mapping__c);
                        }
                    }
                }  else {
                    fmapping.Field_Created__c = true;
                    fieldMappingsObj.add(fmapping);
                }             
            }
            system.debug('scope.size()-->' + scope.size());
            if(refFieldOnSourceMap.size() > 0){                
                Sustain_MigrateCustomFieldsController.processFieldMappings(refFieldOnSourceMap);
            }
            if(staticFieldMappingsObj.size() > 0){
                for(Object_Mappings__c objMap : staticFieldMappingsObj){
                    if(fieldsName.contains('Source_Record_ID__c')){
                        Sustain_MigrateCustomFieldsController.readCustomObjectSync(new list<String> {'StnryAssetEnvrSrc'}, objMap.Target_Object__c, fieldsName, null);    
                    }else{
                        Sustain_MigrateCustomFieldsController.readCustomObjectSync(new list<String> {'Sustain_app__Asset__c'}, objMap.Source_Object__c, fieldsName, null);  
                    }
                }
            }  
            Database.update(fieldMappingsObj, false);    
        } catch(exception e) {
            errorMessage = e.getMessage();
            system.debug('Sustain_CreateMetadataBatch:error-->' + e);
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);   
        }
    }
    
    // Finish Method
    global void finish(Database.BatchableContext BC) {
        string CurrentMethodName = 'finish';
        try{ 
            System.debug('errorMessage --->'+errorMessage);    
            user us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
            List<String> emailAddress = new List<String>();
            emailAddress.add(us.email);
            Sustain_SendNotification sendData =new Sustain_SendNotification();
            if(String.isBlank(errorMessage)){               
                Migration_Status__c ms = Migration_Status__c.getOrgDefaults();                
                ms.Metadata_Created__c = true;
                ms.Running_Metadata_Job__c = false;
                update ms;  
                sendData.sendChatterNotification('MetadataEmails');
                sendData.sendEmailNotification('Sustain_MetadataEmails',emailAddress);  
            }else{                   
                sendData.sendEmailNotification('Sustain_MetadataErrorEmails',emailAddress);  
            }
        }catch(Exception ex){
            Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName);            
        } 
    }
}