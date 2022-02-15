public  without sharing class Sustain_MigrateCustomFieldsController {
    private static final string CurrentClassName = 'Sustain_MigrateCustomFieldsController';
    
    public static void processFieldMappings(Map<String,List<Field_Mappings__c>> fldMaps) {

        string CurrentMethodName = 'processFieldMappings';
        Set<String> fieldsName = new Set<String>();
        String objName = '';

        try {
            system.debug('scope-->' + fldMaps.size());
            for(String fm: fldMaps.keySet()){
                for(Field_Mappings__c fmapping : fldMaps.get(fm)){
                    fieldsName.add(fmapping.Source_Field__c.replace('Migration_Util__', ''));
                    objName = fmapping.Object_Mapping__r.Source_Object__c;
                }
                readCustomObjectSync(new list<String>{objName}, objName, fieldsName, fldMaps);              }            
        }catch (Exception ce) {
            System.debug('exception--> ' + ce.getMessage());
			Sustain_UtilityError.createErrorLog(ce, CurrentClassName, CurrentMethodName); 
            Sustain_CreateMetadataBatch.errorMessage = ce.getMessage();
        }
    }

    public static void readCustomObjectSync(List<String> objectNames,String trgtObj, Set<String> fieldNames, Map<String,List<Field_Mappings__c>> refFieldMap) {
        string CurrentMethodName = 'readCustomObjectSync';
        try {
            //Creating a Service for Callout
            system.debug('objectNames-->' + objectNames);
            system.debug('trgtObj-->' + trgtObj);
            system.debug('fieldNames-->' + fieldNames);
            MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
            metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
            metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();       
            
            List <MetadataService.CustomField> fieldList = new List <MetadataService.CustomField>();
            Map<String,List <MetadataService.CustomField>> objFieldsMapping = new Map<String,List<MetadataService.CustomField>>();
            
        
            if(!test.isRunningTest()) {
                                
                MetadataService.IReadResult readResult = metadataservice.readMetadata('CustomObject', objectNames);
                MetadataService.Metadata[] mdInfo = readResult.getRecords();
                for (MetadataService.Metadata md : mdInfo) {
                    if (md != null) {
                        MetadataService.CustomObject obj = (MetadataService.CustomObject) md;
                        if(obj.fields != null) {
                            for(MetadataService.CustomField field : obj.fields) {
                                String fieldName = field.fullName.replace('Migration_Util__', '').replace('Migration_Util__', '');
                                system.debug('fieldName--> ' + fieldName);
                                if(field != null && fieldNames.contains(fieldName)) {
                                    if(field.fullName.contains('Migration_Util__')){
                                        field.fullName = fieldName;
                                    }else {
                                        field.fullName = field.fullName.replace('sustain_app__', '').replace('Sustain_app__', '');    
                                    }
                                    
                                    fieldList.add(field);
                                    System.debug('Field Name: ' + field.fullName);
                                }
                            }                           
                            if(fieldList != null && fieldList.size()>0) {
                                objFieldsMapping.put(trgtObj, fieldList); 
                                createCustomField(objFieldsMapping, objectNames[0], refFieldMap);
                            }
                        }
                    }
                }
            }
        } catch (Exception ce) {
            System.debug('exception--> ' + ce.getMessage());
			Sustain_UtilityError.createErrorLog(ce, CurrentClassName, CurrentMethodName);
            Sustain_CreateMetadataBatch.errorMessage = ce.getMessage();
        }
    }
    
    // Create fields on targets objects
    private static void createCustomField(Map<String,List<MetadataService.CustomField>> objFieldMaps, String sourceObjName,  Map<String,List<Field_Mappings__c>> refFieldMap ){
        string CurrentMethodName = 'createCustomField';
        system.debug('Inside createCustomField');
        try {
            Set<String> fieldNamesTobeCreated = new Set<String>();

            if(!test.isRunningTest()) {
                MetadataService.MetadataPort metadataservices = new MetadataService.MetadataPort();
                metadataservices.SessionHeader = new MetadataService.SessionHeader_element();
                metadataservices.SessionHeader.sessionId = UserInfo.getSessionId();

                List<MetadataService.CustomField> fields = new List<MetadataService.CustomField>();
                system.debug('objFieldMaps-->' + objFieldMaps);
                if(refFieldMap == null || refFieldMap.size() == 0){
                    for(String objName: objFieldMaps.keySet()){
                        for(MetadataService.CustomField custField : objFieldMaps.get(objName)){
                            MetadataService.CustomField customField = new MetadataService.CustomField();
                            customField=custField;
                            String fieldName=custField.fullname;
                            if(fieldName.contains('.')){
                                fieldName=fieldName.split('.')[1];
                            }            
                            if(fieldName.contains('sustain_app__')){
                                fieldName=fieldName.remove('sustain_app__');
                            }
                            customField.fullName = objName.replace('sustain_app__', '').replace('Sustain_app__', '')+'.'+fieldName.replace('Migration_Util__',''); 
                            fieldNamesTobeCreated.add(objName.replace('sustain_app__', '').replace('Sustain_app__', '').replace('Migration_Util__','')+'.'+fieldName.replace('Migration_Util__',''));                    
                            fields.add(customField);
                        }
                    }
                }else if(refFieldMap != null && refFieldMap.size() > 0){
                    System.debug('refFieldMap '+refFieldMap);
                    for(String objName: objFieldMaps.keySet()){
                        for(MetadataService.CustomField custField : objFieldMaps.get(objName)){                            
                            String fieldName=custField.fullname;
                            String key = objName+'.'+fieldName;
                            System.debug('Key '+Key);
                            if(fieldName.contains('.')){
                                fieldName=fieldName.split('.')[1];                                
                            } 
                            if(refFieldMap.get(key) != null){
                                for(Field_Mappings__c fld: refFieldMap.get(key)){
                                    MetadataService.CustomField customField = new MetadataService.CustomField();
                                    customField=custField;
                                    customField.label = fld.Target_Field_Label__c;
                                    customField.type_x = 'Lookup';
                                    customField.fullName = objName+'.'+fld.Target_Field__c;
                                    customField.relationshipLabel = fld.Target_Field__c.replace('__c','');
                                    customField.relationshipName = fld.Target_Field__c.replace('__c','');
                                    customField.referenceTo = fld.Reference_To__c;  
                                    fieldNamesTobeCreated.add(objName.replace('Migration_Util__','')+'.'+fld.Target_Field__c.replace('Migration_Util__',''));
                                    System.debug(customField.label + customField.fullName + customField.relationshipLabel + customField.referenceTo);
                                    fields.add(customField);
                                }
                            }                            
                        }
                    }
                }
                System.debug('Metadata Created '+fields + fields.Size());
                List<MetadataService.SaveResult> results = metadataservices.createMetadata(fields);
                //metadataservice.createMetadata(fields);
                system.debug('Field Create Successfull' +  fieldNamesTobeCreated);
                //Updating FLS for Admin only
                
                List<MetadataService.Profile> mprofile = new List<MetadataService.Profile>();
                for(String fldName: fieldNamesTobeCreated){
                    MetadataService.Profile admin = new MetadataService.Profile();
                    admin.fullName = 'Admin';
                    admin.custom = false;
                    MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
                    fieldSec.field=fldName;
                    fieldSec.editable=true;
                    admin.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSec} ;    
                    mprofile.add(admin);               
                }
                List<MetadataService.SaveResult> resultsFLS = metadataservices.updateMetadata(mprofile);
                handleSaveResults(results[0], fieldNamesTobeCreated);
            }
        } catch(exception e) {
            system.debug('Create Field Exception-->' + e);
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
            Sustain_CreateMetadataBatch.errorMessage = e.getMessage();
        }        
    }
  @testVisible
    private static void handleSaveResults(MetadataService.SaveResult saveResult, Set<String> newFieldsCreated){
        string CurrentMethodName = 'handleSaveResults';
        try{
            // Construct error message and throw an exception
            if(saveResult.errors!=null){            
                for(MetadataService.Error error : saveResult.errors){
                    System.debug('saveResult.fullName '+saveResult.fullName);
                    newFieldsCreated.remove(saveResult.fullName);    
                }
            }
            System.debug('newFieldsCreated '+newFieldsCreated + 'size '+newFieldsCreated.size());
            
            Map<String, List<Field_Mappings__c>> fldMap = new Map<String, List<Field_Mappings__c>>();
            List<Field_Mappings__c> flListtoupdate = new List<Field_Mappings__c>();
            Set<String> staticFld = Sustain_UtilConstants.STATICFIELDNAMES;

            for(Field_Mappings__c fl: [SELECT id,Name, Calculated__c, Source_Field__c,Target_Field_Label__c, Custom_Field__c, Mapping_Included__c, 
                            Object_Mapping__c,Object_Mapping__r.Source_Object__c,Object_Mapping__r.Target_Object__c,Object_Mapping__r.Object_Type__c,
                            Target_Field__c, Field_Created__c FROM Field_Mappings__c 
                            where ((New_Field__c = true AND Object_Mapping__r.Mapping_Included__c = true AND Mapping_Included__c = true AND Calculated__c = false) OR
                            Source_Field__c IN:staticFld)
                            AND Field_Created__c = false order By Object_Mapping__r.Source_Object__c ASC]){
                List<Field_Mappings__c> fieldMapList = new List<Field_Mappings__c>();   
                String key ='';
                if((Sustain_UtilConstants.STATICFIELDNAMES.contains(fl.Target_Field__c) ||
                    fl.Object_Mapping__r.Object_Type__c == 'custom' ) && !fl.Target_Field__c.contains('Source_Record_ID__c') )  {        
                    key = fl.Object_Mapping__r.source_Object__c.replace('Migration_Util__','')+ '.' + fl.Target_Field__c.replace('Migration_Util__','');
                } else {
                    key = fl.Object_Mapping__r.Target_Object__c.replace('Migration_Util__','')+ '.' + fl.Target_Field__c.replace('Migration_Util__','');
                }
                System.debug('inside key '+Key);
                if(fldMap != null && 
                fldMap.containsKey(key)){
                    System.debug('fldMap.get(fl.Source_Field__c+fl.Object_Mapping__c) '+fldMap.get(key));
                    fieldMapList = fldMap.get(key);
                }
                fieldMapList.add(fl);
                fldMap.put(key, fieldMapList);            
            }
            System.debug('fldMap ' + fldMap);       
            
            for(String flkey: fldMap.keySet()){
                for(Field_Mappings__c fl: fldMap.get(flkey) ){
                    if(newFieldsCreated.contains(flkey)){
                        Field_Mappings__c flm = fl;
                        flm.Field_Created__c = true;
                        flListtoupdate.add(flm);
                    }
                }
            }
            
            if(flListtoupdate.size() > 0){
                Database.update(flListtoupdate, false);
            }
        }catch (Exception ce) {
			Sustain_UtilityError.createErrorLog(ce, CurrentClassName, CurrentMethodName); 
            Sustain_CreateMetadataBatch.errorMessage = ce.getMessage();
        }
    }

    public static void createField( Set<String> objectNames, String fieldName, Integer fieldLength, String fieldType, String fieldLabel, String sessionIDS){
 
        MetadataService.MetadataPort metadataservices = new MetadataService.MetadataPort();
        metadataservices.SessionHeader = new MetadataService.SessionHeader_element();
        metadataservices.SessionHeader.sessionId = sessionIDS != null ? sessionIDS : UserInfo.getSessionId();

        Set<String> fieldNames = new Set<String>();
        List<MetadataService.CustomField> metadatatobeCreate = new List<MetadataService.CustomField>();

        for(String obj: objectNames){
            MetadataService.CustomField customField = new MetadataService.CustomField();
            customField.fullName = obj + '.' + fieldName;
            customField.label = FieldLabel;
            customField.type_x = fieldType;
            customField.length = fieldLength;
            metadatatobeCreate.add(customField);
            fieldNames.add(obj + '.' + fieldName);
        }

        List<MetadataService.SaveResult> fieldresults = metadataservices.createMetadata(metadatatobeCreate);

        if(fieldresults.size() > 0 && fieldresults[0].errors!=null){            
            for(MetadataService.Error error : fieldresults[0].errors){
                System.debug('saveResult.fullName '+fieldresults[0].fullName);
                fieldNames.remove(fieldresults[0].fullName);    
            }
        }
        System.debug('fieldNames '+fieldNames + 'fieldNames.size '+fieldNames.size());
        List<MetadataService.Profile> mprofile = new List<MetadataService.Profile>();
        
        List<MetadataService.ProfileFieldLevelSecurity> pflsList = new List<MetadataService.ProfileFieldLevelSecurity>();

        MetadataService.Profile admin = new MetadataService.Profile();
        admin.fullName = 'Admin';
        admin.custom = false;

        for(String fldName: fieldNames){           
            MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
            fieldSec.field=fldName;
            fieldSec.editable=true;
            pflsList.add(fieldSec);
        }
        admin.fieldPermissions  = pflsList;           
        mprofile.add(admin);      
        List<MetadataService.SaveResult> resultsFLS = metadataservices.updateMetadata(mprofile);
    }
}