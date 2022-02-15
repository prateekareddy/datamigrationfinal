/**
 * @description       : 
 * @author            : Accenture
 * @group             : 
 * @last modified on  : 09-30-2021
 * @last modified by  : Accenture
**/
global without sharing class Sustain_CreateMigrationMapping {

    public static List<String> emailAdress;
    private static final string CurrentClassName = 'Sustain_CreateMigrationMapping';
   
    global static void createObjectMapping(String csvFileName){
        string CurrentMethodName = 'createObjectMapping';
        try{            
            //delete previous records
            deleteObjMapping();
            /* start processing */
            StaticResource defaultResource = [Select  s.Body From StaticResource s where s.Name=:csvFileName limit 1];
            blob tempB = defaultResource.Body;
            String contentFile = tempB.toString();
            String[] filelines = contentFile.split('\n');
            List<Object_Mappings__c> objMapList = new List<Object_Mappings__c>();
            for (Integer i=1;i<filelines.size();i++)
            {
                if(filelines[i]!=null){
                    Object_Mappings__c temp = new Object_Mappings__c();
                    String[] inputvalues = filelines[i].split(',');
                    temp.Source_Object_Label__c = inputValues[0];
                    temp.Source_Object__c = inputValues[1];
                    temp.Source_Recordtype_Label__c=inputValues[2];
                    temp.Source_Record_Type__c = inputValues[3];
                    temp.Destination_Object_Label__c = inputValues[4];
                    temp.Target_Object__c = inputValues[5];
                    temp.Target_RecordType_Label__c=inputValues[6];
                    temp.Target_Record_Type__c = inputValues[7];
                    temp.Sequence_Number__c =Integer.valueOf(inputValues[8].trim());
                    temp.Delete_Sequence_No__c =Integer.valueOf(inputValues[9].trim());
                    temp.Batch_Size__c =Integer.valueOf(inputValues[10].trim());
                    temp.Object_Type__c = getObjectType(inputValues[1]);
                    
                    //System.debug('Total record '+Database.countQuery('select count() from '+inputValues[1]));
                    /*String QueryString = 'SELECT count() FROM '+inputValues[1];
                    if(inputValues[3] != null && inputValues[3] != 'Master'){
                        QueryString = QueryString + ' where recordType.DeveloperName = \''+inputValues[3] + '\''; 
                    } 
                    temp.Total_Records__c = String.valueOf(Database.countQuery(QueryString));
                    System.debug(' temp.Total_Records__c'+ temp.Total_Records__c);*/
                    objMapList.add(temp);
                }
            }
            if(objMapList.size()>0){
                Database.insert(objMapList,false);
            } 
            createFieldsMapping('SustainDataMigration_FieldMapping');           
        }
        catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
    }
    public static void createFieldsMapping(String csvFileName){
        string CurrentMethodName = 'createFieldsMapping';
        try{
            //delete previous records
                deleteFieldMapping();
            /* start processing */
            Map<String,Id> srcObjRecordtypeMap=new Map<String,Id>();
            for(Object_Mappings__c oMap:[select id,Source_Record_Type__c,Source_Object__c,Target_Object__c,Target_Record_Type__c from Object_Mappings__c where Source_Object__c!=null]){
                srcObjRecordtypeMap.put(oMap.Source_Object__c+''+oMap.Source_Record_Type__c+''+oMap.Target_Object__c+''+oMap.Target_Record_Type__c,oMap.id);
            }
            StaticResource defaultResource = [Select  s.Body From StaticResource s where s.Name=:csvFileName limit 1];
            blob tempB = defaultResource.Body;
            String contentFile = tempB.toString();
            String[] filelines = contentFile.split('\n');
            List<Field_Mappings__c> fieldMapList = new List<Field_Mappings__c>();
            for (Integer i=1;i<filelines.size();i++)
            {
                Field_Mappings__c temp = new Field_Mappings__c();
                if(filelines[i]!=null){
                    String[] inputvalues = filelines[i].split(';');
                    temp.Source_Field_Label__c = inputValues[0];
                    temp.Source_Field__c = inputValues[1];
                    temp.Source_Field_Type__c = inputValues[2];
                    temp.Target_Field_Label__c = inputValues[3];
                    temp.Target_Field__c = inputValues[4];
                    temp.Target_Field_Type__c = inputValues[5];
                    temp.Calculated__c = Boolean.valueof(inputValues[6]);
                    temp.New_Field__c = Boolean.valueOf(inputValues[7]);
                    temp.Mapping_Included__c =boolean.valueOf(inputValues[8]);
                    if(srcObjRecordtypeMap.containsKey(inputValues[10].trim()+''+inputValues[12].trim()+''+inputValues[14].trim()+''+inputValues[16].trim())){
                        temp.Object_Mapping__c =srcObjRecordtypeMap.get(inputValues[10].trim()+''+inputValues[12].trim()+''+inputValues[14].trim()+''+inputValues[16].trim());
                    }
                    else{
                        system.debug('not found '+inputValues[0]+' '+inputValues[10].trim()+' '+inputValues[12].trim()+' '+inputValues[14].trim()+''+inputValues[16].trim());
                    }
                    fieldMapList.add(temp);
                }   
            }
            if(fieldMapList.size()>0){ 
                Database.insert(fieldMapList,false);
                List<Object_Mappings__c> mappingList=[select id,Object_Type__c,Source_Object__c,(select id from Field_Mappings__r) from Object_Mappings__c where Object_Type__c=: Sustain_UtilConstants.standardWithCustFieldLabel
                                                      and Mapping_Included__c=true LIMIT 10000 ];
                if(mappingList.size()>0){
                    createCustomFieldMappings(mappingList);
                }
            }
            createCustomObjectMapping();
        }
        catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
    }
    @testVisible
    private static String getObjectType(String objName){
        List<String> utilityFieldList=Sustain_UtilConstants.getUtilityItems();
        
        SObjectType sObj = Schema.getGlobalDescribe().get(objName);
        for (SObjectField aField : sObj.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDesc = aField.getDescribe();
            if (fieldDesc.isCustom() && !fieldDesc.getName().startsWith('sustain_app__')
                && !utilityFieldList.contains(fieldDesc.getName().removeStart('Migration_Util__'))) {
                    return Sustain_UtilConstants.standardWithCustFieldLabel;
                }
        }
        return Sustain_UtilConstants.standardLabel;
    }
    
    public static void createCustomObjectMapping(){
        string CurrentMethodName = 'createGenericRecords';
        try{
            List<Object_Mappings__c> objMapList = new List<Object_Mappings__c>();
            Map<String, Schema.SObjectType> globalMap = Schema.getGlobalDescribe();
            List<String> utilityObjectList=Sustain_UtilConstants.getUtilityItems();

            /*Boolean isValidObj = false;
            String objectName = '';*/

            for (Schema.SObjectType obj : globalMap.values()) {
                Schema.DescribeSObjectResult objDesc = obj.getDescribe();
                //isValidObj = false;     
                if(/*!objDesc.getName().startsWith('sustain_app__') &&*/ objDesc.iscustom() && !objDesc.getName().endsWith('__mdt')
                   && !objDesc.isCustomSetting() && !objDesc.getName().endsWith('__kav') && !objDesc.getName().endsWith('__ka')
                   && !utilityObjectList.contains(objDesc.getName()) && objDesc.getName().endsWith('__c')){
                       for(SObjectField aField : objDesc.fields.getMap().values()) {
                           Schema.DescribeFieldResult fieldDesc = aField.getDescribe();
                           if(Sustain_UtilConstants.castTypeToString(fieldDesc.getType()).equals(Sustain_UtilConstants.referenceLabel) && fieldDesc.isNamePointing()==false){
                               List<Schema.sObjectType> sobjType=fieldDesc.getReferenceTo();
                               Schema.DescribeSObjectResult res=sobjType[0].getDescribe();
                               String objName=res.getName();
                               Object_Mappings__c temp;
                               if(!objDesc.getName().startsWith('sustain_app__') && objDesc.getName().EndsWith('__c') && objName.contains('sustain_app__')){ 
                                    temp = new Object_Mappings__c();
                                    temp.Source_Object_Label__c = objDesc.getLabel();
                                    temp.Source_Object__c = objDesc.getName();
                                    temp.Target_Object__c = objDesc.getName(); 
                                    temp.Mapping_Included__c=false;
                                    temp.Destination_Object_Label__c =objDesc.getLabel();
                                    temp.Object_Type__c = Sustain_UtilConstants.customLabel;
                                    objMapList.add(temp);
                                    break;  
                                   /*isValidObj = true;  
                                   objectName =  objDesc.getName(); */                            
                               }else if(objName.contains('__c') && !objName.startsWith('sustain_app__') && objDesc.getName().startsWith('sustain_app__') ){
                                    temp = new Object_Mappings__c();
                                    temp.Source_Object_Label__c = res.getLabel();
                                    temp.Source_Object__c = objName;
                                    temp.Target_Object__c = objName; 
                                    temp.Mapping_Included__c=false;
                                    temp.Destination_Object_Label__c =res.getLabel();
                                    temp.Object_Type__c = Sustain_UtilConstants.customLabel;
                                    objMapList.add(temp);
                                    break;  
                                    /*isValidObj = true;    
                                    objectName =  objName;*/                                
                               }
                               /*if(isValidObj){
                                    String QueryString = 'SELECT count() FROM '+ objectName;                                    
                                    temp.Total_Records__c = String.valueOf(Database.countQuery(QueryString));
                                    System.debug(' temp.Total_Records__c'+ temp.Total_Records__c);                                    
                                    objMapList.add(temp);
                                    break;    
                               }*/
                           }
                       }
                   }
            }
            if(objMapList.size()>0){
                Database.insert(objMapList,false);
            }
            createCustObjMappingforMngPckgDependentFields();
        }
        catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
    }
    
    public static void createCustomFieldMappings(List<Object_Mappings__c> objMappingList){
        string CurrentMethodName = 'createCustomFieldMappings';
        try{
            List<Object_Mappings__c> mappingList= new List<Object_Mappings__c>();
            List<String> utilityFieldList=Sustain_UtilConstants.getUtilityItems();
            String label;
            for(Object_Mappings__c oMap :objMappingList){
                if(oMap.Object_Type__c==Sustain_UtilConstants.standardWithCustFieldLabel){
                    label=Sustain_UtilConstants.standardWithCustFieldLabel;
                    mappingList.add(oMap);
                }
                else if(oMap.Object_Type__c==Sustain_UtilConstants.CustomwithCORE && oMap.Field_Mappings__r.size()==0){
                    label=Sustain_UtilConstants.CustomwithCORE;
                    mappingList.add(oMap);
                }
            }
            if(label==Sustain_UtilConstants.standardWithCustFieldLabel){
                createFieldMappingForStdObjs(mappingList,utilityFieldList);
            }
            else if(label==Sustain_UtilConstants.CustomwithCORE){
                createFieldMappingForCustObjs(mappingList,utilityFieldList);
            }
        }
        catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
        }
    }
    
    private static void createFieldMappingForStdObjs(List<Object_Mappings__c> mappingList,List<String> utilityFieldList){
        List<Field_Mappings__c> fieldMapList = new List<Field_Mappings__c>();
        for(Object_Mappings__c obj : mappingList){
            SObjectType sObj = Schema.getGlobalDescribe().get(obj.Source_Object__c);
            for (SObjectField aField : sObj.getDescribe().fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDesc = aField.getDescribe();
                if (fieldDesc.isCustom()&& !fieldDesc.getName().startsWith('sustain_app__')
                    && !utilityFieldList.contains(fieldDesc.getName().removeStart('Migration_Util__')) /*&& !fieldDesc.isCalculated()*/) {
                        Field_Mappings__c temp = new Field_Mappings__c();
                        temp.Source_Field_Label__c = fieldDesc.getLabel();
                        temp.Source_Field__c = fieldDesc.getName().removeStart('Migration_Util__');
                        temp.Source_Field_Type__c = Sustain_UtilConstants.castTypeToString(fieldDesc.getType());
                        //temp.Target_Field_Label__c = fieldDesc.getLabel();
                        //temp.Target_Field__c = fieldDesc.getName();
                        //temp.Target_Field_Type__c = Sustain_UtilConstants.castTypeToString(fieldDesc.getType());
                        temp.Required__c=!fieldDesc.isNillable();
                        if(temp.Source_Field_Type__c.equals(Sustain_UtilConstants.referenceLabel) && fieldDesc.isNamePointing()==false){
                            List<Schema.sObjectType> sobjType=fieldDesc.getReferenceTo();
                            Schema.DescribeSObjectResult res=sobjType[0].getDescribe();
                            temp.Reference_To__c=res.getName().removeStart('Migration_Util__'); 
                        }
                        temp.Calculated__c =fieldDesc.isCalculated(); //false;
                        temp.New_Field__c = false;
                        temp.Mapping_Included__c =false;
                        temp.Object_Mapping__c=obj.id;
                        fieldMapList.add(temp);
                    }
            }
        }
        if(fieldMapList.size()>0){ 
            Database.SaveResult[] srList =Database.insert(fieldMapList,false);
        }
    }
    private static void createFieldMappingForCustObjs(List<Object_Mappings__c> mappingList,List<String> utilityFieldList){
        List<Field_Mappings__c> fieldMapList = new List<Field_Mappings__c>();
        for(Object_Mappings__c obj : mappingList){
            SObjectType sObj = Schema.getGlobalDescribe().get(obj.Source_Object__c);
            String fieldLabel= getTargetObjectNameField(obj.Target_Object__c);
            for (SObjectField aField : sObj.getDescribe().fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDesc = aField.getDescribe();
                if (!Sustain_UtilConstants.stdFieldList.contains(fieldDesc.getName()) && !utilityFieldList.contains(fieldDesc.getName().removeStart('Migration_Util__'))
                    /*&& !fieldDesc.isCalculated()*/) {
                        Field_Mappings__c temp = new Field_Mappings__c();
                        temp.Source_Field_Label__c = fieldDesc.getLabel();
                        temp.Source_Field__c = fieldDesc.getName().removeStart('Migration_Util__');
                        temp.Source_Field_Type__c = Sustain_UtilConstants.castTypeToString(fieldDesc.getType());
                        //temp.Target_Field_Label__c = fieldDesc.getLabel();
                        //temp.Target_Field__c = fieldDesc.getName();
                        //temp.Target_Field_Type__c = Sustain_UtilConstants.castTypeToString(fieldDesc.getType());
                        temp.Required__c=!fieldDesc.isNillable();
                        if(temp.Source_Field_Type__c.equals(Sustain_UtilConstants.referenceLabel) && fieldDesc.isNamePointing()==false){
                            List<Schema.sObjectType> sobjType=fieldDesc.getReferenceTo();
                            Schema.DescribeSObjectResult res=sobjType[0].getDescribe();
                            temp.Reference_To__c=res.getName().removeStart('Migration_Util__'); 
                        }
                        temp.Calculated__c =fieldDesc.isCalculated(); //false;
                        temp.New_Field__c = false;
                        temp.Mapping_Included__c =false;
                        temp.Object_Mapping__c=obj.id;
                        if(fieldDesc.isNameField() && fieldLabel!=null){
                            temp.Target_Field_Label__c = fieldLabel;
                            temp.Target_Field__c = 'Name';
                            temp.Target_Field_Type__c ='String';
                            temp.Mapping_Included__c =true;
                        }
                        fieldMapList.add(temp);
                    }
            }
            fieldMapList.addAll(addUtiltiyFieldMappingRecords(obj.id));
        }
        if(fieldMapList.size()>0){ 
            Database.SaveResult[] srList =Database.insert(fieldMapList,false);
        }
    }
    private static List<Field_Mappings__c> addUtiltiyFieldMappingRecords(Id objMapId){
        List<Field_Mappings__c> fieldMappingList=new List<Field_Mappings__c>();
        Field_Mappings__c temp = new Field_Mappings__c(Source_Field_Label__c = 'Error Details',Source_Field__c = 'Error_Details__c',Source_Field_Type__c ='Long',
                                                      New_Field__c = true,Mapping_Included__c =false,Required__c=false,Calculated__c=false,Object_Mapping__c=objMapId,Comments__c='New Field',
                                                      Target_Field_Label__c = 'Error Details',Target_Field__c = 'Error_Details__c',Target_Field_Type__c ='Long');
        Field_Mappings__c temp1 = new Field_Mappings__c(Source_Field_Label__c = 'Migration Status',Source_Field__c = 'Migration_Status__c',Source_Field_Type__c ='Picklist',
                                                      New_Field__c = true,Mapping_Included__c =false,Required__c=false,Calculated__c=false,Object_Mapping__c=objMapId,Comments__c='New Field',
                                                      Target_Field_Label__c = 'Migration Status',Target_Field__c = 'Migration_Status__c',Target_Field_Type__c ='Picklist');
        Field_Mappings__c temp2 = new Field_Mappings__c(Source_Field_Label__c = 'Target SFDC ID',Source_Field__c = 'Target_SFDC_ID__c',Source_Field_Type__c ='Long',
                                                      New_Field__c = true,Mapping_Included__c =false,Required__c=false,Calculated__c=false,Object_Mapping__c=objMapId,Comments__c='New Field',
                                                      Target_Field_Label__c = 'Target SFDC ID',Target_Field__c = 'Target_SFDC_ID__c',Target_Field_Type__c ='Long');
        Field_Mappings__c temp3 = new Field_Mappings__c(Source_Field_Label__c = 'Source Record ID',Source_Field__c = 'Source_Record_ID__c',Source_Field_Type__c ='String',
                                                        New_Field__c = true,Mapping_Included__c =false,Required__c=false,Calculated__c=false,Object_Mapping__c=objMapId,Comments__c='New Field',
                                                        Target_Field_Label__c = 'Source Record ID',Target_Field__c = 'Source_Record_ID__c',Target_Field_Type__c ='String');
        fieldMappingList.add(temp);
        fieldMappingList.add(temp1);
        fieldMappingList.add(temp2);
        fieldMappingList.add(temp3);
        return fieldMappingList;
    }
    
    public static void deleteObjMapping(){
        string CurrentMethodName = 'deleteObjMapping';
        try{
            List<Object_Mappings__c> objMapList=[select id from Object_Mappings__c limit 100];
            if(objMapList.size()>0){
                database.delete(objMapList,false);
            }
        }
        catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
    }
    public static void deleteFieldMapping(){
        string CurrentMethodName = 'deleteFieldMapping';
        try{
            List<Field_Mappings__c> fieldMapList=[select id from Field_Mappings__c limit 3000];
            if(fieldMapList.size()>0){
                database.delete(fieldMapList,false);
            }
        }
        catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
    }
    public static void createCustObjMappingforMngPckgDependentFields(){
        string CurrentMethodName = 'createCustObjMappingforMngPckgDependentFields';
        try{
            Map<String,Set<String>> fullMappingMap= allMappings();
            Map<String, Schema.SObjectType> globalMap = Schema.getGlobalDescribe();
            List<String> utilityObjectList=Sustain_UtilConstants.getUtilityItems();
            List<String> custObjNames=new List<String>();
            Map<String,String> objMappingMap=new Map<String,String>();
            List<Field_Mappings__c> fieldMapList = new List<Field_Mappings__c>();
            List<Object_Mappings__c> objMapList = new List<Object_Mappings__c>();           
            for(Object_Mappings__c oMap : [select id,Mapping_Included__c,Source_Object__c from Object_Mappings__c where Object_Type__c=: Sustain_UtilConstants.customLabel]){
                if(oMap.Mapping_Included__c==true){
                    custObjNames.add(oMap.Source_Object__c);      
                }
                else{
                    objMappingMap.put(oMap.Source_Object__c,oMap.id);
                }
            }
            for (Schema.SObjectType obj : globalMap.values()) {
                boolean updObjMapping=false;
                Map<String,Integer> trgtObjCountMap=new Map<String,Integer>();
                Schema.DescribeSObjectResult objDesc = obj.getDescribe();
                if(!objDesc.getName().startsWith('sustain_app__') && objDesc.iscustom() && !objDesc.getName().endsWith('__mdt')
                   && !objDesc.isCustomSetting() && !objDesc.getName().endsWith('__kav') && !objDesc.getName().endsWith('__ka')
                   && !utilityObjectList.contains(objDesc.getName()) && !custObjNames.contains(objDesc.getName()) && objDesc.getName().endsWith('__c')){
                       String objMapId='';
                       if(objMappingMap.containsKey(objDesc.getName())){
                           objMapId=objMappingMap.get(objDesc.getName());
                       }
                       for(SObjectField aField : objDesc.fields.getMap().values()) {
                           Schema.DescribeFieldResult fieldDesc = aField.getDescribe();
                           if(Sustain_UtilConstants.castTypeToString(fieldDesc.getType()).equals(Sustain_UtilConstants.referenceLabel) && fieldDesc.isNamePointing()==false){
                               List<Schema.sObjectType> sobjType=fieldDesc.getReferenceTo();
                               Schema.DescribeSObjectResult res=sobjType[0].getDescribe();
                               if(res.getName().startsWith('sustain_app__') && fullMappingMap.containsKey(res.getName())){
                                   updObjMapping=true;
                                   for(String trgtObj : fullMappingMap.get(res.getName())){
                                       Field_Mappings__c temp = new Field_Mappings__c();
                                       temp.Source_Field_Label__c = fieldDesc.getLabel();
                                       temp.Source_Field__c = fieldDesc.getName().removeStart('Migration_Util__');
                                       temp.Reference_To__c = trgtObj.removeStart('Migration_Util__');
                                       temp.Calculated__c =false;
                                       temp.New_Field__c = true;
                                       temp.Comments__c='New Field';
                                       temp.Mapping_Included__c =true;
                                       temp.Target_Field_Label__c = Schema.getGlobalDescribe().get(trgtObj).getDescribe().getLabel();
                                       temp.Target_Field__c = trgtObj.removeStart('Migration_Util__')+'__c';
                                       temp.Target_Field_Type__c ='Reference';
                                       temp.Source_Field_Type__c='Reference';
                                       temp.Object_Mapping__c=objMapId;
                                       if(trgtObjCountMap.containsKey(trgtObj)){
                                           integer i=trgtObjCountMap.get(trgtObj);
                                           temp.Target_Field_Label__c = Schema.getGlobalDescribe().get(trgtObj).getDescribe().getLabel()+i;
                                           temp.Target_Field__c = trgtObj.removeStart('Migration_Util__')+i+'__c';
                                           i++;
                                           trgtObjCountMap.put(trgtObj,i);
                                       }
                                       else{
                                           temp.Target_Field_Label__c = Schema.getGlobalDescribe().get(trgtObj).getDescribe().getLabel();
                                           temp.Target_Field__c = trgtObj.removeStart('Migration_Util__')+'__c';
                                           trgtObjCountMap.put(trgtObj,1);
                                       }
                                       fieldMapList.add(temp);
                                   }
                               } 
                           }
                       }
                       if(updObjMapping){
                           Object_Mappings__c objTemp=new Object_Mappings__c();
                           objTemp.Id=objMapId;
                           objTemp.Mapping_Included__c=true;
                           objMapList.add(objTemp);
                       }
                       //fieldMapList.addAll(addUtiltiyFieldMappingRecords(objMapId));
                }
            }
            if(fieldMapList.size()>0){
                Database.insert(fieldMapList);
            }
            if(objMapList.size()>0){
                Database.update(objMapList);
            }
            
            Integer counter = 0;
            Set<Id> objIds = new Set<Id>();
            integer objList = database.countquery('select COUNT() from Object_Mappings__c LIMIT 10000');
            System.debug('objList '+objList);

            for(Object_Mappings__c oMap: [select Id, Source_Record_Type__c,Source_Object__c from Object_Mappings__c LIMIT 10000]){
                objIds.add(oMap.Id);
                counter++;
                System.debug('Counter '+counter);
                if(objList == 80 || objList == counter){
                    if(objList == counter){
                        updateNoOfRecords(objIds, true, emailAdress);
                    }else{
                        updateNoOfRecords(objIds, false, emailAdress);
                    }
                    objIds = new Set<ID>();                    
                }
            }
            
            // Scheduling batch call to create vendors data
            Sustain_CreateVendorRecordBatch nextcustBatch = new Sustain_CreateVendorRecordBatch(1);
            database.executeBatch(nextcustBatch, 1000);
            
            //creating fields on target objects
            //createSourceRecordIDFields(UserInfo.getSessionId());
        }
        catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
    }
    
    public static void createCustObjMappingforMngPckgDependentFieldsforSpecific(List<Object_Mappings__c> mappingList){
        string CurrentMethodName = 'createCustObjMappingforMngPckgDependentFieldsforSpecific';
        try{
            Map<String,Set<String>> fullMappingMap= allMappings();
            List<Field_Mappings__c> fieldMapList = new List<Field_Mappings__c>();
            List<Object_Mappings__c> objMapList = new List<Object_Mappings__c>(); 
            for(Object_Mappings__c objMap : mappingList){
                boolean updObjMapping=false;
                Map<String,Integer> trgtObjCountMap=new Map<String,Integer>();
                SObjectType obj = Schema.getGlobalDescribe().get(objMap.Source_Object__c);
                Schema.DescribeSObjectResult objDesc = obj.getDescribe();
                for(SObjectField aField : objDesc.fields.getMap().values()) {
                    Schema.DescribeFieldResult fieldDesc = aField.getDescribe();
                    if(Sustain_UtilConstants.castTypeToString(fieldDesc.getType()).equals(Sustain_UtilConstants.referenceLabel) && fieldDesc.isNamePointing()==false){
                        List<Schema.sObjectType> sobjType=fieldDesc.getReferenceTo();
                        Schema.DescribeSObjectResult res=sobjType[0].getDescribe();
                        if(res.getName().startsWith('sustain_app__') && fullMappingMap.containsKey(res.getName())){
                            updObjMapping=true;
                            for(String trgtObj : fullMappingMap.get(res.getName())){
                                Field_Mappings__c temp = new Field_Mappings__c();
                                temp.Source_Field_Label__c = fieldDesc.getLabel();
                                temp.Source_Field__c = fieldDesc.getName().removeStart('Migration_Util__');
                                temp.Reference_To__c = trgtObj.removeStart('Migration_Util__');
                                temp.Calculated__c =false;
                                temp.New_Field__c = true;
                                temp.Comments__c='New Field';
                                temp.Mapping_Included__c =true;
                                temp.Target_Field_Type__c ='Reference';
                                temp.Source_Field_Type__c='Reference';
                                temp.Object_Mapping__c=objMap.Id;
                                if(trgtObjCountMap.containsKey(trgtObj)){
                                    integer i=trgtObjCountMap.get(trgtObj);
                                    temp.Target_Field_Label__c = Schema.getGlobalDescribe().get(trgtObj).getDescribe().getLabel()+i;
                                    temp.Target_Field__c = trgtObj.removeStart('Migration_Util__')+i+'__c';
                                    i++;
                                    trgtObjCountMap.put(trgtObj,i);
                                }
                                else{
                                    temp.Target_Field_Label__c = Schema.getGlobalDescribe().get(trgtObj).getDescribe().getLabel();
                                    temp.Target_Field__c = trgtObj.removeStart('Migration_Util__')+'__c';
                                    trgtObjCountMap.put(trgtObj,1);
                                }
                                fieldMapList.add(temp);
                            }
                        } 
                    }
                }
                if(updObjMapping){
                    Object_Mappings__c objTemp=new Object_Mappings__c();
                    objTemp.Id=objMap.Id;
                    objTemp.Mapping_Included__c=true;
                    objTemp.Target_Object__c = objDesc.getName(); 
                    objTemp.Destination_Object_Label__c =objDesc.getLabel();
                    objMapList.add(objTemp);
                    //fieldMapList.addAll(addUtiltiyFieldMappingRecords(objMap.Id));
                }
            }
            if(fieldMapList.size()>0){
                Database.insert(fieldMapList);
            }
            if(objMapList.size()>0){
                Database.update(objMapList);
            }
        }
        catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
    }

    private static String getTargetObjectNameField(String objName){
        SObjectType sObj = Schema.getGlobalDescribe().get(objName);
        for (SObjectField aField : sObj.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDesc = aField.getDescribe();
            if(fieldDesc.isNameField() && !fieldDesc.isAutoNumber()){
                return fieldDesc.getLabel();
            }
        }
        return null;
    }
    public static Map<String,Set<String>> allMappings(){
        string CurrentMethodName = 'createGenericRecords';
        Map<String,Set<String>> srcTrgtListMap=new Map<String,Set<String>>();        
        try{
            for(Object_Mappings__c oMap: [SELECT Target_Object__c, Source_Object__c FROM Object_Mappings__c limit 100]){
                if(!srcTrgtListMap.containsKey(oMap.Source_Object__c)){
                    srcTrgtListMap.put(oMap.Source_Object__c, new Set<String>{oMap.Target_Object__c});
                }
                else{
                    srcTrgtListMap.get(oMap.Source_Object__c).add(oMap.Target_Object__c);    
                }
            }
            return srcTrgtListMap;
        }
        catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
            return null;
        }
    }

    @future
    public static void updateNoOfRecords(Set<ID> recordIds, Boolean isLastJob, List<String> emailaddresses){ 
        string CurrentMethodName = 'createGenericRecords';  
        try{
            List<Object_Mappings__c> objMaptobeUpdate = new List<Object_Mappings__c>();
            // Get those records based on the IDs
            for(Object_Mappings__c oMap:[select id,Source_Record_Type__c,Source_Object__c,Target_Object__c from Object_Mappings__c where ID IN: recordIds]){
                // Process records   
                String QueryString = 'SELECT count() FROM '+oMap.Source_Object__c;
                if(oMap.Source_Record_Type__c != null && oMap.Source_Record_Type__c != 'Master'){
                    QueryString = QueryString + ' where recordType.DeveloperName = \''+ oMap.Source_Record_Type__c + '\''; 
                } 
                oMap.Total_Records__c = String.valueOf(Database.countQuery(QueryString));
                System.debug(' temp.Total_Records__c'+ oMap.Total_Records__c);                                 
                objMaptobeUpdate.add(oMap);             
            }
    
            if(objMaptobeUpdate.size() > 0){
                update objMaptobeUpdate;
            }
            
            if(isLastJob){
                Migration_Status__c ms = Migration_Status__c.getInstance(UserInfo.getOrganizationId());
                if(ms==null){
                    ms = new Migration_Status__c();                              
                }
                ms.Current_Migration_Stage__c   = 'Org Data Scan Output'; 
                ms.Ready_To_Launch__c = false;
                ms.MetaData_Created__c = false;
                upsert ms;
            }           
            
            if(emailaddresses!= null & emailaddresses.size() >0){
                Sustain_SendNotification sendData =new Sustain_SendNotification();
                sendData.sendEmailNotification('Sustain_PackageInstallEmails',emailaddresses);   
                //sendData.sendChatterNotification('Sustain_PackageInstallEmails');
            }
        }  catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
        }
    }   
    
    /*@future(callout=true)
    public static void createSourceRecordIDFields(String sessionIDS){   
        try{
            Sustain_MigrateCustomFieldsController.createField( Sustain_UtilConstants.SCFirstCoreObjectNames, 'Source_Record_ID__c', 255, 'Text', 'Source Record ID', sessionIDS);
            Sustain_MigrateCustomFieldsController.createField( Sustain_UtilConstants.SCSecondCoreObjectNames, 'Source_Record_ID__c', 255, 'Text', 'Source Record ID', sessionIDS);
            Sustain_MigrateCustomFieldsController.createField( Sustain_UtilConstants.SCThirdCoreObjectNames, 'Source_Record_ID__c', 255, 'Text', 'Source Record ID', sessionIDS);
            Sustain_MigrateCustomFieldsController.createField( Sustain_UtilConstants.SCFourCoreObjectNames, 'Source_Record_ID__c', 255, 'Text', 'Source Record ID', sessionIDS);
        }  catch(Exception e){
            Sustain_UtilityError.createErrorLog(e);
        }
    } */           
}