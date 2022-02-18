/***************************************************************************************************************
* Name - Sustain_Utils 
* Description - This class is used as Utility class for this application. All untilty methods need be define here
* Author - Accenture (Arup)
* Created Date - 09/06/2021
* Last Modified By & Date - Accenture, 09/06/2021
* ***************************************************************************************************************/
public without sharing class Sustain_Utils {
    public Sustain_Utils(){}
    private static final string MASTER_RECORD_TYPE = 'Master';
    private static final string ASSET_API_NAME = 'sustain_app__Asset__c';
    private static final string EMISSIONFACTOROTHER = 'sustain_app__EmissionFactorOther__c';
    private static map<string, list<Sustain_FuelTypeInformation__mdt>> unitMap = new map<string, list<Sustain_FuelTypeInformation__mdt>>();
    private static map<string, String> targetFieldMap = new map<string, String>();
    private static final string ASSET_Contact_API_NAME = 'sustain_app__Contact__c';
    private static final string SUPPLIER_API_NAME = 'sustain_app__ServiceProvider__c';
    private static final string VENDOR_API_NAME = 'Vendor__c';
    private static final string DataCenterRecordTypeAPI='Data_Center_Facility';
    private static final string EXTRAPOLATION_STATUS='sustain_app__Extrapolation_Status__c';
    private static final string STAGE='sustain_app__Stage__c';
    private static final string CONSUMPTIONREPORT = 'sustain_app__ConsumptionReport__c';
    private static final string Scope3ProcurementSummAPI='Scope3PcmtSummary';
    private static final string Scope3PrntIdFieldAPI='Scope3CrbnFtprntId';
    private static final string EnergyUseObjAPI='sustain_app__EnergyConsumption__c';
    private static final string VehicleAssetEnergyUseObjAPI='VehicleAssetEnrgyUse';
    private static final string RentalCarEnergyUseObjAPI = 'RentalCarEnrgyUse';
    private static final string CurrentClassName = 'Sustain_Utils';
    private static final string EmissionFactorScope3API = 'sustain_app__EmissionFactorScope3__c';

    static List<String> carbonFootPrintIdList=new List<String>();


    private static map<string,list<String>> assetTargetObjAPIName = new map<string,list<String>>() ;
    
    private static map<string, Sustain_PicklistMigration__mdt> picklistTransfrmList = new map<String,Sustain_PicklistMigration__mdt>();
    private static map<string, Sustain_PicklistMigration__mdt> transfromPickListVals = new map<String,Sustain_PicklistMigration__mdt>();
    static {
        assetTargetObjAPIName.put('StnryAssetEnvrSrc',new list<String>{'RefrigerantEmssnFctrId','OtherEmssnFctrId','ElectricityEmssnFctrId'});
        assetTargetObjAPIName.put('VehicleAssetEmssnSrc',new list<String>{'OtherEmssnFctrId'});
        assetTargetObjAPIName.put('Scope3EmssnSrc',new list<String>{'RentalCarEmssnFctrId','HotelStayEmssnFctrId','GroundTravelEmssnFctrId','FrgtHaulingEmssnFctrId','AirTravelEmssnFctrId'});
        targetFieldMap.put('CH4','Ch4EmissionFactorUnit');
        targetFieldMap.put('CO2','Co2EmissionFactorUnit');
        targetFieldMap.put('N2O','N2oEmissionFactorUnit');
        picklistTransfrmList = Sustain_UtilConstants.getPickListTrnsfrmMdt();
        transfromPickListVals = Sustain_UtilConstants.gettransfromPickListValsMdt();
    }
    
    static List<String> eimissionFactorFldList = new List<String>{'sustain_app__ElectricityEmissionFactor__c','sustain_app__EmissionFactorOther__c','sustain_app__EmissionFactorScope3Dataset__c','sustain_app__EmissionFactorScope3__c','sustain_app__EmissionFactorScope3__c','sustain_app__EmissionFactorScope3__c'};
    
    private static Set<String> errorSourceRecordIds = new Set<String>();
    private static List<Sobject> errorSourceRecordList = new List<Sobject>();
      
    public static  SustainUtilWrapper createGenericRecords(List<sObject> srcRecords,List<Field_Mappings__c> fldList){
        List<SObject> recordToBeInserted = new List<SObject>();
        errorSourceRecordIds = new Set<String>();
        errorSourceRecordList = new List<Sobject>();

        string CurrentMethodName = 'createGenericRecords';
        SustainUtilWrapper finalWrapper = new SustainUtilWrapper();
        List<String> assetContactIdList = new List<String>();
        List<String> supplierIdList = new List<String>();
        List<String> vendorIdList = new List<String>();
        set<String> vendorNameSet = new Set<String>();
        Map<String,String> cfEnergyUseMap = new Map<String,String>();
        Map<String, ID> supplierIdMap = new Map<String, ID>();

        try{
            String trgtObject=fldList[0].Object_Mapping__r.Target_Object__c;
            string trgtRecordtype=fldList[0].Object_Mapping__r.Target_Record_Type__c;
            string srcOj=fldList[0].Object_Mapping__r.Source_object__c;
            string sourceRcdType= fldList[0].Object_Mapping__r.Source_Record_Type__c;
            list<Field_Mappings__c> emissionFld = new list<Field_Mappings__c>();
            system.debug('createGenericRecords:trgtObject----->' + trgtObject);
            system.debug('createGenericRecords:trgtRecordtype----->' + trgtRecordtype);
            system.debug('createGenericRecords:srcOj----->' + srcOj);
            system.debug('createGenericRecords:srcRecords---->' + srcRecords.size());
            if(srcOj.equals(EnergyUseObjAPI)){
                List<sustain_app__ConsumptionReportItem__c> CFItemList = [Select Id, Name,sustain_app__ConsumptionReport__r.Target_SFDC_ID__c, sustain_app__EnergyConsumption__c from sustain_app__ConsumptionReportItem__c where sustain_app__EnergyConsumption__c IN:srcRecords];
                for(sustain_app__ConsumptionReportItem__c cfi: CFItemList){
                    cfEnergyUseMap.put(cfi.sustain_app__EnergyConsumption__c, cfi.sustain_app__ConsumptionReport__r.Target_SFDC_ID__c);
                }
                
                if( trgtObject != 'StnryAssetEnrgyUse'){
                    for(sustain_app__EnergyConsumption__c energyUse: [SELECT id, sustain_app__VendorName__c from sustain_app__EnergyConsumption__c where sustain_app__VendorName__c != null AND ID IN:srcRecords ]){
                        vendorNameSet.add(energyUse.sustain_app__VendorName__c);
                    }
                    String supSoql = 'Select Id, Name from Supplier where Name IN: vendorNameSet';
                    for(Sobject sup: database.query(supSoql)){
                        supplierIdMap.put((string)sup.get('Name'), (id)sup.get('Id'));
                    }
                }
            }
            for(sObject cf: srcRecords){                   
                //System.debug('fldList[0].Object_Mapping__r.Source_Record_Type__c------>' + fldList[0].Object_Mapping__r.Source_Record_Type__c);

                String recordTypeName = fldList[0].Object_Mapping__r.Source_Record_Type__c != null && fldList[0].Object_Mapping__r.Source_Record_Type__c != '' && fldList[0].Object_Mapping__r.Source_Record_Type__c !='Master' ? Schema.getGlobalDescribe().get(srcOj).getDescribe().getRecordTypeInfosById().get((String)cf.get('RecordTypeId')).getDeveloperName() : '';
                //system.debug('createGenericRecords:recordTypeName-->' + recordTypeName);
                if(String.isBlank(recordTypeName) || recordTypeName == fldList[0].Object_Mapping__r.Source_Record_Type__c ) {
                    SObject obj = Schema.getGlobalDescribe().get(trgtObject).newSObject();                            
                    for(Field_Mappings__c fMapping : fldList){
                        //system.debug('createGenericRecords:trgtObject---->1 ' + fMapping.Object_Mapping__r.Target_Object__c);
                        //system.debug('createGenericRecords:trgtRecordtype---->1 ' + fMapping.Object_Mapping__r.Target_Record_Type__c);
                        //system.debug('createGenericRecords:srcOj---->1 ' + fMapping.Object_Mapping__r.Source_object__c);                               
                        if((!fMapping.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.lookupLabel) 
                                && !fMapping.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.referenceLabel) 
                                && !fMapping.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.masterDetailLabel)) || 
                                (!fMapping.Source_Field__c.contains('sustain_app__') && !fMapping.Reference_To__c.contains('sustain_app__')
                                && (fMapping.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.lookupLabel) 
                                    || fMapping.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.referenceLabel) 
                                    || fMapping.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.masterDetailLabel)))){                    
                                        if(fMapping.source_Field__c=='Name' && Sustain_UtilConstants.MIGRATION_DATA_OBJECTS.contains(fMapping.Object_Mapping__r.source_Object__c) && 
                                                fMapping.Object_Mapping__r.Source_Object__c+fMapping.Object_Mapping__r.source_Record_Type__c  != 'sustain_app__BuildingEnergyIntensity__cCommercialBuilding' ){
                                            obj.put(fMapping.Target_Field__c, ((String)cf.get(fMapping.Source_Field__c)+ '_Migrated'));                                                    
                                        } else {
                                            if((!(fldList[0].Object_Mapping__r.Target_Object__c == 'Contact' && fMapping.source_Field__c=='Name')) && 
                                                fMapping.source_Field__c != 'sustain_app__VendorName__c') {                                         
                                                obj.put(fMapping.Target_Field__c,cf.get(fMapping.Source_Field__c) );
                                            } else if(fldList[0].Object_Mapping__r.Target_Object__c == 'Contact' && fMapping.source_Field__c=='Name') {
                                                obj.put('lastname',cf.get(fMapping.Source_Field__c) );
                                            }else if(fldList[0].Object_Mapping__r.Source_Object__c == 'sustain_app__EnergyConsumption__c' && fMapping.source_Field__c=='sustain_app__VendorName__c' && 
                                                cf.get(fMapping.Source_Field__c) != null && supplierIdMap.get((string)cf.get(fMapping.Source_Field__c)) != null){
                                                obj.put(fMapping.Target_Field__c,supplierIdMap.get((string)cf.get(fMapping.Source_Field__c)));
                                            }
                                        }
                                    }
                            else{
                                obj=addRelationShipField(cf,fMapping,trgtObject,obj);
                            }
                        /* }else if(eimissionFactorFldList.contains(fMapping.source_Field__c)) {
                            emissionFld.add(fMapping);
                        }*/
                        if(CONSUMPTIONREPORT == cf.getSObjectType().getDescribe().getName()) {
                            if((fMapping.Source_Field__c.contains(EXTRAPOLATION_STATUS) || fMapping.Source_Field__c.contains(STAGE)) && cf.get(fMapping.Source_Field__c)!=null && picklistTransfrmList.containskey((String)cf.get(fMapping.Source_Field__c))) {
                                obj.put(fMapping.Target_Field__c, picklistTransfrmList.get((String)cf.get(fMapping.Source_Field__c)).Sustain_Target_Value__c);
                            } 
                        }
                        if(fMapping.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.Picklistabel)) {
                            String str = fMapping.Object_Mapping__r.Target_Object__c+fMapping.Source_Field__c;
                            str+=fMapping.Object_Mapping__r.Source_Record_Type__c !=Sustain_UtilConstants.masterLabel ? fMapping.Object_Mapping__r.Source_Record_Type__c : '' ;
                            str+= (String)cf.get(fMapping.Source_Field__c);
                            //System.debug('key is '+str);
                            if(transfromPickListVals.containskey(str)) {
                            obj.put(fMapping.Target_Field__c, transfromPickListVals.get(str).Sustain_Target_Value__c);

                            }                               
                        }
                    }
                    if(srcOj.equals(EnergyUseObjAPI)){
                        if(cfEnergyUseMap != null && cfEnergyUseMap.get(cf.Id) != null){
                            if(trgtObject.equals(VehicleAssetEnergyUseObjAPI)){
                                obj.put('VehicleAssetCrbnFtprntId', cfEnergyUseMap.get(cf.Id));                                        
                            }
                            else{
                                obj.put('Scope3CrbnFtprntId', cfEnergyUseMap.get(cf.Id));
                            }                                    
                        }
                        if(trgtObject.equals(VehicleAssetEnergyUseObjAPI) && sourceRcdType.equals('Private_Jet')){ 
                            Obj.put('FuelType','JetFuel');
                            if(cf.get('sustain_app__Annual_Fuel_Used_Value__c') == null){
                                Obj.put('FuelConsumption',0);
                            }                                    
                        }else if(trgtObject.equals(RentalCarEnergyUseObjAPI)){
                            Obj.put('FuelType','Gasoline');                                     
                        }
                    }

                    obj.put('Source_Record_ID__c' , cf.id);
                    if(String.isNotBlank(trgtRecordtype) && !Sustain_UtilConstants.masterLabel.equalsIgnoreCase(trgtRecordtype)){
                        try {
                            obj.put('RecordTypeId', Schema.getGlobalDescribe().get(trgtObject).getDescribe().getRecordTypeInfosByDeveloperName().get(trgtRecordtype).getRecordTypeId());
                        } catch(exception e) {
                            obj.put('RecordTypeId', Schema.getGlobalDescribe().get(trgtObject).getDescribe().getRecordTypeInfosByName().get(trgtRecordtype).getRecordTypeId());
                        }
                    }
                        
                    String objAPI=cf.getSObjectType().getDescribe().getName();
                    
                    System.debug('OBJAPI '+objAPI.removeStart(Label.Sustain_Name_Space_Prefix));

                    if(ASSET_API_NAME == objAPI) {
                        for(String key : assetTargetObjAPIName.keyset()) {
                            if(key.equalsIgnoreCase(trgtObject)) {
                                for(String fldName :  assetTargetObjAPIName.get(key)) {
                                    obj.put(fldName, Default_Emission_Factors__c.getValues(fldName).Factor_Value__c);
                                }
                            }
                        }            

                        string emissionRcdSql = '';
                        if(emissionFld.size()>0) {
                            emissionRcdSql = 'SELECT id,';
                            for(Field_Mappings__c str : emissionFld) {
                                emissionRcdSql += str.source_Field__c + ',';
                                emissionRcdSql+= str.Source_Field__c.remove('__c')+'__r.Target_SFDC_ID__c,' ;
                            }
                            
                            emissionRcdSql = emissionRcdSql.removeEnd(',');
                            emissionRcdSql = ' from sustain_app__EnergyConsumption__c where id =:cf.id';
                            for(Field_Mappings__c str : emissionFld) {
                                emissionRcdSql += ' and '+str.source_Field__c + ' !=null';
                            }  
                            list<sustain_app__EnergyConsumption__c>  rcrds = database.query(emissionRcdSql);
                            if(rcrds != null && rcrds.size()>0) {
                                sustain_app__EnergyConsumption__c rcrd = rcrds[0];
                                for(Field_Mappings__c str : emissionFld) {
                                    obj=addRelationShipField(rcrd,str,trgtObject,obj);
                                }
                            }                      
                        }
                    } else if(ASSET_Contact_API_NAME.equals(objAPI)){
                        assetContactIdList.add(cf.id);
                    }else if(SUPPLIER_API_NAME.equals(objAPI) && trgtObject.equals('Supplier')){
                        supplierIdList.add(cf.id);
                    } else if(VENDOR_API_NAME.equals(objAPI.removeStart(Label.Sustain_Name_Space_Prefix)) && trgtObject.equals('Supplier')){
                        vendorIdList.add(cf.id);
                    } else if(EmissionFactorScope3API.equals(objAPI) && trgtObject.equals('FrgtHaulingEmssnFctr') && 
                        (cf.get('sustain_app__Emission_Factors_Other__c') == null || cf.get('sustain_app__Emission_Factors_Other__c') == '')){
                        obj.put('OtherEmssnFctrId' , Default_Emission_Factors__c.getValues('OtherEmssnFctrId').Factor_Value__c ); 
                    }
                    if(!errorSourceRecordIds.contains((string)obj.get('Source_Record_Id__c'))){
                        recordToBeInserted.add(obj); 
                    }                                                       
                }
            }
            if(trgtObject.equals(Scope3ProcurementSummAPI)){
                System.debug('carbonFootPrintIdList '+carbonFootPrintIdList);
                Map<String,String> footPrintIdScope3EmssnIdMap=getFootPrintIdScope3EmssnIdMap(carbonFootPrintIdList);
                for(Sobject sobj : recordToBeInserted){
                    if(footPrintIdScope3EmssnIdMap.containsKey((String)sobj.get(Scope3PrntIdFieldAPI))){
                        sobj.put('Scope3EmssnSrcId',footPrintIdScope3EmssnIdMap.get((string)sobj.get(Scope3PrntIdFieldAPI)));
                    }
                }
            } 
                    
            if(assetContactIdList.size()>0){
                addAccountField(assetContactIdList, null, recordToBeInserted);
            }

            if(supplierIdList.size()>0){
                addAccountField(null, supplierIdList, recordToBeInserted);
            }
            
            if(vendorIdList.size()>0){
                addAccountIDField(vendorIdList, recordToBeInserted);
            }
            List<Database.SaveResult> results = new List<Database.SaveResult>();
            SYSTEM.debug('createGenericRecords:recordToBeInserted---->' +trgtObject + ' : '+  + srcOj + '  :  ' +recordToBeInserted.size());
            if(recordToBeInserted.size()>0){
                results = Database.insert(recordToBeInserted, false);
            }
            finalWrapper = updateErrorResult(recordToBeInserted,results);                                          
        }catch(Exception e){
            system.debug('createGenericRecords: Error-->'  + e);                
            updateExceptionDetail(srcRecords,e);                
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
        }             
        return finalWrapper;
    }

    public static SustainUtilWrapper createEnergyUseandItemRecords(List<sObject> srcRecords,List<Field_Mappings__c> fldList){
        SustainUtilWrapper finalWrapper = new SustainUtilWrapper();
        string CurrentMethodName = 'createEnergyUseandItemRecords';       
        List<SObject> recordToBeInserted = new List<SObject>();
        List<SObject> recordToBeInsertedItem = new List<SObject>();
        errorSourceRecordIds = new Set<String>();
        errorSourceRecordList = new List<Sobject>();
        
        Map<String, sustain_app__ConsumptionReportItem__c> cfEnergyUseMap = new Map<String,sustain_app__ConsumptionReportItem__c>();        
       
        try{            
            List<sustain_app__ConsumptionReportItem__c> CFItemList = [Select Id, Name,sustain_app__ConsumptionReport__r.sustain_app__Total_Steam_consumption_kWh__c,sustain_app__ConsumptionReport__r.sustain_app__Total_Propane_consumption_kWh__c,sustain_app__ConsumptionReport__r.sustain_app__Total_Natural_Gas_consumption_kWh__c,
            sustain_app__ConsumptionReport__r.sustain_app__Total_Heat_consumption_kWh__c,sustain_app__ConsumptionReport__r.sustain_app__Total_Fuel_Oil_consumption_kWh__c,sustain_app__ConsumptionReport__r.sustain_app__Total_Electricity_Consumption_kWh__c,sustain_app__ConsumptionReport__r.sustain_app__Total_Diesel_Consumption_kWh__c,
            sustain_app__ConsumptionReport__r.sustain_app__Total_Cooling_consumption_kWh__c,sustain_app__ConsumptionReport__r.Target_SFDC_ID__c, sustain_app__EnergyConsumption__c from sustain_app__ConsumptionReportItem__c where sustain_app__EnergyConsumption__c IN:srcRecords];
            for(sustain_app__ConsumptionReportItem__c cfi: CFItemList){
                cfEnergyUseMap.put(cfi.sustain_app__EnergyConsumption__c, cfi);                
            }
            System.debug('cfEnergyUseMap '+cfEnergyUseMap);
           
            String trgtObject=fldList[0].Object_Mapping__r.Target_Object__c;
            string trgtRecordtype=fldList[0].Object_Mapping__r.Target_Record_Type__c;
            string srcRecordtype=fldList[0].Object_Mapping__r.Source_Record_Type__c;
            system.debug('trgtObject-->'+trgtObject);
            system.debug('trgtRecordtype-->'+trgtRecordtype); 
            system.debug('srcRecordtype-->'+srcRecordtype);
            List<Field_Mappings__c> effectedFieldMappingList=new List<Field_Mappings__c>();
            List<Field_Mappings__c> notEffectedFieldMappingList=new List<Field_Mappings__c>();
            Map<String,Sustain_FuelTypeInformation__mdt> fieldFuelTypemap=Sustain_UtilConstants.getFuelTypeConsumptionMdt(fldList[0].Object_Mapping__r.Source_Object__c);
            Set<String> fieldList=new Set<String>();
            
            for(Sustain_FuelTypeInformation__mdt mdt : fieldFuelTypemap.values()){
                fieldList.add(mdt.Field_Unit__c);
                fieldList.add(mdt.Field_Name__c);
            }
            System.debug('fieldList '+fieldList);
            System.debug('fldList '+fldList + 'Size '+fldList.size());
            for(Field_Mappings__c fMapping : fldList){                
                if(fieldList.contains(fMapping.Source_Field__c)){  
                    if(fieldFuelTypemap.containskey(fMapping.Source_Field__c)) {
                        effectedFieldMappingList.add(fMapping);                            
                    }
                } else {
                    notEffectedFieldMappingList.add(fMapping);
                    
                }
            }
            
            for(sObject cf: srcRecords){                
                String recordTypeName = fldList[0].Object_Mapping__r.source_Record_Type__c != '' && fldList[0].Object_Mapping__r.source_Record_Type__c !='Master' ? 
                    Schema.getGlobalDescribe().get(fldList[0].Object_Mapping__r.source_Object__c).getDescribe().getRecordTypeInfosById().get((String)cf.get('RecordTypeId')).getDeveloperName() : '';
                if(String.isBlank(recordTypeName) || recordTypeName == fldList[0].Object_Mapping__r.source_Record_Type__c) {                    
                    boolean firstValue = true;
                    for(Field_Mappings__c fMapping : effectedFieldMappingList){
                        //'fMapping.Source_Field__c '+fMapping.Source_Field__c);
                        if(fieldFuelTypemap.containsKey(fMapping.Source_Field__c) && cf.get(fMapping.Source_Field__c) != null){
                           SObject sObj=Schema.getGlobalDescribe().get(trgtObject).newSObject();  
                            sObj.put('Source_Record_ID__c' , cf.id);     
                            Sustain_FuelTypeInformation__mdt mdt=fieldFuelTypemap.get(fMapping.Source_Field__c);                        
                            for(Field_Mappings__c fmap : notEffectedFieldMappingList){
                                //System.debug('fieldList.contains(fMapping.Source_Field__c) '+fieldList.contains(fmap.Source_Field__c));                                                                       
                                if((!fmap.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.lookupLabel) && !fmap.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.referenceLabel) && !fmap.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.masterDetailLabel)) || 
                                    (!fmap.Source_Field__c.contains('sustain_app__') && (fmap.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.lookupLabel) || fmap.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.referenceLabel) || fMapping.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.masterDetailLabel)))){                    
                                        if(mdt.Fuel_Type__c != 'Electricity' && fmap.Target_Field__c.equals('AllocatedRenewableEnergyInKwh')){
                                            sObj.put(fmap.Target_Field__c, 0 );    
                                        }else{   
                                            sObj.put(fmap.Target_Field__c,cf.get(fmap.Source_Field__c) );
                                        }
                                    }
                                else{
                                    sObj=addRelationShipField(cf,fmap,trgtObject,sObj);
                                }                                
                            }
                            if(!firstValue) {
                                sObj.put('SuplScope1Emissions',null);
                                sObj.put('SuplScope2LocationBasedEmssn',null);
                                sObj.put('SuplScope2MarketBasedEmssn',null);
                            }
                            firstValue = false;                                 
                                
                            sObj.put('FuelConsumption',cf.get(fMapping.Source_Field__c));
                            sObj.put('FuelConsumptionUnit',cf.get(mdt.Field_Unit__c));
                            sObj.put('FuelType',mdt.Fuel_Type__c);
                                
                            sObj.put('Name',cf.get('Name') + ' - ' + mdt.Fuel_Type__c);
                            if(fMapping.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.Picklistabel)) {
                                String str = fMapping.Object_Mapping__r.Target_Object__c+fMapping.Source_Field__c;
                                str +=(fMapping.Object_Mapping__r.Source_Record_Type__c !=Sustain_UtilConstants.masterLabel) ? fMapping.Object_Mapping__r.Source_Record_Type__c : '' ;
                                str+= (String)cf.get(fMapping.Source_Field__c);
                                //System.debug('key is '+str);
                                if(transfromPickListVals.containskey(str)) {
                                    sobj.put(fMapping.Target_Field__c, transfromPickListVals.get(str).Sustain_Target_Value__c);
                                }                                
                            }
                            if(cfEnergyUseMap != null && cfEnergyUseMap.get(cf.Id) != null){
                                sObj.put('StnryAssetCrbnFtprntId', cfEnergyUseMap.get(cf.Id).sustain_app__ConsumptionReport__r.Target_SFDC_ID__c);
                            }
                                
                            if(!errorSourceRecordIds.contains((string)SObj.get('Source_Record_Id__c'))){
                                recordToBeInserted.add(sObj); 
                            }                            
                        }
                    }                                     
                }
            }
            
            List<Database.SaveResult> results = new List<Database.SaveResult>();
            List<Database.SaveResult> resultsItems = new List<Database.SaveResult>();
            SYSTEM.debug('createGenericRecords:recordToBeInserted---->' + trgtObject + ' : '+  + fldList[0].Object_Mapping__r.Source_object__c + '  :  ' +recordToBeInserted.size());
            
            if(recordToBeInserted.size()>0){               
                results = Database.insert(recordToBeInserted, false);
                finalWrapper = updateErrorResult(recordToBeInserted,results);                
            }   
            finalWrapper.listOfobject = recordToBeInserted;
        }catch(Exception e){
            system.debug('createEnergyUseandItemRecords: Error-->'  + e);
            updateExceptionDetail(srcRecords,e);
           
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
        return finalWrapper; 
    }

    public static void updateSourceObjectRecords(List<sObject> srcRecords,List<SObject> newCreatedRecords,String trgtObject){
        List<sObject> cfList=new List<sObject>();
        string CurrentMethodName = 'updateSourceObjectRecords';
        Map<String,String> nameIdMap=new Map<String,String>();
        try{
            String query='select id,Source_Record_ID__c from '+trgtObject+' where id IN :newCreatedRecords';
            List<sobject> newRecords=Database.query(query);
            for(SObject sObj :newRecords){
                nameIdMap.put((string)sObj.get('Source_Record_ID__c'),sObj.Id);
            }
            for(sObject cf: srcRecords){
                if(nameIdMap.containsKey((String)cf.get('Id'))){
                    String ids = String.isBlank((String)cf.get('Target_SFDC_ID__c')) ? nameIdMap.get((String)cf.get('Id')) : (cf.get('Target_SFDC_ID__c')  + ',' + nameIdMap.get((String)cf.get('Id')));
                    cf.put('Target_SFDC_ID__c', ids.removeStart(','));
                    if(cf.get('Error_Details__c') == null){
                        cf.put('Migration_Status__c','Completed');
                    }else{
                        cf.put('Migration_Status__c','Error Occurred');
                    }
                    cfList.add(cf);
                }
            }
            if(cfList.size()>0){
                Database.update(cfList,false);
            }
        }
        catch(Exception e){
            system.debug('updateSourceObjectRecords:error---->' + e);
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
    }
    
    public static  SustainUtilWrapper updateErrorResult(List<sObject> recordToBeInserted,List<Database.SaveResult> results){
        SustainUtilWrapper finalWrapper = new SustainUtilWrapper();
        string CurrentMethodName = 'updateErrorResult';
        map<string,SObject> updateResults = new map<string,SObject>();
        string temp1,temp2;
        set<string> resultList = new  set<string>();
        system.debug('recordToBeInserted-->' + recordToBeInserted);
        system.debug('results-->' + results.size());
        if(recordToBeInserted != null && recordToBeInserted.size() >0 && results != null) { 
            String  apiName = recordToBeInserted.get(0).getSObjectType().getDescribe().getName();
            // Iterate through each returned result
            list<string> ids =new list<string>();
            for(Integer i=0; i < results.size(); i++) {
                if(results.get(i).isSuccess()) {
                    temp1 ='Success';
                    ids.add(results.get(i).id);
                } 
                else if(!results.get(i).isSuccess()) {
                    String errorMsg = '';
                    for(Database.Error err : results.get(i).getErrors()) { 
                        //System.debug('The following error has occurred.');                        
                        errorMsg += err.getStatusCode() + ': ' + err.getMessage() +';'; 
                        System.debug(errorMsg);
                        System.debug('Account fields that affected this error: ' + err.getFields()); 
                    }
                    id rcdId = (Id)recordToBeInserted.get(i).get('Source_Record_ID__c');
                    
                    sobject objectName  =  rcdId.getSobjectType().newSObject(rcdId);
                    objectName.put('Id',rcdId);
                    objectName.put('Migration_Status__c','Error Occurred');
                    objectName.put('Error_Details__c',errorMsg);                    
                    resultList.add(rcdId);
                    updateResults.put(rcdId,objectName);                    
                    temp2 ='fail';
                }
            }
            if(ids.size()>0) {
                Map<String,SObject> idSObjectMap= new Map<String,SObject>();
                string sql = 'select id, Source_Record_ID__c from ' +apiName + '  where id in:ids' ;
                List<SObject> successList = (List<SObject>)Type.forName('List<' + apiName + '>').newInstance();
                successList = database.query(sql);
                
                if(successList !=null) {
                    List<String> srcIds = new List<String>();
                    String objName;
                    for(SObject obj : successList) {
                        id rcdId = (ID)obj.get('Source_Record_ID__c');
                        srcIds.add(rcdId);
                        if(String.isBlank(objName)){
                            objName=rcdId.getSobjectType().getDescribe().getName();
                        }
                    }
                    Map<String,String> srcTrgtMap=getTargetIds(srcIds,objName);

                    for(SObject obj : successList) {                      
                        id rcdId = (ID)obj.get('Source_Record_ID__c');
                        sobject objectName =  rcdId.getSobjectType().newSObject(rcdId);
                        system.debug('rcdId------------------------>' + rcdId);
                        objectName.put('Id',rcdId);
                        //System.debug('resultList.contains(rcdId) Out --> '+resultList.contains(rcdId));
                        if(!updateResults.containsKey(rcdId)){   
                            //System.debug('resultList.contains(rcdId)IN --> '+resultList.contains(rcdId));   
                            if(resultList.contains(rcdId)){
                                objectName.put('Migration_Status__c','Error Occurred');
                            }else{
                                objectName.put('Migration_Status__c','Completed');
                            }                             
                            String str  = srcTrgtMap.containsKey(rcdId) ? srcTrgtMap.get(rcdId) : '';
                            if(String.isNotBlank(str)) {
                                str+=','+obj.id;
                            } else {
                                str = obj.id;
                            }
                            str = str.removeStart(',').removeEnd(',');
                            //system.debug('After str----------->' + str);
                            objectName.put('Target_SFDC_ID__c',str);
                            
                            updateResults.put(rcdId,objectName);                           
                        }
                        else{
                            objectName=updateResults.get(rcdId);
                            String str  = (String)objectName.get('Target_SFDC_ID__c');
                            //system.debug('Before str----------->' + str);
                            if(String.isNotBlank(str)) {
                                str+=','+obj.id;
                            } else {
                                str = obj.id;
                            }
                            str = str.removeStart(',').removeEnd(',');
                            //system.debug('After str----------->' + str);
                            objectName.put('Target_SFDC_ID__c',str);
                            if(resultList.contains(rcdId)){
                                objectName.put('Migration_Status__c','Error Occurred');
                            }else{
                                objectName.put('Migration_Status__c','Completed');
                            }    
                            //system.debug('objectName-->' +  objectName);                            
                            updateResults.put(rcdId,objectName);                            
                        }
                    }
                }
            }
        }
        System.debug('errorSourceRecordList '+errorSourceRecordList);
        if(errorSourceRecordList != null && errorSourceRecordList.size() > 0){
            for(Sobject sob: errorSourceRecordList){
                sob.put('Id',sob.get('Id'));
                sob.put('Migration_Status__c','Error Occurred');
                sob.put('Error_Details__c','Atleast One of the Parent Record did not migrated');
                updateResults.put((string)sob.get('Id'),sob);
            } 
            temp2 ='fail';
        }
        system.debug('updateErrorResult:updateResults-->' + updateResults.values().size());
        
        if(updateResults.values().size()>0){
            try {
                System.debug('updateResults.values()------------------->' + updateResults.values());
                update updateResults.values();
            } catch(exception ex) {
                system.debug('updateResults:error-->'+ ex);
                Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName);
            }
        }
        if(temp2 == 'Fail'){
            finalWrapper.listOfobject = recordToBeInserted;
            finalWrapper.status = temp2;    
        }
        else if(temp1 == 'Success'){
            finalWrapper.listOfobject = recordToBeInserted;
            finalWrapper.status = temp1;                               
        } else if(String.isBlank(temp1) && String.isBlank(temp2)) {
            finalWrapper.status = 'Success';
        }
        system.debug('finalWrapper--> ' + finalWrapper);
        return finalWrapper;
    }

    // Method updateExceptionDetail added by Karan: To update the error details on the records which are failed to be inserted
    public static  void updateExceptionDetail(List<sObject> srcRecord, Exception ex){
        
        map<string,SObject> updateException = new map<string,SObject>();
        string ErrorDetails = ex.getMessage();
        string CurrentMethodName = 'updateExceptionDetail';
        
        system.debug('Exception-->' + ErrorDetails);
        if(srcRecord != null && ErrorDetails != null ){
            for (integer i=0; i<srcRecord.size(); i++){
                id rcdId = (Id)srcRecord.get(i).get('Id');
                    sobject objectName  =  rcdId.getSobjectType().newSObject(rcdId);
                    objectName.put('Id',rcdId);
                    objectName.put('Migration_Status__c','Error Occurred');
                    objectName.put('Error_Details__c',ErrorDetails);
                    updateException.put(rcdId,objectName);  
            }
            if(updateException.values().size()>0){
                try {
                    System.debug('updateException.values()------------------->' + updateException.values());
                    update updateException.values();
                } catch(exception e) {
                    system.debug('updateException:error-->'+ e);
                    Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
                }
            } 
        }
    }

    //--------------------------------------//
    public without sharing class SustainUtilWrapper{
        public SustainUtilWrapper(){}
        public List<sObject> listOfobject{get;set;}
        public string status{get;set;}
    }

    public static integer getSequebnceNo(Integer seqNo) {
        String sqlStr = '';
        list<Object_Mappings__c> objMappingList = new  list<Object_Mappings__c>();
        if(seqNo != null) {
            sqlStr = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c from Object_Mappings__c where Sequence_Number__c=:seqNo and Status__c = \'Not Started\' AND Object_Type__c != \'custom\' and mapping_included__c=true  order by sequence_number__c,Target_Object__c nulls last';
            objMappingList = Database.query(sqlStr);
            if(objMappingList != null && objMappingList.size()>0) {
                return seqNo;
            } else {            
                sqlStr = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c,Sequence_Number__c from Object_Mappings__c where Sequence_Number__c >: seqNo and Status__c != \'Completed\' AND Object_Type__c != \'custom\' and mapping_included__c=true  order by sequence_number__c,Target_Object__c nulls last limit 1';
                objMappingList = Database.query(sqlStr);
                return objMappingList != null && objMappingList.size() > 0 ? Integer.valueof(objMappingList[0].Sequence_Number__c) : null;
            }
        } else {
            sqlStr = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c,Sequence_Number__c from Object_Mappings__c where Status__c != \'Completed\' and Sequence_Number__c=null AND Object_Type__c = \'custom\' and mapping_included__c=true  order by sequence_number__c,Target_Object__c limit 1';
            objMappingList = Database.query(sqlStr);
            return objMappingList != null && objMappingList.size() > 0 ? Integer.valueof(objMappingList[0].Sequence_Number__c) : null;
        }
    }

    public static  SustainUtilWrapper createOtherEmissionChildRecords(List<sObject> scope,List<Field_Mappings__c> fldList){
        List<SObject> recordToBeInserted = new List<SObject>();
        string CurrentMethodName = 'createOtherEmissionChildRecords';
        SustainUtilWrapper finalWrapper = new SustainUtilWrapper();
        try{
            String trgtObject=fldList[0].Object_Mapping__r.Target_Object__c;
            string trgtRecordtype=fldList[0].Object_Mapping__r.Target_Record_Type__c;
            string srcOj=fldList[0].Object_Mapping__r.Source_object__c;
            system.debug('trgtObject-->' + trgtObject);
            Map<String,Sustain_FuelTypeInformation__mdt> fieldFuelTypemap=Sustain_UtilConstants.getFuelTypeConsumptionMdt(fldList[0].Object_Mapping__r.Source_Object__c);
            List<Field_Mappings__c> effectedFieldMappingList=new List<Field_Mappings__c>();
            system.debug(srcOj + ' scope----->' + scope.size());
            map<String, sustain_app__EmissionFactorOther__c> temObjs= new map<String, sustain_app__EmissionFactorOther__c>([select id,name,target_sfdc_id__c from sustain_app__EmissionFactorOther__c where id in :scope]);
            for(sObject cf : scope) {
                Map<String,sObject> fuelSObjectMap=new Map<String,sObject>();
                String recordTypeName = fldList[0].Object_Mapping__r.source_Record_Type__c != '' && fldList[0].Object_Mapping__r.source_Record_Type__c !='Master' ? 
                    Schema.getGlobalDescribe().get(fldList[0].Object_Mapping__r.source_Object__c).getDescribe().getRecordTypeInfosById().get((String)cf.get('RecordTypeId')).getDeveloperName() : '';
                system.debug('createOtherEmissionChildRecords:recordTypeName-->' + recordTypeName);
                if(String.isBlank(recordTypeName) || recordTypeName == fldList[0].Object_Mapping__r.source_Record_Type__c ) {
                    for(Field_Mappings__c fMapping : fldList){
                        //system.debug('fMapping----------------->' + fMapping);
                        if(fieldFuelTypemap.containsKey(fMapping.Source_Field__c) && cf.get(fMapping.Source_Field__c)!=null){                           
                            Sustain_FuelTypeInformation__mdt mdt=fieldFuelTypemap.get(fMapping.Source_Field__c);
                            //system.debug('Sustain_FuelTypeInformation__mdt-->'+mdt);
                            if(!fuelSObjectMap.containsKey(fieldFuelTypemap.get(fMapping.Source_Field__c).Fuel_Type__c)){  
                                SObject itmObj=Schema.getGlobalDescribe().get(trgtObject).newSObject();
                                if(fMapping.source_Field__c=='Name' && Sustain_UtilConstants.MIGRATION_DATA_OBJECTS.contains(fMapping.Object_Mapping__r.source_Object__c)) {
                                    itmObj.put(fMapping.Target_Field__c, ((String)cf.get(fMapping.Source_Field__c)+ '_Migrated'));
                                } else {
                                    itmObj.put(fMapping.Target_Field__c,cf.get(fMapping.Source_Field__c) );
                                }
                                if(srcOj == EMISSIONFACTOROTHER) {                                   
                                    itmObj.put('FuelType',mdt.Fuel_Type__c);                                    
                                }
                                itmObj.put('Source_Record_ID__c' , cf.id);
                                if(mdt.Fuel_Type__c != 'Cooling' && mdt.Fuel_Type__c != 'Heat'){
                                    if(fMapping.Source_Field__c.toLowerCase().contains('co2')) {
                                        itmObj.put(targetFieldMap.get('CO2'), mdt.Field_Unit__c);
                                        
                                    } else if(fMapping.Source_Field__c.toLowerCase().contains('n2o')) {
                                        itmObj.put(targetFieldMap.get('N2O'), mdt.Field_Unit__c);
                                        
                                    } else if(fMapping.Source_Field__c.toLowerCase().contains('ch4')) {
                                        itmObj.put(targetFieldMap.get('CH4'), mdt.Field_Unit__c);
                                    } 
                                }
                                if(fMapping.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.Picklistabel)) {
                                    String str = fMapping.Object_Mapping__r.Target_Object__c+fMapping.Source_Field__c;
                                    str+= (fMapping.Object_Mapping__r.Source_Record_Type__c !=Sustain_UtilConstants.masterLabel) ? fMapping.Object_Mapping__r.Source_Record_Type__c : '' ;
                                    str+= (String)cf.get(fMapping.Source_Field__c);
                                    System.debug('key is '+str);
                                    if(transfromPickListVals.containskey(str)) {
                                        itmObj.put(fMapping.Target_Field__c, transfromPickListVals.get(str).Sustain_Target_Value__c);
                                    }                                   
                                }
                                fuelSObjectMap.put(mdt.Fuel_Type__c,itmObj);
                            }
                            else{
                                SObject itmObj1=fuelSObjectMap.get(fieldFuelTypemap.get(fMapping.Source_Field__c).Fuel_Type__c);
                                itmObj1.put(fMapping.Target_Field__c,cf.get(fMapping.Source_Field__c));
                                if(mdt.Fuel_Type__c != 'Cooling' && mdt.Fuel_Type__c != 'Heat'){
                                    if(fMapping.Source_Field__c.toLowerCase().contains('co2')) {
                                        itmObj1.put(targetFieldMap.get('CO2'), mdt.Field_Unit__c);                                        
                                    } else if(fMapping.Source_Field__c.toLowerCase().contains('n2o')) {
                                        itmObj1.put(targetFieldMap.get('N2O'), mdt.Field_Unit__c);                                        
                                    } else if(fMapping.Source_Field__c.toLowerCase().contains('ch4')) {
                                        itmObj1.put(targetFieldMap.get('CH4'), mdt.Field_Unit__c);                                        
                                    }
                                }
                                fuelSObjectMap.put(mdt.Fuel_Type__c,itmObj1);
                            }                        
                            SObject itmObj2 = fuelSObjectMap.get(mdt.Fuel_Type__c);
                           
                            if(itmObj2 != null) {
                                if(srcOj == EMISSIONFACTOROTHER && mdt.Fuel_Type__c =='NaturalGas') {   
                                    if(mdt.Fuel_Type__c =='NaturalGas') {
                                        itmObj2.put('CalorificValue',cf.get('sustain_app__Natural_Gas_Cal_Conversion_kWh_m3__c'));
                                    }                                   
                                } 
                                //System.debug('cf.get(Target_SFDC_ID__c)-->' + temObjs.get((String)cf.get('id')).target_sfdc_id__c);
                                if(mdt.Fuel_Type__c == 'Cooling' || mdt.Fuel_Type__c == 'Heat'){
                                    itmObj2.put('SuppliedEmissionsFactorUnit',mdt.Field_Unit__c);
                                }else{
                                    itmObj2.put('SuppliedEmissionsFactorUnit','');    
                                }
                                itmObj2.put('ParentEmissionFactorId',temObjs.get((String)cf.get('id')).target_sfdc_id__c);
                                fuelSObjectMap.put(mdt.Fuel_Type__c,itmObj2);
                            }                           
                        }
                    }
                    
                    for(String fuelType: fuelSObjectMap.keySet()){
                        SObject itmObj3 = fuelSObjectMap.get(fuelType);
                        if(itmObj3.get('Ch4EmissionFactor') == null){
                            itmObj3.put(targetFieldMap.get('CH4'), '');   
                        }
                        if(itmObj3.get('Co2EmissionFactor') == null){
                            itmObj3.put(targetFieldMap.get('CO2'), '');   
                        }
                        if(itmObj3.get('N2oEmissionFactor') == null){
                            itmObj3.put(targetFieldMap.get('N2O'), '');   
                        }
                        fuelSObjectMap.put(fuelType,itmObj3);  
                    } 
                    
                    recordToBeInserted.addAll(fuelSObjectMap.values()); 
                }                
            }
            
            SYSTEM.debug('createOtherEmissionChildRecords:recordToBeInserted---->' + trgtObject + ' : '+  + fldList[0].Object_Mapping__r.Source_object__c + '  :  ' +recordToBeInserted.size());
            List<Database.SaveResult> results = new List<Database.SaveResult>();
            
            if(recordToBeInserted.size()>0){
                results = Database.insert(recordToBeInserted, false);
            }
            finalWrapper = updateErrorResult(recordToBeInserted,results);
        } catch(Exception e){
            system.debug('createOtherEmissionChildRecords: Error-->'  + e);
            updateExceptionDetail(scope,e);
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        } 
        return finalWrapper;
    }

    public static SustainUtilWrapper createBuildingEnergyIntensityValueRecords(List<sObject> srcRecords,List<Field_Mappings__c> fldList){
        SustainUtilWrapper finalWrapper = new SustainUtilWrapper();
        
        string CurrentMethodName = 'createBuildingEnergyIntensityValueRecords';
        
        List<SObject> recordToBeInserted = new List<SObject>();
        try{            
            map<String, sustain_app__BuildingEnergyIntensity__c> temObjs= new map<String, sustain_app__BuildingEnergyIntensity__c>([select id,name,target_sfdc_id__c from sustain_app__BuildingEnergyIntensity__c where id in :srcRecords]);
            Map<String,Sustain_FuelTypeInformation__mdt> fieldFuelTypemap=Sustain_UtilConstants.getFuelTypeConsumptionMdt('sustain_app__BuildingEnergyIntensity__c');
            for(sObject cf: srcRecords){               
                Map<String,sObject> fuelSObjectMap=new Map<String,sObject>();
                if(fldList != null && fldList.size()>0){
                    String recordTypeName = fldList[0].Object_Mapping__r.source_Record_Type__c != '' && fldList[0].Object_Mapping__r.source_Record_Type__c !='Master' ? 
                    Schema.getGlobalDescribe().get(fldList[0].Object_Mapping__r.source_Object__c).getDescribe().getRecordTypeInfosById().get((String)cf.get('RecordTypeId')).getDeveloperName() : '';
                    system.debug('createBuildingEnergyIntensityValueRecords:recordTypeName-->' + recordTypeName);
                    if(String.isBlank(recordTypeName) || recordTypeName == fldList[0].Object_Mapping__r.source_Record_Type__c ) {
                        for(Sustain_FuelTypeInformation__mdt fMapping : fieldFuelTypemap.values()){
                            if(cf.get(fMapping.Field_Name__c)!=null){
                                if(!fuelSObjectMap.containsKey(fMapping.Fuel_Type__c)){
                                    SObject itmObj=Schema.getGlobalDescribe().get('BldgEnrgyIntensityVal').newSObject();                                                          
                                    itmObj.put('FuelType',fMapping.Fuel_Type__c);
                                    itmObj.put('Source_Record_ID__c' , cf.id);
                                    for(Field_Mappings__c fMap : fldList){
                                        if(fMap.Source_Field__c.equals(fMapping.Field_Name__c)){
                                            itmObj.put(fmap.Target_Field__c,cf.get(fMapping.Field_Name__c));
                                        }
                                        if(fMap.Source_Field__c.startsWith('sustain_app__'+fMapping.Fuel_Type__c) && cf.get(fMap.Source_Field__c)!=null){
                                            itmObj.put(fmap.Target_Field__c,cf.get(fMap.Source_Field__c));
                                        }
                                    }
                                    String newSourceField=(String) temObjs?.get(cf.id).Target_SFDC_ID__c;
                                    String objName='BldgEnrgyIntensity';
                                    if(String.isnotblank(newSourceField) && newSourceField.contains(',')){
                                        List<Id> ids=newSourceField.split(',');
                                        for(Id tempId : ids){
                                            String objectName=tempId.getsobjecttype().getDescribe().getName();
                                            if(objectName.equals(objName)){
                                                //system.debug('tempId---->' + tempId);
                                                //system.debug('objName---->' + objName + ' : ' + objectName);
                                                itmObj.put('BuildingEnergyIntensityId',tempId);
                                                break;
                                            }
                                        }
                                    }
                                    else{
                                        if(String.isnotblank(newSourceField)){                    
                                            String objectName=((ID)newSourceField).getsobjecttype().getDescribe().getName();                   
                                            if(objectName.equals(objName)){
                                                //system.debug('newSourceField else---->' + newSourceField);
                                                //system.debug('objName else---->' + objName );
                                                itmObj.put('BuildingEnergyIntensityId',newSourceField);
                                            }
                                        }
                                        
                                    }                                    
                                    fuelSObjectMap.put(fMapping.Fuel_Type__c,itmObj);
                                    recordToBeInserted.add(itmObj);
                                }
                            }
                        }
                    }
                }               
            }
            SYSTEM.debug('createBuildingEnergyIntensityValueRecords:recordToBeInserted---->' +recordToBeInserted.size());
            SYSTEM.debug('createBuildingEnergyIntensityValueRecords:fieldFuelTypemap---->' +fieldFuelTypemap);
            List<Database.SaveResult> results = new List<Database.SaveResult>();
            if(recordToBeInserted.size()>0){
                results = Database.insert(recordToBeInserted, false);
            }            
            finalWrapper = updateErrorResult(recordToBeInserted,results);
        }
        catch(Exception e){
            system.debug('createBuildingEnergyIntensityValueRecords: Error-->'  + e);            
            updateExceptionDetail(srcRecords,e);
            
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
        return finalWrapper; 
    }

    @testVisible
    private static List<SObject> addAccountField(List<String> assetContactIdList, List<String> supplierIds, List<SObject> recordToBeInserted){
        Map<String,String> assetContactTargetIdMap =new Map<String,String>();
        String soqlStr = 'select sustain_app__Contact__c,sustain_app__Contact__r.Migration_Status__c, sustain_app__Contact__r.Error_Details__c,Target_SFDC_ID__c from sustain_app__ServiceProvider__c';
        if(assetContactIdList != null && assetContactIdList.size() > 0){
            soqlStr += ' where sustain_app__Contact__c IN : assetContactIdList order by Migration_Status__c DESC nulls last';
        }else if(supplierIds != null && supplierIds.size() > 0){
            soqlStr += ' where Id IN: supplierIds order by Migration_Status__c DESC nulls last';
        }
        
        Map<Id, Sobject> errorSourceRecordMap = new Map<Id, Sobject>();
        
        for(sustain_app__ServiceProvider__c sp : database.query(soqlStr)){
            String supplierOrAccID = '';

            if(String.isnotblank(sp.Target_SFDC_ID__c) && sp.Target_SFDC_ID__c.contains(',')){
                List<Id> ids=sp.Target_SFDC_ID__c.split(',');
                for(Id tempId : ids){
                    String objectName=tempId.getsobjecttype().getDescribe().getName();
                    if(objectName.equals('Account')){
                        system.debug('tempId---->' + tempId);                       
                        supplierOrAccID = tempId;
                        break;
                    }
                }
            }
            else{
                if(String.isnotblank(sp.Target_SFDC_ID__c)){                    
                    String objectName=((ID)sp.Target_SFDC_ID__c).getsobjecttype().getDescribe().getName();                   
                    if(objectName.equals('Account')){                        
                        system.debug('Target IDS else---->' + sp.Target_SFDC_ID__c );
                        supplierOrAccID = sp.Target_SFDC_ID__c;                        
                    }
                } else{
                    if(assetContactIdList != null && assetContactIdList.size() > 0 && assetContactTargetIdMap.get(sp.sustain_app__Contact__c) == null){
                        errorSourceRecordIds.add(sp.sustain_app__Contact__c);
                        errorSourceRecordMap.put(sp.sustain_app__Contact__c,sp.sustain_app__Contact__r);
                    }else if(supplierIds != null && supplierIds.size() > 0 && assetContactTargetIdMap.get(sp.Id) == null){
                        errorSourceRecordIds.add(sp.Id);
                        errorSourceRecordMap.put(sp.Id,sp);
                    }
                }               
            }
            if(assetContactIdList != null && assetContactIdList.size() > 0 && assetContactTargetIdMap.get(sp.sustain_app__Contact__c) == null && string.isNotBlank(supplierOrAccID)){
                assetContactTargetIdMap.put(sp.sustain_app__Contact__c,supplierOrAccID);
            }else if(supplierIds != null && supplierIds.size() > 0 && assetContactTargetIdMap.get(sp.Id) == null && string.isNotBlank(supplierOrAccID)){
                assetContactTargetIdMap.put(sp.Id,supplierOrAccID); 
            }                                  
        }

        if(errorSourceRecordIds.size() > 0){
            errorSourceRecordIds.removeAll(assetContactTargetIdMap.keySet());
        }
        System.debug('errorSourceRecordIds --->'+errorSourceRecordIds);

        for(Integer i = (recordToBeInserted.size()-1); i>=0; i--){
            if(assetContactTargetIdMap.containsKey((String)recordToBeInserted[i].get('Source_Record_ID__c')) ){
                recordToBeInserted[i].put('AccountId',assetContactTargetIdMap.get((String)recordToBeInserted[i].get('Source_Record_ID__c'))); 
                errorSourceRecordMap.remove((String)recordToBeInserted[i].get('Source_Record_ID__c'));              
            }else if(errorSourceRecordIds.contains((String)recordToBeInserted[i].get('Source_Record_ID__c'))){
                recordToBeInserted.remove(i);
            }
        }

        if(errorSourceRecordMap.size() > 0){
            errorSourceRecordList = errorSourceRecordMap.values();
        }
        return recordToBeInserted;
    }

    @testVisible
    private static List<SObject> addAccountIDField(List<String> vendorIdList, List<SObject> recordToBeInserted){
        Map<String,String> vendorAccountIdMap =new Map<String,String>();
        String soqlStr = 'select Id,Name,Vendor_Name__c,Target_SFDC_ID__c from Vendor__c where Id IN : vendorIdList';
            
        for(Vendor__c sp : database.query(soqlStr)){
            String accID = '';

            if(String.isnotblank(sp.Target_SFDC_ID__c) && sp.Target_SFDC_ID__c.contains(',')){
                List<Id> ids=sp.Target_SFDC_ID__c.split(',');
                for(Id tempId : ids){
                    String objectName=tempId.getsobjecttype().getDescribe().getName();
                    if(objectName.equals('Account')){
                        system.debug('tempId---->' + tempId);                       
                        accId = tempId;
                        break;
                    }
                }
            }
            else{
                if(String.isnotblank(sp.Target_SFDC_ID__c)){                    
                    String objectName=((ID)sp.Target_SFDC_ID__c).getsobjecttype().getDescribe().getName();                   
                    if(objectName.equals('Account')){                        
                        system.debug('Target IDS else---->' + sp.Target_SFDC_ID__c );
                        accId = sp.Target_SFDC_ID__c;                        
                    }
                } else{                    
                    errorSourceRecordList.add(sp); 
                }               
            }
            if(string.isNotBlank(accID)){
                vendorAccountIdMap.put(sp.Id,accId);
            }              
        }

        for(Integer i = (recordToBeInserted.size()-1); i>=0; i--){
            if(vendorAccountIdMap.containsKey((String)recordToBeInserted[i].get('Source_Record_ID__c'))){
                recordToBeInserted[i].put('AccountId',vendorAccountIdMap.get((String)recordToBeInserted[i].get('Source_Record_ID__c')));
            }else{
                recordToBeInserted.remove(i);
            }
        }
        return recordToBeInserted;
    }

    @testVisible
    private static Sobject addFieldforDataCenterRecordtype(sobject itmObj,sobject cf){
        for(sustain_app__ConsumptionReportItem__c item : cf.getSObjects('sustain_app__ConsumptionReportItems__r')){
            itmObj.put('Name',item.getSObject('sustain_app__ConsumptionReport__r').get('Name'));
            itmObj.put('SuplScope3UpstrmEmissions',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__Additional_Scope_3_Emissions__c'));
            itmObj.put('AllocationStatus',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__Allocation_Status__c'));
            itmObj.put('StnryAssetEnvrSrcIdId',item.getSObject('sustain_app__ConsumptionReport__r').getSObject('sustain_app__Asset__r').get('Target_SFDC_ID__c'));
            itmObj.put('AuditApprovalStatus',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__AuditApprovalStatus__c'));
            itmObj.put('BuildingEnergyIntensityId',item.getSObject('sustain_app__ConsumptionReport__r').getSObject('sustain_app__BuildingEnergyIntensity__r').get('Target_SFDC_ID__c'));
            itmObj.put('RegionalBuildingEnergyIntensityId',item.getSObject('sustain_app__ConsumptionReport__r').getSObject('sustain_app__CBECSIntensityRecord__r').get('Target_SFDC_ID__c'));
            itmObj.put('DataGapStatus',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__Extrapolation_Status__c'));
            itmObj.put('OccupiedFloorAreaUnit',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__Occupied_Building_Floor_Area_Unit__c'));
            itmObj.put('OccupiedFloorArea',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__Occupied_Building_Floor_Area__c'));
            itmObj.put('ReportingYearType',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__ReportBoundary__c'));
            itmObj.put('EndDate',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__ReportEndDate__c'));
            itmObj.put('ReportingYear',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__ReportingYear__c'));
            itmObj.put('ReportingDate',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__Reporting_Date__c'));
            itmObj.put('StartDate',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__ReportStartDate__c'));
            itmObj.put('FootprintStage',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__Stage__c'));
            itmObj.put('TotalFloorAreaUnit',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__TotalBuildingFloorAreaUnit__c'));
            itmObj.put('TotalFloorArea',item.getSObject('sustain_app__ConsumptionReport__r').get('sustain_app__TotalBuildingFloorArea__c'));
        }
        return itmObj;
    }
    @testVisible
    private static Sobject addRelationShipField(sobject cf,Field_Mappings__c fMapping,String trgtObject,SObject obj){
        String srcField=fMapping.Source_Field__c.remove('__c')+'__r';        
        SObject tempObj = cf.getSObject(srcField);
        if(tempObj != null) {
            String newSourceField=(String) tempObj.get('Target_SFDC_ID__c');
            List<Schema.sObjectType> sobjType=Schema.getGlobalDescribe().get(trgtObject).getDescribe().fields.getMap().get(fMapping.Target_Field__c).getDescribe().getReferenceTo();
            String objName=sobjType[0].getDescribe().getName();
            if(String.isnotblank(newSourceField) && newSourceField.contains(',')){
                List<Id> ids=newSourceField.split(',');
                for(Id tempId : ids){
                    String objectName=tempId.getsobjecttype().getDescribe().getName();
                    if(objectName.equals(objName)){                       
                        obj.put(fMapping.Target_Field__c,tempId);
                        if(fMapping.Target_Field__c.equals(Scope3PrntIdFieldAPI) && trgtObject.equals(Scope3ProcurementSummAPI)){                            
                            carbonFootPrintIdList.add(tempId);
                        }
                        break;
                    }
                }
            }
            else{
                if(String.isnotblank(newSourceField)){                    
                    String objectName=((ID)newSourceField).getsobjecttype().getDescribe().getName();                   
                    if(objectName.equals(objName)){                       
                        obj.put(fMapping.Target_Field__c,newSourceField);
                        if(fMapping.Target_Field__c.equals(Scope3PrntIdFieldAPI) && trgtObject.equals(Scope3ProcurementSummAPI)){                           
                            carbonFootPrintIdList.add(newSourceField);
                        }
                    }
                }else{
                    System.debug('Error ID '+cf.Id);
                    errorSourceRecordIds.add(cf.Id);
                    errorSourceRecordList.add(cf);
                }                
            }            
        }        
        return obj;
    }

    private static string getCustomLabelValByName(String name) {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        MetadataService.CustomLabel label = (MetadataService.CustomLabel) service.readMetadata('CustomLabel', new String[] { name }).getRecords()[0];//Label named 'X12345'
        return label.value;
    }

    @testVisible
    private static List<String> addToCarbonFootprintIdList(String printId){
        return (List<String>) carbonFootPrintIdList.add(printId);
    }

    @testVisible
    private static Map<String,String> getFootPrintIdScope3EmssnIdMap(List<String> carbonFootPrintIdList){
        Map<String,String> footPrintIdScope3EmssnIdMap = new Map<String,String>();
        if(carbonFootPrintIdList != null && !carbonFootPrintIdList.isEmpty()) {
            string sql = 'select id, Scope3EmssnSrcId from Scope3CrbnFtprnt where Id IN : carbonFootPrintIdList and Scope3EmssnSrcId!=null';
            for(Sobject sc : Database.query(sql)){
                footPrintIdScope3EmssnIdMap.put(sc.Id,(String)sc.get('Scope3EmssnSrcId'));
            }
        }
        return footPrintIdScope3EmssnIdMap;
    }

    @testVisible
    private static Map<String,String> getTargetIds(List<String> srcIds,String obj){
        Map<String,String> srcIdTargetIdMap = new Map<String,String>();
        system.debug('obj--------------------->'+obj);
        string query='select Id, Target_SFDC_ID__c from '+obj+' where id IN :srcIds';
        List<Sobject> sObjList=Database.query(query);
        for(Sobject s : sObjList){
            srcIdTargetIdMap.put((String)s.get('Id'),(String) s.get('Target_SFDC_ID__c'));
        }
        return srcIdTargetIdMap;
    }
}