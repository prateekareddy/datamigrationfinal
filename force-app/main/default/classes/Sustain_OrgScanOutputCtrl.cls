/***************************************************************************************************************
 * Name - Sustain_OrgScanOutputCtrl
 * Description - This class is used to scan the org and get org informations like number of objects, fields etc.
 * Author - Accenture (Bindhyachal)
 * Created Date - 8/22/2021
 * Last Modified By & Date - Accenture, 8/24/2021
 * ***************************************************************************************************************/

public with sharing class Sustain_OrgScanOutputCtrl{
    private static final string CurrentClassName = 'Sustain_OrgScanOutputCtrl';

    // Aura enables method to fetch org scan deatils and set wrapper to diplsay info on UI
    @AuraEnabled 
    public static OrgScanOutputWrapper fetchOrgScanDetails(){
        string CurrentMethodName = 'fetchOrgScanDetails';
        // Initialize variables for counters
        Integer scObject = 0;
        Integer cObject= 0;        
        Integer customFieldCount = 0;

        Boolean isValidObj = false;

        List<CustomObjectInfo> cObjectInfoList = new List<CustomObjectInfo>();
        
        Map<String, Integer> custFieldsPerObject = new Map<String, Integer>();

        try{
            Set<String> mwmSet = new Set<String>();

            // Getting list of all metadata (object and fields ) which are used in migration wizard app
            // create a set of metadata list
            for(Sustain_MigrationWizardMetaData__mdt mwm: [Select Id, DeveloperName, Sustain_MetaDataName__c from Sustain_MigrationWizardMetaData__mdt LIMIT 1000]){
                mwmSet.add(mwm.Sustain_MetaDataName__c);
            }
            
            Set<String> validObjectList = getAllReferenceCustomObject(mwmSet, custFieldsPerObject);

            // Iterate over SobjectType and get object name, fields details
            for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() ){
                Schema.DescribeSObjectResult objResult = o.getDescribe();                
                
                // Check whether object is from SC managed package or not excluding Feed, ChangeEvent, History and Share objects
                if(!objResult.getName().endsWith('__Feed') && !objResult.getName().endsWith('__History') && 
                     !objResult.getName().endsWith('__Share') && !objResult.getName().endsWith('__ChangeEvent') &&
                     !objResult.getName().endsWith('__mdt') && !mwmSet.contains(objResult.getName())){
                    if(objResult.getName().startsWith('sustain_app__')){
                        scObject = scObject + 1;    
                        isValidObj = true;                                 
                    }else if(objResult.getName().contains('__c') && !objResult.isCustomSetting() && validObjectList.contains(objResult.getName())){
                        cObject = cObject + 1;

                        customObjectInfo coi = new customObjectInfo();
                        coi.objLabel = objResult.getLabel();
                        coi.objName = objResult.getName();
                        cObjectInfoList.add(coi);
                        isValidObj = true;                        
                    }
                }
                //system.debug( 'Sobject Name: ' + objResult.getName() );

                // Check whether the object is relevant or not based on Object type. if object valid then set customfield count for an object
                if(isValidObj){
                    //custFieldsPerObject = countCustomFields(objResult, custFieldsPerObject, mwmSet);
                    if(custFieldsPerObject.get(objResult.getName()) != null ){           
                        customFieldCount = customFieldCount + custFieldsPerObject.get(objResult.getName());
                        //System.debug('custFieldsPerObject.get(objResult.getName()) custom'+ custFieldsPerObject.get(objResult.getName()));
                        //system.debug( 'Sobject API Name Custom: ' + objResult.getName() ); 
                    }
                    isValidObj = false;
                }
 
            }
        
            System.debug(' Custom Objects has fields '+custFieldsPerObject.size());
            
            System.debug('Custom Object = '+ cObject + 'Sustain '+ scObject );
            
            // Getting sustainability cloud package details like version number
            List<Publisher> scPackageDetails = [SELECT Id,MajorVersion, MinorVersion, Name, NamespacePrefix from Publisher where NamespacePrefix = 'sustain_app' limit 1];

            // Set all wrapper variables 
            OrgScanOutputWrapper oso = new OrgScanOutputWrapper ();
            oso.noOfSCObjects = scObject;
            oso.noOfCustomObjects = cObject;
            oso.coInfoList = cObjectInfoList;
            oso.noOfCustomFields = customFieldCount;
            oso.noOfObjectwithCustomFields = custFieldsPerObject.size(); 
            if(scPackageDetails.size() > 0){
                oso.packageVer = String.valueOf(scPackageDetails[0].MajorVersion)+ '.' + String.valueof(scPackageDetails[0].MinorVersion);  
            }else{
                oso.packageVer = null;
            }
            // return wrapper
            return oso;
        }catch(Exception ex){
            // Create error log records
            Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName); 
            return null;
        }
    }

    @AuraEnabled
    public static ListView getListViews() {
        ListView listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Migration_Util__Vendor__c' and NAME = 'All Vendors' limit 1];

        // Perform isAccessible() check here
        return listviews;
    }

    /*
    @AuraEnabled 
    public static Boolean redirectToObjectMappings(String migStage){
        try{    
            Migration_Status__c ms = Migration_Status__c.getOrgDefaults();
            ms.Current_Migration_Stage__c = migStage;
            update ms;
            return true;
        }catch(Exception ex){
            Sustain_UtilityError.createErrorLog(ex);
            return false;
        }        
    }*/

     // This method is used to count the number of custom fields for a given objects 
     /*private static Map<String, Integer> countCustomFields(Schema.DescribeSObjectResult objReslt, Map<String, Integer> custFieldsPerObject, Set<String> mwmetadata){
        Integer customFieldCount = 0;
        
        for (SObjectField aField : objReslt.fields.getMap().values()) {
            if (aField.getDescribe().isCustom() && !aField.getDescribe().getName().startsWith('sustain_app__') && !mwmetadata.contains(aField.getDescribe().getName())) {
                customFieldCount++;
            }
        }
        
        System.debug('customFieldCount '+customFieldCount);
        
        // if object has custom field then put into map otherwise skip that object from map
        if(customFieldCount > 0){
            custFieldsPerObject.put(objReslt.getName(), customFieldCount);
        }
        return custFieldsPerObject;
    }*/

    // This method is used to count the number of custom fields for a given objects 
    private static Set<String> getAllReferenceCustomObject(Set<String> mwmetadata, Map<String, Integer> customFieldsPerObject){
        Integer customFieldCount = 0;
       // Map<String, List<Schema.sObjectType>> objReferenceToMap = new Map<String, List<Schema.sObjectType>>();
        Set<String> objectSet = new Set<String>();
        List<Schema.sObjectType> sobjType;
        //Set<String> sObjectType;

        for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() ){
            Schema.DescribeSObjectResult objResult = o.getDescribe();   
            if(!mwmetadata.contains(objResult.getName()) && !objResult.getName().endsWith('__Feed') && !objResult.getName().endsWith('__History') && 
                !objResult.getName().endsWith('__Share') && !objResult.getName().endsWith('__ChangeEvent') && !objResult.getName().endsWith('__mdt') && 
                !objResult.isCustomSetting() ){
                sobjType = new List<Schema.sObjectType>();
                customFieldCount = 0;
                for (SObjectField aField : objResult.fields.getMap().values()) {
                    if(Sustain_UtilConstants.castTypeToString(aField.getDescribe().getType()).equals(Sustain_UtilConstants.referenceLabel) && 
                        aField.getDescribe().isNamePointing()==false &&
                        aField.getDescribe().isCustom() ){                        
                        //sobjType.addAll(aField.getDescribe().getReferenceTo());
                        sobjType = aField.getDescribe().getReferenceTo();                         
                        //System.debug('sObjType '+ sobjType + 'objectName '+objResult.getName()); 
                        if(objResult.getName().startsWith('sustain_app__')  && String.valueOf(sobjType[0]).contains('__c') && !String.valueOf(sobjType[0]).startsWith('sustain_app__')){
                            objectSet.add(string.valueOf(sobjType[0]));
                        }else if(String.valueOf(sobjType[0]).startsWith('sustain_app__')  && objResult.getName().contains('__c') && !objResult.getName().startsWith('sustain_app__')){
                            objectSet.add(objResult.getName());
                        }                       
                    }
                    if (aField.getDescribe().isCustom() && !aField.getDescribe().getName().startsWith('sustain_app__') && 
                        !mwmetadata.contains(aField.getDescribe().getName().removeStart('Migration_Util__'))) {
                        customFieldCount++;
                    }                
                }           

                /*for(Schema.sObjectType refObj: sobjType){
                    if(objResult.getName().startsWith('sustain_app__')  && String.valueOf(refObj).contains('__c') && !String.valueOf(refObj).startsWith('sustain_app__')){
                        objectSet.add(string.valueOf(refObj));
                    }else if(String.valueOf(refObj).startsWith('sustain_app__')  && objResult.getName().contains('__c') && !objResult.getName().startsWith('sustain_app__')){
                        objectSet.add(objResult.getName());
                    }
                } */

                // if object has custom field then put into map otherwise skip that object from map
                if(customFieldCount > 0 && (objResult.getName().startsWith('sustain_app__') || objectSet.contains(objResult.getName()))){
                    customFieldsPerObject.put(objResult.getName(), customFieldCount);     
                    //System.debug('customFieldsPerObject.get(objResult.getName()) custom'+ customFieldsPerObject.get(objResult.getName()) + 'objResult.getName() '+ objResult.getName());
                }
            }
        }
        System.debug('objectSet '+objectSet);
        return objectSet;
    }
}