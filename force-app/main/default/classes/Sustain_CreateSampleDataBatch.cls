/**
 * @description       : 
 * @author            : Accenture
 * @group             : 
 * @last modified on  : 09-23-2021
 * @last modified by  : Accenture
**/
global class Sustain_CreateSampleDataBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    public Sustain_CreateSampleDataBatch(){}
    private List<string> orgAsstId;
    Private String dataLoadId;
    String errorMessage='';
    Boolean batchStatus = false ;
    private static final string BuildingRecordtypeAPI='sustain_app__Building';
    private static final string VehicleRecordtypeAPI='sustain_app__Vehicle';
    private static final string GeneralRecordType='sustain_app__General';
    private static final string DateLabel='Date';
    private static final string CheckboxLabel='Checkbox';
    private static final string CurrentClassName = 'Sustain_CreateSampleDataBatch';
    
    public Sustain_CreateSampleDataBatch(List<String> orgAsstId,String dataLoadId){
        this.orgAsstId = orgAsstId;
        this.dataLoadId = dataLoadId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT id,Name,RecordType.Name,Target_SFDC_ID__c FROM sustain_app__Asset__c Where Id IN : orgAsstId' ;
        return Database.getQueryLocator(query);
    }
    
    // Execute method
    global void execute(Database.BatchableContext BC, List<sustain_app__Asset__c> scope) {
        string CurrentMethodName = 'execute';
        try{
            system.debug('value of scope'+scope);
            Map<String,String> fieldSourceMap = new Map<String,String>();
            Map<String,String> fieldTypeMap = new Map<String,String>();
            List<SObject> objsToInsert = new List<SObject>();
            List<SObject> objToUpdate = new List<SObject>();
            sObject trgetDataRec;
            Map<String,String> objDataMap = new Map<String,String>();//Map of objdata(id,Source_Record_Type__c)
            Map<Field_Mappings__c,String> fieldObjMap = new Map<Field_Mappings__c,String>(); //Map of fielddata(Field_Mappings__c,object dataid);
            String objDataId;
            List<String> insertResultLst = new List<String>();
            Map<String,String> insertResultMap = new Map<String,String>();
            Map<String,String> targetobjMap = new Map<String,String>();
            Map<String,String> assetMap = new Map<String,String>();
            List<SObject> dataToUpdate = new List<SObject>();
            List<Field_Mappings__c> finalFieldLst = new List<Field_Mappings__c>();
            List<String> fields=new List<String>();
            Map<String,sustain_app__EnergyConsumption__c> OrgAssetEnryMap = new Map<String,sustain_app__EnergyConsumption__c>();
            
            Map <String, Schema.SObjectField> EnergyFieldMap= sustain_app__EnergyConsumption__c.sObjectType.getDescribe().fields.getMap();
            for(Schema.SObjectField fieldVal : EnergyFieldMap.values()){
                Schema.SObjectField sfield=fieldVal;
            	schema.describefieldresult dfield = sfield.getDescribe();
            	fields.add(dfield.getName());
            }
            String Query=' select ' + String.join(fields, ',') + ' from sustain_app__EnergyConsumption__c';
            List<sustain_app__EnergyConsumption__c> energyLst = Database.query(Query);
            for(sustain_app__EnergyConsumption__c energyData : energyLst){
                OrgAssetEnryMap.put(energyData.sustain_app__Asset__c,energyData);
            }
            
            
           // List<Object_Mappings__c> objData1 = [Select id,Name,Source_Object__c,Source_Record_Type__c,Target_Object__c FROM Object_Mappings__c Where Source_Object__c='sustain_app__Asset__c' Limit 1000 ];
            for( Object_Mappings__c objRec : [Select id,Name,Source_Object__c,Source_Record_Type__c,Target_Object__c FROM Object_Mappings__c Where Source_Object__c='sustain_app__Asset__c' Limit 1000 ]){
                objDataMap.put(objRec.Source_Record_Type__c,objRec.id);
            }
            system.debug('value of objDataMap'+objDataMap);//3 records
            
            //List<Field_Mappings__c> fieldMapLst = [Select  id,Name,Object_Mapping__c,Source_Field__c,Target_Field__c,Source_Field_Type__c,Target_Field_Type__c,Mapping_Included__c from Field_Mappings__c Where Mapping_Included__c=true Limit 10000 ];
            for(Field_Mappings__c fieldRec : [Select  id,Name,Object_Mapping__c,Source_Field__c,Target_Field__c,Source_Field_Type__c,Target_Field_Type__c,Mapping_Included__c from Field_Mappings__c Where Mapping_Included__c=true Limit 10000 ]){
                fieldObjMap.put(fieldRec,fieldRec.Object_Mapping__c);
            }
            system.debug('value of fieldObjMap'+fieldObjMap);//will get all the field mapping from org
            
            //for(sustain_app__EnergyConsumption__c energyRec : [Select id,Name,])
            
            for(sustain_app__Asset__c assetData : scope){
                system.debug('value of assetData.Target_SFDC_ID__c'+assetData.Target_SFDC_ID__c);
                //if(assetData.Target_SFDC_ID__c=='' || assetData.Target_SFDC_ID__c==null){
                if(String.isBlank(assetData.Target_SFDC_ID__c)){
                    batchStatus = true ;
                    assetMap.put(assetData.Id,assetData.Name);
                    String recordName = 'sustain_app__' + assetData.RecordType.Name;
                    objDataId = objDataMap.get(recordName);
                    system.debug('value of objDataId'+objDataId);
                    if(String.isNotBlank(recordName) && String.isNotEmpty(recordName)){
                    if(BuildingRecordtypeAPI.equalsIgnoreCase(recordName)){
                        trgetDataRec = new StnryAssetEnvrSrc(); 
                    }else if(VehicleRecordtypeAPI.equalsIgnoreCase(recordName)){
                        trgetDataRec = new VehicleAssetEmssnSrc();
                    }else if(GeneralRecordType.equalsIgnoreCase(recordName)){
                        trgetDataRec = new Scope3EmssnSrc();
                    }
                }
                    for(Field_Mappings__c fieldData : fieldObjMap.keyset() ){
                        if(fieldObjMap.get(fieldData)==objDataId){
                            system.debug('inside fieldObjMap map check');
                            system.debug('value of fieldObjMap.get(fieldData)'+fieldObjMap.get(fieldData));
                            system.debug('value of objDataId'+objDataId);
                            finalFieldLst.add(fieldData);
                        }
                    }
                    system.debug('value of finalFieldLst'+finalFieldLst);
                    system.debug('value of finalFieldLst size'+finalFieldLst.size());
                    if(finalFieldLst.size()>0){
                        for(Field_Mappings__c fieldRec : finalFieldLst){
                            fieldSourceMap.put(fieldRec.Source_Field__c,fieldRec.Target_Field__c);
                            fieldTypeMap.put(fieldRec.Source_Field__c,fieldRec.Source_Field_Type__c);
                        }
                        system.debug('value of fieldSourceMap'+fieldSourceMap);
                        system.debug('value of fieldTypeMap'+fieldTypeMap);
                        for(String sourceFieldVal:fieldSourceMap.keyset()){
                            String assetId = assetData.Id;
                            system.debug('sourceFieldVal-->' + sourceFieldVal);
                            String  sourceVal = 'SELECT id,Name,'+ sourceFieldVal+' FROM sustain_app__Asset__c Where id=:assetId limit 1' ;
                            list<sustain_app__Asset__c> asstDatas = Database.query(sourceVal);
                            sustain_app__Asset__c asstData = asstDatas.get(0);
                            String targetFieldVal = fieldSourceMap.get(sourceFieldVal);
                            system.debug('targetFieldVal'+targetFieldVal);
                            if(targetFieldVal.contains(',')){
                                system.debug('inside contains');
                                List<String> targetFieldLst = targetFieldVal.split(',');
                                for(String targetField:targetFieldLst){
                                    try{
                                        if(DateLabel.equalsIgnoreCase(fieldTypeMap.get(targetField))){
                                            trgetDataRec.put(fieldSourceMap.get(targetField),(Date)asstData.get(targetField));  
                                        }else if(CheckboxLabel.equalsIgnoreCase(fieldTypeMap.get(targetField))){
                                            trgetDataRec.put(fieldSourceMap.get(targetField),(boolean)asstData.get(targetField));
                                        }else
                                            trgetDataRec.put(fieldSourceMap.get(targetField),(String)asstData.get(targetField));
                                    }catch(Exception ex){
                                        system.debug('error'+targetField);
                                        Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName); 
                                    }
                                }
                            }else{
                                system.debug('inside contains else');
                                try{
                                    if(DateLabel.equalsIgnoreCase(fieldTypeMap.get(sourceFieldVal))){
                                        trgetDataRec.put(fieldSourceMap.get(sourceFieldVal),(Date)asstData.get(sourceFieldVal));  
                                    }else if(CheckboxLabel.equalsIgnoreCase(fieldTypeMap.get(sourceFieldVal))){
                                        trgetDataRec.put(fieldSourceMap.get(sourceFieldVal),(boolean)asstData.get(sourceFieldVal));
                                    }else
                                        trgetDataRec.put(fieldSourceMap.get(sourceFieldVal),(String)asstData.get(sourceFieldVal));
                                }catch(Exception ex){
                                    system.debug('error'+sourceFieldVal);
                                    Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName); 
                                }
                            }}
                        trgetDataRec.put('Name',assetData.Name);
                        objsToInsert.add(trgetDataRec);
                    }
                    
                    if(OrgAssetEnryMap.get(assetData.Id) !=null){
                        
                   system.debug('value of OrgAssetEnryMap'+OrgAssetEnryMap);
                   system.debug('value of OrgAssetEnryMap size'+OrgAssetEnryMap.size());
                    }  
                }
            }
            if(objsToInsert.size()>0){
            List<Database.Saveresult> insertResults = Database.insert(objsToInsert); 
            for (Database.SaveResult sr : insertResults) {
                if (sr.isSuccess()) {
                    insertResultLst.add(sr.getId());
                }
            }
            
            for(Id insertRec: insertResultLst){
                string objApiName = insertRec.getSObjectType().getDescribe().getName();
                String idVal = insertRec;
                system.debug('value of objApiName'+objApiName);
                String queryData = 'Select id,Name from '+ objApiName + ' Where id=:idVal';
                system.debug('value f queryData'+queryData);
                SObject asstData = Database.query(queryData);
                system.debug('value f asstData'+asstData);
                targetobjMap.put((String)asstData.get('Name'),insertRec);
            }
            
                for(sustain_app__Asset__c asstData : [SELECT id,Name,RecordType.Name,Target_SFDC_ID__c FROM sustain_app__Asset__c Where Id IN :assetMap.keyset() Limit 1000] ){
                	asstData.Target_SFDC_ID__c = targetobjMap.get(asstData.Name);
                    asstData.Migration_Status__c = 'Completed';
                    dataToUpdate.add(asstData);
                }
                Database.update(dataToUpdate);
        } 
           /* for(){
                
            }*/
            }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
            errorMessage = e.getMessage();
        }   
        
    }
    
    // Finish Method
    global void finish(Database.BatchableContext BC) {
        user us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
        List<String> emailAddress = new List<String>();
        emailAddress.add(us.email);
        if((String.isBlank(errorMessage) || String.isEmpty(errorMessage)) && batchStatus == true ){
            Sustain_SendNotification sendData =new Sustain_SendNotification();
            sendData.sendChatterNotification('SampleDataLoadEmails');
            sendData.sendEmailNotification('Sustain_SampleDataLoadEmails',emailAddress);
            Data_Load_Request__c dataRec = [Select id,Name,End_Date_Time__c,Status__c from Data_Load_Request__c where id=:dataLoadId Limit 1];
            dataRec.End_Date_Time__c = system.now();
            dataRec.Status__c = 'Completed';
            Database.update(dataRec);
            /*Sustain_SampleLoadEvent__e publishEvents = new Sustain_SampleLoadEvent__e();
            publishEvents.Sustain_BatchStatus__c = true;
            EventBus.publish(publishEvents);*/
        }
    }
    
    
}