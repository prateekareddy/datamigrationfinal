/**
* @description       : 
* @author            : Accenture
* @group             : 
* @last modified on  : 09-30-2021
* @last modified by  : Accenture
**/
public without sharing class Sustain_MigrationWizardController {
    private static final string CurrentClassName = 'Sustain_MigrationWizardController';
    @AuraEnabled
    public static ObjMappingListWrapper getObjMapping(){
        ObjMappingListWrapper listWrapper= new ObjMappingListWrapper();
        List<Object_Mappings__c> stdList =new List<Object_Mappings__c>();
        List<Object_Mappings__c> custList=new List<Object_Mappings__c>();
        List<Object_Mappings__c> stdwithCustFieldList=new List<Object_Mappings__c>();
        for(Object_Mappings__c objMap:[SELECT Id, Source_Object__c,Source_Record_Type__c,Destination_Object_Label__c,Source_Object_Label__c,Target_Object__c, Target_Record_Type__c,Total_Fields__c, 
                                       Object_Type__c,Total_To_Review_Fields__c, Sequence_Number__c,Mapping_Included__c,Source_Recordtype_Label__c,Target_RecordType_Label__c FROM Object_Mappings__c]){
                                           if(objMap.Object_Type__c==Sustain_UtilConstants.standardLabel){
                                               stdList.add(objMap);                                                 
                                           }
                                           else if(objMap.Object_Type__c==Sustain_UtilConstants.customLabel || objMap.Object_Type__c==Sustain_UtilConstants.CustomwithCORE){
                                               custList.add(objMap);                                  
                                           }
                                           else if(objMap.Object_Type__c==Sustain_UtilConstants.standardWithCustFieldLabel){
                                               stdwithCustFieldList.add(objMap);                                 
                                           }
                                       }
        if(stdList.size()>0){
            listWrapper.stdObjList=stdList;                                   
        }
        if(custList.size()>0){
            listWrapper.customObjList=custList;                                   
        } 
        if(stdwithCustFieldList.size()>0){
            listWrapper.stdObjwithCustFieldList=stdwithCustFieldList;                                   
        }
        listWrapper.coreObjectMap=Sustain_UtilConstants.coreObjectMap;
        return listWrapper; 
    }
    @AuraEnabled
    public static MappingListWrapper getAllMapping(){
        List<String> utilityFields=Sustain_UtilConstants.getUtilityItems();    
        MappingListWrapper wrap= new MappingListWrapper();
        wrap.objMappingList=[SELECT Id, Source_Object__c,Source_Record_Type__c,Source_Object_Label__c,Destination_Object_Label__c,Target_Object__c, Target_Record_Type__c,Total_Fields__c, 
                             Object_Type__c,Check_Source_And_Target__c,Total_To_Review_Fields__c, Sequence_Number__c,Source_Recordtype_Label__c,Target_RecordType_Label__c FROM Object_Mappings__c  where Mapping_Included__c=true 
                             and Check_Source_And_Target__c ='true' AND Total_Mapping_Eligible_Field__c > 0 order by Total_To_Review_Fields__c desc];
        wrap.fieldMappingList=[SELECT Id, Source_Field__c,Source_Field_Label__c,Source_Field_Type__c,Target_Field_Label__c,Target_Field__c, Target_Field_Type__c, Calculated__c, 
                               New_Field__c,Mapping_Included__c, Object_Mapping__c, Object_Mapping__r.Source_Object__c,Object_Mapping__r.Target_Object__c,Required__c,Reference_To__c,
                               Object_Mapping__r.Total_Fields__c,To_Review__c,Object_Mapping__r.Total_To_Review_Fields__c,Object_Mapping__r.Source_Object_Label__c,Object_Mapping__r.Destination_Object_Label__c,
                               Comments__c,Custom_Field__c FROM Field_Mappings__c where Object_Mapping__r.Mapping_Included__c=true and Object_Mapping__r.Check_Source_And_Target__c ='true' and Object_Mapping__r.Total_Mapping_Eligible_Field__c > 0 AND Calculated__c =false and Source_Field__c NOT IN :utilityFields 
                               order by Object_Mapping__c];                    
        return wrap;
    }
    @AuraEnabled
    public static void updateObjMapping(List<Object_Mappings__c> objMappingMap){
        string CurrentMethodName = 'updateObjMapping';
        try{
            List<String> tempIds=new List<String>();
            for(Object_Mappings__c omp : objMappingMap){
                if(omp.Mapping_Included__c==true){
                    omp.Object_Type__c=Sustain_UtilConstants.CustomwithCORE;
                }
                else{
                    omp.Object_Type__c=Sustain_UtilConstants.customLabel;
                }
                tempIds.add(omp.Id);
            }
            Database.update(objMappingMap,false);
            List<Field_Mappings__c> fieldList=[select id from Field_Mappings__c where Object_Mapping__c IN : tempIds];
            if(fieldList.size()>0){
                Database.delete(fieldList,false);
            }
            List<Object_Mappings__c> mappingList= [select id,Object_Type__c,Source_Object__c,Target_Object__c,(select id from Field_Mappings__r) from Object_Mappings__c where ID IN : tempIds and Object_Type__c=: Sustain_UtilConstants.CustomwithCORE
                                                   and Mapping_Included__c=true];
            List<Object_Mappings__c> mappingList2=[select id,Source_Object__c from Object_Mappings__c where ID IN : tempIds and Object_Type__c=: Sustain_UtilConstants.customLabel
                                                   and Mapping_Included__c=false];

            Boolean isMetadataCreateReq = false;
            if(mappingList.size()>0){
                Sustain_CreateMigrationMapping.createCustomFieldMappings(mappingList);
                isMetadataCreateReq = true;
            }
            if(mappingList2.size()>0){
                Sustain_CreateMigrationMapping.createCustObjMappingforMngPckgDependentFieldsforSpecific(mappingList2);
                isMetadataCreateReq = true;
            }

            if(isMetadataCreateReq){
                Migration_Status__c mig = Migration_Status__c.getOrgDefaults();
                mig.Metadata_Created__c = false;
                update mig;
            }
        }
        catch(Exception ex){
            Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName); 
        }
    }
    
    @AuraEnabled
    public static boolean getDataMappingDetails(){
        list<Object_Mappings__c> objDetails  = [select id, Removed_Field_Mapping_Count__c  from Object_Mappings__c where Mapping_Included__c=true];
        boolean mappingRec =false;
        for(Object_Mappings__c obj: objDetails ){
            if(obj.Removed_Field_Mapping_Count__c != 0){
                mappingRec = true; 
                break;
            } 
        }
        return mappingRec;
    }
    
    
    
    @AuraEnabled
    public static void updateFieldMapping(List<Field_Mappings__c> fieldMappingList){
        string CurrentMethodName = 'updateFieldMapping';
        try{
            boolean temp = false;
            for(Field_Mappings__c fm : fieldMappingList ) {
                if(fm.New_Field__c == true ){
                    fm.Target_Field_Label__c = fm.Source_Field_Label__c;
                    fm.Target_Field__c = fm.Source_Field__c;
                    fm.Target_Field_Type__c = fm.Source_Field_Type__c;
                    temp = true;
                }
            }
            Database.update(fieldMappingList,false);
            if(temp == true){
                Migration_Status__c mig = Migration_Status__c.getOrgDefaults();
                mig.Metadata_Created__c = false;
                update mig;
            }
        }
        catch(Exception ex){
            Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName);
        }
    }
    @AuraEnabled
    public static string getCurrentStage(){
        String value;
        Migration_Status__c ms = Migration_Status__c.getOrgDefaults();
        if(Sustain_UtilConstants.stageStepMap.containsKey(ms.Current_Migration_Stage__c)){
            value=Sustain_UtilConstants.stageStepMap.get(ms.Current_Migration_Stage__c);
        }
        return value; 
    }

    @AuraEnabled
    public static boolean getMigrationStatusData(){        
        Migration_Status__c ms = Migration_Status__c.getOrgDefaults();       
        return ms.Pre_Requisite_Status__c; 
    }

    @AuraEnabled
    public static boolean updateMigrationStatus(String stepNo){
        string CurrentMethodName = 'updateMigrationStatus';
        string stage=Sustain_UtilConstants.stepStageMap.get(stepNo);
        try{    
            Migration_Status__c ms = Migration_Status__c.getOrgDefaults();
            ms.Current_Migration_Stage__c = stage;
            if(stage == 'Review/Update Object Mapping'){
                ms.Pre_Requisite_Status__c = true;
            }
            update ms;
            return true;
        }catch(Exception ex){
            Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName);
            return false;
        }       
    }
    @AuraEnabled
    public static List<CustomFieldWrapper> getAllCustomFields(String objName){
        List<String> utilityFields=Sustain_UtilConstants.getUtilityItems();  
        List<CustomFieldWrapper> fieldList =new List<CustomFieldWrapper>();
        SObjectType sObj = Schema.getGlobalDescribe().get(objName);
        for (SObjectField aField : sObj.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDesc = aField.getDescribe();
            if (!Sustain_UtilConstants.stdFieldList.contains(fieldDesc.getName()) && !utilityFields.contains(fieldDesc.getName().removeStart('Migration_Util__'))) {
                CustomFieldWrapper wrap=new CustomFieldWrapper();
                wrap.targetFieldLabel=fieldDesc.getLabel();
                wrap.targetFieldAPI=fieldDesc.getName().removeStart('Migration_Util__');
                wrap.targetFieldType=Sustain_UtilConstants.castTypeToString(fieldDesc.getType());
                if(wrap.targetFieldType=='Reference' && fieldDesc.isNamePointing()==false){
                    List<Schema.sObjectType> sobjType=fieldDesc.getReferenceTo();
                    Schema.DescribeSObjectResult res=sobjType[0].getDescribe();
                    wrap.referenceTo=res.getName().removeStart('Migration_Util__'); 
                }
                fieldList.add(wrap);
            }
        }
        if(fieldList.size()>0){
            fieldList.sort();        
            return fieldList;
        }
        else{
            return null;
        }
    }
    public class MappingListWrapper{
        @AuraEnabled
        public List<Object_Mappings__c> objMappingList;
        @AuraEnabled
        public List<Field_Mappings__c> fieldMappingList;
    }
    
    public class CustomFieldWrapper implements Comparable{
        @AuraEnabled
        public string targetFieldLabel;
        @AuraEnabled
        public string targetFieldAPI;
        @AuraEnabled
        public string targetFieldType;
        @AuraEnabled
        public string referenceTo;
    
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            CustomFieldWrapper compareToFieldLabel = (CustomFieldWrapper)compareTo;
            //Sort by fieldName Alphabetically            
            return targetFieldLabel.compareTo((compareToFieldLabel.targetFieldLabel));                          
        }
    }
    
    @AuraEnabled
    public static Id executeBatchJob() {
        Migration_Status__c ms = Migration_Status__c.getOrgDefaults();
        ms.Running_Metadata_Job__c = true;
        update ms; 
        Id jobId = Database.executeBatch(new Sustain_CreateMetadataBatch(),1);
        return jobId;
    }
    @AuraEnabled
    public static boolean getRunningMetadataJobFlag() {
        return Migration_Status__c.getOrgDefaults().Running_Metadata_Job__c;
    }    
    @AuraEnabled
    public static boolean getMigrationStatusSetting(){
        System.debug('Migration_Status__c.getInstance() => '+Migration_Status__c.getOrgDefaults());
        return Migration_Status__c.getOrgDefaults().Metadata_Created__c;
    }

    @AuraEnabled
    public static boolean getSCPackageVersion(){
        //Integer majorVer, minorVer;
        String verNo = '';
        // Getting sustainability cloud package details like version number
        List<Publisher> scPackageDetails = [SELECT Id,MajorVersion, MinorVersion, Name, NamespacePrefix from Publisher where NamespacePrefix = 'sustain_app' limit 1];
        if(scPackageDetails.size() > 0){
            //majorVer = scPackageDetails[0].MajorVersion;
            //minorVer = scPackageDetails[0].MinorVersion;  
            verNo = String.valueOf(scPackageDetails[0].MajorVersion)+ '.' + String.valueof(scPackageDetails[0].MinorVersion);  
        }
        System.debug('Ver No => '+verNo);
        if(verNo != null && Decimal.valueOf(verNo) >= 1.14){
            return true;
        }else{
            return false;
        } 
    }

    @AuraEnabled
    public static void deleteDataLoadReq(){
        try{
            Data_Load_Request__c dataRec = new Data_Load_Request__c();
            dataRec.Request_Job_Name__c = 'Delete Data Load';
            dataRec.Start_Date_Time__c = system.now();
            dataRec.Data_Load_Type__c = 'Delete Data Load';
            datarec.Status__c= 'Not Started';
            Database.insert(dataRec);
            if(String.isNotBlank(dataRec.Id) && String.isNotEmpty(dataRec.Id)){
                List<Object_Mappings__c> objMapList = new List<Object_Mappings__c>();
                for(Object_Mappings__c objMap :[SELECT Id, Name,Status__c FROM Object_Mappings__c where Status__c != 'Not Started' LIMIT 1000]){
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
        } 
        
    }   
    
    @AuraEnabled
    public static boolean getMigrationStatus(){
        boolean  ms= [select Ready_to_Launch__c from Migration_Status__c].Ready_to_Launch__c;
        system.debug('ms--->' + ms);
        return ms && getSCPackageVersion();
        
    }
    @AuraEnabled
    public STATIC boolean startFinalDataLoad(){
        map<String, list<Object_Mappings__c>>objMap = new  map<String, list<Object_Mappings__c>>();
        Map<String,List<Field_Mappings__c>> fldMap = new Map<String,List<Field_Mappings__c>> ();
        Data_Load_Request__c dataRec = new Data_Load_Request__c();
        try{
            List<String> orgAssetIds = new List<String>();         
            
            dataRec.Request_Job_Name__c = 'Complete Data Load';
            dataRec.Start_Date_Time__c = system.now();
            dataRec.Data_Load_Type__c = 'Complete Data Load';
            dataRec.Status__c = 'In Progress';
            integer seqNo;
            Database.insert(dataRec);
            if(String.isNotBlank(dataRec.Id)){  
                seqNo = Sustain_Utils.getSequebnceNo(1);
                if(seqNo != null) {
                    string sqlStr = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c from Object_Mappings__c where Sequence_Number__c=:seqNo and Status__c = \'Not Started\' AND Object_Type__c != \'custom\' and mapping_included__c=true order by  sequence_number__c,Target_Object__c nulls last';
                    system.debug('createDataLoadReq sql -->' + sqlStr);
                    list<Object_Mappings__c> objMappingList = Database.query(sqlStr);
                    list<id> recordIds =  new list<id>();
                    if(objMappingList != null) {
                        for(Object_Mappings__c obj : objMappingList) {
                            recordIds.add(obj.id);
                            string key = obj.Source_Object__c + '-' +obj.Source_Record_Type__c.replaceAll('sustain_app__','').replaceAll('Sustain_app__','');
                            if(objMap.keyset().contains(key)) {
                                objMap.get(key).add(obj);
                            } else {
                                list<Object_Mappings__c> tempList = new list<Object_Mappings__c>();
                                tempList.add(obj);
                                objMap.put(key,tempList);
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
                        database.executeBatch(nextBatch);
                    } else {
                        string sqlStr1 = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c from Object_Mappings__c where Status__c = \'Not Started\' AND Object_Type__c = \'custom\' and mapping_included__c=true order by  sequence_number__c,Target_Object__c nulls last limit 1';    
                        list<Object_Mappings__c> customObjectList = Database.query(sqlStr1);
                        if(customObjectList!=null && customObjectList.size() > 0){                
                            Sustain_UpdateCustomObjectRefBatch nextcustBatch = new Sustain_UpdateCustomObjectRefBatch(customObjectList[0], 'FinalDataLoad');
                            database.executeBatch(nextcustBatch);
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
            System.debug('An exception occurred: ' + e.getMessage());
            return false;
        }  
        return true;
        
    }
    @AuraEnabled
    public static integer getObjectMappingCount(){
        integer  om= [SELECT COUNT() FROM Object_Mappings__c where Status__c != 'Not Started'];
        system.debug('om--->' + om);
        return om;
        
    }
    @AuraEnabled
    public static List<String> getAllMappings(){
        List<String> srcTargetList=new List<String>();
        Map<String,Set<String>> mapSetList=Sustain_CreateMigrationMapping.allMappings();
        for(String s: mapSetList.Keyset()){
            for(String v : mapSetList.get(s)){
                srcTargetList.add(s+''+v);
            }
        }
        return srcTargetList;
    }
    
    @AuraEnabled
    public static boolean getrunningJobStatus(){
        boolean loadStatus=true ;
        try{
           
              List<Data_Load_Request__c> dataRecStatus = [Select id,Name,End_Date_Time__c,Status__c,LastModifiedDate,Request_Job_Name__c from Data_Load_Request__c order by LastModifiedDate desc Limit 1];
                if(dataRecStatus.size()>0 && (dataRecStatus[0].Status__c == 'In Progress' || dataRecStatus[0].Status__c == 'Not Started')){
                
                       loadStatus = false;
                } 
                
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
        } 
        system.debug('loadStatus-->'+loadStatus);
        return loadStatus;
    }
    @AuraEnabled
    public static EmissionFactorWrapper getAllEmissionFactors(){
        string CurrentMethodName = 'getAllEmissionFactors';
        try{
            EmissionFactorWrapper wrap= new EmissionFactorWrapper();    
            List<Sobject> elecFctrList = database.query('select id,Name from ElectricityEmssnFctrSet where Source_Record_ID__c = null order by Lastmodifieddate desc limit 1000');
            List<Sobject> othFctrList=database.query('select id,Name from OtherEmssnFctrSet where Source_Record_ID__c = null order by Lastmodifieddate desc limit 1000');
            List<Sobject> airFctrList=database.query('select id,Name from AirTravelEmssnFctr where Source_Record_ID__c = null order by Lastmodifieddate desc limit 1000');
            List<Sobject> grndFctrList=database.query('select id,Name from GroundTravelEmssnFctr where Source_Record_ID__c = null order by Lastmodifieddate desc limit 1000');
            List<Sobject> frgtFctrList=database.query('select id,Name from FrgtHaulingEmssnFctr where Source_Record_ID__c = null order by Lastmodifieddate desc limit 1000');
            List<Sobject> htlFctrList=database.query('select id,Name from HotelStayEmssnFctr where Source_Record_ID__c = null order by Lastmodifieddate desc limit 1000');
            List<Sobject> refriFctrList=database.query('select id,Name from RefrigerantEmssnFctr where Source_Record_ID__c = null order by Lastmodifieddate desc limit 1000');
            List<Sobject> rntalFctrList=database.query('select id,Name from RentalCarEmssnFctr where Source_Record_ID__c = null order by Lastmodifieddate desc limit 1000');
            wrap.elecFctrList=elecFctrList;
            wrap.othFctrList=othFctrList;
            wrap.airFctrList=airFctrList;
            wrap.grndFctrList=grndFctrList;
            wrap.frgtFctrList=frgtFctrList;
            wrap.htlFctrList=htlFctrList;
            wrap.refriFctrList=refriFctrList;
            wrap.rntalFctrList=rntalFctrList;
            return wrap;
        }
        catch(Exception ex){
            Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName); 
            return null;
        } 
    }
    @AuraEnabled
    public static void createEmissionFactorRecords(Map<String,Object> emissionFactorMap){
        string CurrentMethodName = 'createEmissionFactorRecords';
        try{
            List<Default_Emission_Factors__c> emissionFctrList=new List<Default_Emission_Factors__c>();
            for(String key :emissionFactorMap.keySet()){
                Default_Emission_Factors__c temp = new Default_Emission_Factors__c();
                temp.name=key;
                temp.Factor_Value__c=(String)emissionFactorMap.get(key);
                emissionFctrList.add(temp);
            }
            if(emissionFctrList.size()>0){
                Database.upsert(emissionFctrList);

                Sustain_CreateSourceIDFieldsBatch createFieldBatch = new Sustain_CreateSourceIDFieldsBatch();
                ID batchProcessId = database.executeBatch(createFieldBatch, 100);

                Migration_Status__c ms = Migration_Status__c.getInstance(UserInfo.getOrganizationId());
                if(ms==null){
                    ms = new Migration_Status__c(); 
                    ms.Current_Migration_Stage__c   = 'Org Data Scan Output';             
                }
                
                ms.Ready_To_Launch__c = true;
                upsert ms;
            }
        }
        catch(Exception ex){
            Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName);
            throw new AuraHandledException('Error in creating records');
        } 
    }
}