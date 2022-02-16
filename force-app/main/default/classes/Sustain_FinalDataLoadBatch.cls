/**
* @description       : 
* @author            : Accenture
* @group             : 
* @last modified on  : 09-28-2021
* @last modified by  : Accenture
**/
global class Sustain_FinalDataLoadBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    map<String, list<Object_Mappings__c>> objMap;
    Map<String,List<Field_Mappings__c>> fldMap;
    Integer sequenceNo;
    String errorMessage='';
    private static final string MASTER_RECORD_TYPE = 'Master';
    private static final string orgAssetObjAPI='sustain_app__Asset__c';
    private static final string carbonFootPrintObjAPI='sustain_app__ConsumptionReport__c';
    private static final string otherEmssnFctrSetItemObjAPI='OtherEmssnFctrSetItem';
    private static final string OtherEmssnFctrSetAPI='OtherEmssnFctrSet';
    private static final string bldgEnrgyIntensityValObjAPI='BldgEnrgyIntensityVal';
    private static final string BldgEnrgyIntensityObjAPI='BldgEnrgyIntensity';
    private static final string stnryAssetEnrgyUseObjAPI='StnryAssetEnrgyUse';
    private static final string DataCenterRecordTypeAPI='Data_Center_Facility';
    private static final string BuildingRecordTypeAPI='Building';
    private static final string VehicleRecordTypeAPI='Vehicle';
    private static final string GeneralRecordTypeAPI='General';
    private static final string CurrentClassName = 'Sustain_FinalDataLoadBatch';
    private static final list<string> excludeFlds = new list<string>{'sustain_app__Other_Emission_Factor__c','sustain_app__Refrigerant_GWP_Factor__c','sustain_app__ElectricityEmissionFactor__c','sustain_app__EmissionFactorScope3__c'};
        List<String> orgAssetIds;
    String dataLoadReqId;
    String dataloadType;
    Data_Load_Request__c dataReq;
    Integer  maxSequence ;
    List<SObject> parentRecordList;
    List<SObject> childRecordList;
    Boolean isfullDataLoad;
    global Sustain_FinalDataLoadBatch(map<String, list<Object_Mappings__c>> objMap, Map<String,List<Field_Mappings__c>> fldMap, Integer sequenceNo, List<String> orgAssetIds,String dataLoadReqId) {
        this.objMap = objMap;
        this.fldMap = fldMap;
        this.sequenceNo = sequenceNo;
        this.orgAssetIds = orgAssetIds;
        this.dataLoadReqId = dataLoadReqId;
        list<aggregateResult> aggResults = [SELECT MAX(Sequence_Number__c)maxSequence FROM Object_Mappings__c];
        maxSequence = Integer.valueOf(aggResults[0].get('maxSequence'));
        system.debug('dataLoadReqId-->' + dataLoadReqId);
        dataReq = [select id, Data_Load_Type__c from Data_Load_Request__c where id=:dataLoadReqId limit 1];   
        system.debug('dataReq------------------->' + dataReq);
        system.debug('objMap------------------->' + objMap);
        
    }
    
    // Start Method  
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        string CurrentMethodName = 'start';        
        try{        
            String sourceSqlRcrdStr = '';
            set<String> uniqueFlds = new set<String>();
            set<string> ids = new set<string>();
            set<string> vendorNames = new set<string>();
            system.debug('objMap.keySet()-->' + objMap.keySet());
            List<String> objRecTypeList = new List<String>(objMap.keySet())[0]?.split('-');
            String sourceObjName = objRecTypeList[0];
            String sourcerecordTypeName = '';
            if(objRecTypeList.size() > 1){
                sourcerecordTypeName = objRecTypeList[1];
            }
            map<string,string> rcrdList = new  map<string,string>();
            for(String rcrd : objMap.keySet()) {
                if(rcrd.contains('-') && rcrd.split('-').size() >1) {
                    String recordTypeName = rcrd.split('-')[1];
                    if(String.isNotBlank(recordTypeName) && recordTypeName != 'Master' && recordTypeName != 'null') {
                        rcrdList.put(recordTypeName, Schema.getGlobalDescribe().get(sourceObjName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId());
                    }
                }
            }
            system.debug('sourceObjName-->' + sourceObjName);
            system.debug('recordType-->' + rcrdList);
            system.debug('sequenceNo-->' + sequenceNo);
            system.debug('fldMap-->' + fldMap);
            
            
            if(fldMap != null && fldMap.values().size()>0) {
                sourceSqlRcrdStr = 'select id,'; 
                for(String objId : fldMap.keyset()) {
                    list<Field_Mappings__c> fldDtls = fldMap.get(objId);
                    system.debug('fldDtls-->' + fldDtls);
                    
                    if(fldDtls != null && fldDtls.size() >0) {
                        if(fldDtls[0].Object_Mapping__r.Target_Object__c.equals(stnryAssetEnrgyUseObjAPI) && fldDtls[0].Object_Mapping__r.Source_Record_Type__c.equals(DataCenterRecordTypeAPI)){
                            sourceSqlRcrdStr+='(select sustain_app__ConsumptionReport__r.Name,sustain_app__ConsumptionReport__r.sustain_app__Additional_Scope_3_Emissions__c,sustain_app__ConsumptionReport__r.sustain_app__Allocation_Status__c,sustain_app__ConsumptionReport__r.sustain_app__Asset__c,sustain_app__ConsumptionReport__r.sustain_app__Asset__r.Target_SFDC_ID__c,sustain_app__ConsumptionReport__r.sustain_app__AuditApprovalStatus__c,sustain_app__ConsumptionReport__r.sustain_app__BuildingEnergyIntensity__c,sustain_app__ConsumptionReport__r.sustain_app__BuildingEnergyIntensity__r.Target_SFDC_ID__c,';
                            sourceSqlRcrdStr+='sustain_app__ConsumptionReport__r.sustain_app__CBECSIntensityRecord__c,sustain_app__ConsumptionReport__r.sustain_app__CBECSIntensityRecord__r.Target_SFDC_ID__c,sustain_app__ConsumptionReport__r.sustain_app__Extrapolation_Status__c,sustain_app__ConsumptionReport__r.sustain_app__Occupied_Building_Floor_Area_Unit__c,sustain_app__ConsumptionReport__r.sustain_app__Occupied_Building_Floor_Area__c,sustain_app__ConsumptionReport__r.sustain_app__ReportBoundary__c,sustain_app__ConsumptionReport__r.sustain_app__ReportEndDate__c,';
                            sourceSqlRcrdStr+='sustain_app__ConsumptionReport__r.sustain_app__ReportingYear__c,sustain_app__ConsumptionReport__r.sustain_app__Reporting_Date__c,sustain_app__ConsumptionReport__r.sustain_app__ReportStartDate__c,sustain_app__ConsumptionReport__r.sustain_app__Stage__c,sustain_app__ConsumptionReport__r.sustain_app__TotalBuildingFloorAreaUnit__c,sustain_app__ConsumptionReport__r.sustain_app__TotalBuildingFloorArea__c from sustain_app__ConsumptionReportItems__r),';
                            
                        }
                        for(Field_Mappings__c fldDtl : fldDtls) {
                            system.debug('createGenericRecords:trgtRecordtype----->' + fldDtl.Object_Mapping__r.Target_Record_Type__c);
                            system.debug('createGenericRecords:tarRecord----->' + fldDtl.Object_Mapping__r.Source_object__c);
                            system.debug('createGenericRecords:srcRecord----->' + fldDtl.Object_Mapping__r.Target_object__c);
                            system.debug('createGenericRecords:srcRecordtype----->' + fldDtl.Object_Mapping__r.source_Record_Type__c);
                            if(!uniqueFlds.contains(fldDtl.Source_Field__c)) {
                                uniqueFlds.add(fldDtl.Source_Field__c);
                                if(fldDtl.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.lookupLabel) || fldDtl.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.referenceLabel) || fldDtl.Source_Field_Type__c.containsIgnoreCase(Sustain_UtilConstants.masterDetailLabel)) {
                                    //if(!excludeFlds.contains(fldDtl.Source_Field__c)) {
                                    sourceSqlRcrdStr+= fldDtl.Source_Field__c+',';
                                    if((fldDtl.Source_Field__c != null && fldDtl.Source_Field__c.startsWith('sustain_app__')) || 
                                       (fldDtl.Reference_To__c != null && fldDtl.Reference_To__c.startsWith('sustain_app__'))){
                                           sourceSqlRcrdStr+= fldDtl.Source_Field__c.remove('__c')+'__r.Target_SFDC_ID__c,';
                                       }                                        
                                    //}
                                } else {
                                    sourceSqlRcrdStr+= fldDtl.Source_Field__c +',';
                                }
                            }
                        }               
                    }
                }
                sourceSqlRcrdStr  = sourceSqlRcrdStr.removeEnd(',');
                sourceSqlRcrdStr += ',Migration_Status__c,Target_SFDC_ID__c,Error_Details__c';
                if(!rcrdList.isEmpty() /*&& !(rcrdList.size() ==1 && rcrdList.keyset().contains('Master'))*/) {
                    sourceSqlRcrdStr += ',recordTypeID, recordType.Name, recordType.developername';      
                }
                if(String.isNotBlank(sourceObjName) && (sourceObjName.equals(carbonFootPrintObjAPI) || sourceObjName.equals('sustain_app__ConsumptionReport__c')) && !sourceSqlRcrdStr.contains('sustain_app__PY_Annual_Consumption_Report__c')) {
                    sourceSqlRcrdStr += ',sustain_app__PY_Annual_Consumption_Report__c,sustain_app__PY_Annual_Consumption_Report__r.Target_SFDC_ID__c';
                }
                /*if(sourceObjName.equals('sustain_app__BuildingEnergyIntensity__c') && sourcerecordTypeName == 'CommercialBuilding' && 'Complete Data Load' == dataReq.Data_Load_Type__c){
                    sourceSqlRcrdStr += ',sustain_app__NaturalGasIntensityKwhSqftAnnual__c,sustain_app__NaturalGasIntensityKwhM2Annual__c,sustain_app__FuelOilIntensityKwhSqftAnnual__c,'+
                        'sustain_app__ElectricityIntensityKwhSqftAnnual__c,sustain_app__HeatIntensityKwhSqftAnnual__c,sustain_app__SteamIntensityKwhSqftAnnual__c,'+
                        'sustain_app__FuelOilIntensityKwhM2Annual__c,sustain_app__CoolingIntensityKwhM2Annual__c,sustain_app__DieselIntensityKwhM2Annual__c,'+
                        'sustain_app__ElectricityIntensityKwhM2Annual__c,sustain_app__PropaneIntensityKwhM2Annual__c,sustain_app__DieselIntensityKwhSqftAnnual__c,'+
                        'sustain_app__SteamIntensityKwhM2Annual__c,sustain_app__PropaneIntensityKwhSqftAnnual__c,sustain_app__HeatIntensityKwhM2Annual__c,sustain_app__CoolingIntensityKwhSqftAnnual__c';
                }*/
                sourceSqlRcrdStr += ' from '+sourceObjName + ' where ';
                if(!rcrdList.isEmpty() /*&& !(rcrdList.size() ==1 && rcrdList.keyset().contains('Master'))*/) {
                    list<string> tempList = rcrdList.values();
                    sourceSqlRcrdStr += ' RecordTypeId in :tempList and';
                    system.debug('rcrdList---------->'+rcrdList);
                }
                //if(sequenceNo != 18 && sequenceNo != 20){
                    sourceSqlRcrdStr += ' Migration_Status__c != \'Completed\' and';
                //}
            }
            if('Sample Data Load'.equalsIgnoreCase( dataReq.Data_Load_Type__c) && String.isNotBlank(sourceSqlRcrdStr)) {
                if(!test.isRunningTest()) {
                    if(sequenceNo <= 12 || sequenceNo == 17 || sequenceNo == 18 ){
                        string sql  =  'select sustain_app__ServiceProvider__r.id,sustain_app__VendorName__c, sustain_app__EmissionFactorScope3__c,sustain_app__Refrigerant_GWP_Factor__c,sustain_app__Other_Emission_Factor__c,sustain_app__ElectricityEmissionFactor__c,sustain_app__EmissionFactorScope3__r.sustain_app__EmissionFactorScope3Dataset__c FROM sustain_app__EnergyConsumption__c where sustain_app__Asset__r.id in:orgAssetIds';
                        list<sustain_app__EnergyConsumption__c> datas = database.query(sql);
                        if(sequenceNo == 17 ) {
                            sql += ' and sustain_app__ServiceProvider__r.id!=null';
                        }
                        
                        if(sequenceNo == 18) {
                            sql += ' and sustain_app__VendorName__c != null';
                        }
                        
                        Set<Id> dataSetIds = new Set<Id>();

                        if(datas != null) {
                            for(sustain_app__EnergyConsumption__c data : datas) {
                                if(sequenceNo == 1) {
                                    ids.add(data.sustain_app__ElectricityEmissionFactor__c);
                                }else if(sequenceNo == 2 || sequenceNo == 3 || sequenceNo == 4) {
                                    ids.add(data.sustain_app__Refrigerant_GWP_Factor__c);
                                    ids.add(data.sustain_app__Other_Emission_Factor__c);
                                }else if(sequenceNo == 5 ) {
                                    ids.add(data.sustain_app__EmissionFactorScope3__r.sustain_app__EmissionFactorScope3Dataset__c);
                                }else if(sequenceNo >= 6 && sequenceNo <= 12) {
                                    ids.add(data.sustain_app__EmissionFactorScope3__c);
                                    dataSetIds.add(data.sustain_app__EmissionFactorScope3__r.sustain_app__EmissionFactorScope3Dataset__c);
                                } else  if(sequenceNo == 17 ) {
                                    ids.add(data.sustain_app__ServiceProvider__r.id);
                                }else if(sequenceNo == 18) {
                                    vendorNames.add(data.sustain_app__VendorName__c); 
                                }
                            }                        
                        }
                        if(sequenceNo == 5) {
                            string sql1  =  'select id FROM sustain_app__ConsumptionReport__c where sustain_app__Asset__r.id in:orgAssetIds';
                            list<sustain_app__ConsumptionReport__c> datas1 = database.query(sql1);
                            set<string> datasetId = new Set<String>();
                            if(datas1 != null) {
                                for(sustain_app__ConsumptionReport__c data : datas1) {
                                    datasetId.add(data.id);
                                }
                            }
                            map<string, sustain_app__ProcurementDataset__c>  resultMap = new map<string, sustain_app__ProcurementDataset__c>([select id,sustain_app__EmissionFactorScope3Dataset__c from sustain_app__ProcurementDataset__c where sustain_app__CarbonFootprint__c in :datasetId]);
                            if(resultMap != null) {
                                for(string key :resultMap.keyset()) {
                                    ids.add(resultMap.get(key).sustain_app__EmissionFactorScope3Dataset__c);
                                }
                            }
                        }
                        if(sequenceNo >= 6 && sequenceNo <=12 && dataSetIds.size() > 0){
                            System.debug('dataSetIds '+dataSetIds);
                            map<string, sustain_app__ProcurementEntry__c>  pEntryMap = new map<string, sustain_app__ProcurementEntry__c>([select id, sustain_app__EmissionFactorScope3__c from sustain_app__ProcurementEntry__c where sustain_app__ProcurementDataset__c in :dataSetIds AND sustain_app__EmissionFactorScope3__c != null]);
                            
                            if(pEntryMap != null) {
                                for(string key :pEntryMap.keyset()) {
                                    ids.add(pEntryMap.get(key).sustain_app__EmissionFactorScope3__c);
                                }
                            }
                        }
                        if(ids!= null && ids.size()>0) {
                            sourceSqlRcrdStr += ' id in:ids';
                        }
                        
                        if(vendorNames != null && vendorNames.size() > 0){
                            sourceSqlRcrdStr += ' Vendor_Name__c in:vendorNames';
                        }
                        
                    } else if(sequenceNo == 13 || sequenceNo == 14 || sequenceNo == 15) {
                        string sql  =  'SELECT sustain_app__CBECSRecord__c,sustain_app__CBECSRecord__r.sustain_app__BuildingSizeCategory__c  FROM sustain_app__Asset__c where id in:orgAssetIds';
                        list<sustain_app__Asset__c> datas = database.query(sql);
                        if(datas != null) {
                            for(sustain_app__Asset__c data : datas) {
                                if(sequenceNo == 13) {
                                    ids.add(data.sustain_app__CBECSRecord__r.sustain_app__BuildingSizeCategory__c);
                                } else if(sequenceNo == 14 || sequenceNo == 15) {
                                    ids.add(data.sustain_app__CBECSRecord__c);
                                }
                            }
                        }
                        if(ids!= null && ids.size()>0) {
                            sourceSqlRcrdStr += ' id in:ids';
                        }
                        
                    }else if(sequenceNo == 19){
                        string sql  =  'SELECT sustain_app__SustainabilityContact__r.Id FROM sustain_app__AssetContact__c where sustain_app__SustainabilityAsset__r.id in:orgAssetIds and sustain_app__SustainabilityContact__r.id!=null';
                        list<sustain_app__AssetContact__c> datas = database.query(sql);
                        if(datas != null) {
                            for(sustain_app__AssetContact__c data : datas) {
                                ids.add(data.sustain_app__SustainabilityContact__r.id);
                            }
                        }
                        if(ids!= null && ids.size()>0) {
                            sourceSqlRcrdStr += ' id in:ids';
                        }
                        
                    } else if((sequenceNo == 20 || sequenceNo == 21 || sequenceNo == 22 || sequenceNo == 23) && orgAssetIds != null && orgAssetIds.size()>0) {
                        sourceSqlRcrdStr += ' id in:orgAssetIds and';
                    }else if(sequenceNo == 24 && orgAssetIds != null && orgAssetIds.size()>0) {
                        sourceSqlRcrdStr += ' id in:orgAssetIds';
                    }else if(sequenceNo >= 25 && sequenceNo <= 39){
                        sourceSqlRcrdStr += ' sustain_app__Asset__r.id in:orgAssetIds';
                    } else  if(sequenceNo == 40 || sequenceNo == 41){
                        string sql  =  'select id FROM sustain_app__ConsumptionReport__c where sustain_app__Asset__r.id in:orgAssetIds';
                        list<sustain_app__ConsumptionReport__c> datas = database.query(sql);
                        
                        if(datas != null) {
                            for(sustain_app__ConsumptionReport__c data : datas) {
                                ids.add(data.id);
                            }
                        }
                        
                        if(ids!= null && ids.size()>0 && sequenceNo == 40) {
                            sourceSqlRcrdStr += ' sustain_app__CarbonFootprint__c in:ids';
                        }
                        if(sequenceNo == 41) {
                            map<string, sustain_app__ProcurementDataset__c>  resultMap = new map<string, sustain_app__ProcurementDataset__c>([select id from sustain_app__ProcurementDataset__c where sustain_app__CarbonFootprint__c in :ids]);
                            if(resultMap != null) {
                                set<string> val = resultMap.keyset();
                                sourceSqlRcrdStr += ' sustain_app__ProcurementDataset__c in :val';
                            }
                        }
                    }                    
                }                
            }
            if(sequenceNo == 20){
                sourceSqlRcrdStr += ' sustain_app__AssetType__c != \'Data Center\'';
            }else if(sequenceNo == 21){
                sourceSqlRcrdStr += ' sustain_app__AssetType__c = \'Data Center\'';
            }else if(sequenceNo == 22){
                sourceSqlRcrdStr += ' sustain_app__AssetType__c != \'Private Jet\'';    
            }else if(sequenceNo == 23){
                sourceSqlRcrdStr += ' sustain_app__AssetType__c = \'Private Jet\'';    
            }

            sourceSqlRcrdStr = sourceSqlRcrdStr.removeEnd(' where ');
            sourceSqlRcrdStr = sourceSqlRcrdStr.removeEnd('and');
            if(sourceObjName.equals(orgAssetObjAPI) ){
                sourceSqlRcrdStr += ' order by sustain_app__ParentAsset__c nulls first';
            } else if(sourceObjName.equals(carbonFootPrintObjAPI)){
                sourceSqlRcrdStr += ' order by sustain_app__PY_Annual_Consumption_Report__c nulls first';
            }
            system.debug('sourceSqlRcrdStr-->' + sourceSqlRcrdStr); 
            return Database.getQueryLocator(sourceSqlRcrdStr); 
        }catch(Exception e) {
            dataReq.End_Date_Time__c = System.now();
            dataReq.Status__c = 'Failed';
            update dataReq;  
            system.debug('e.getLineNumber()' + e.getLineNumber());
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);  
            user us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
            List<String> emailAddress = new List<String>();
            emailAddress.add(us.email);            
            Sustain_SendNotification sendData =new Sustain_SendNotification();
            sendData.sendEmailNotification('Sustain_Error_FinalDataLoadEmails',emailAddress); 
            return Database.getQueryLocator('');
        }       
    }
    
    // Execute method
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        string CurrentMethodName = 'execute';
        String sourceObjName = new List<String>(objMap.keySet())[0];
        system.debug('inside execute-->'+ sourceObjName + ' : '+(scope !=null));
        Sustain_utils.SustainUtilWrapper wrapper;
        try {
            List<list<SObject>> finalDataList = new List<list<SObject>>();              
            if(scope != null && scope.size() >0) {
                for(String eachObjName : objMap.keySet()) {
                    for(Object_Mappings__c eachObj : objMap.get(eachObjName)) { 
                        list<SObject> reocrdToBeInserted = new  list<SObject>(); 
                        list<Field_Mappings__c> fldDtls = fldMap.get(eachObj.id);
                        if(eachObj.Source_Object__c.equals(orgAssetObjAPI) || eachObj.Source_Object__c.equals(carbonFootPrintObjAPI)){
                            reocrdToBeInserted =  partialProcessingforSelfLookup(eachObj.Source_Object__c,scope, fldDtls);
                        }
                        else if(eachObj.Target_Object__c.equals(otherEmssnFctrSetItemObjAPI)){
                            system.debug('eachObjName------------>' + eachObjName);
                            system.debug('eachObj------------>' + eachObj);
                            wrapper = Sustain_Utils.createOtherEmissionChildRecords(scope, fldDtls);
                            system.debug('createOtherEmissionChildRecords :wrapper.status : ' + wrapper.status);
                            isfullDataLoad = (wrapper.status == 'Success') ? true : false;
                            reocrdToBeInserted =  wrapper.listOfobject;    
                        }
                        else if(eachObj.Target_Object__c.equals(bldgEnrgyIntensityValObjAPI)){
                            system.debug('scope-->' + scope.size());
                            wrapper = Sustain_Utils.createBuildingEnergyIntensityValueRecords(scope, fldDtls);
                            system.debug('createBuildingEnergyIntensityValueRecords :wrapper.status : ' + wrapper.status);
                            isfullDataLoad = (wrapper.status == 'Success') ? true : false;
                            reocrdToBeInserted =  wrapper.listOfobject;    
                        }
                        else if(eachObj.Target_Object__c.equals(stnryAssetEnrgyUseObjAPI)){
                            wrapper = Sustain_Utils.createEnergyUseandItemRecords(scope, fldDtls);
                            system.debug('createEnergyUseandItemRecords :wrapper.status : ' + wrapper.status);
                            isfullDataLoad = (wrapper.status == 'Success') ? true : false;
                            reocrdToBeInserted =  wrapper.listOfobject;    
                        }    
                        else if(!eachObj.Target_Object__c.equals('StnryAssetCrbnFtprntItm')) {                            
                            wrapper = Sustain_Utils.createGenericRecords(scope, fldDtls);
                            system.debug('createGenericRecords :wrapper.status : ' + wrapper.status);
                            isfullDataLoad = (wrapper.status == 'Success') ? true : false;
                            system.debug('execute isfullDataLoad : ' + isfullDataLoad);
                            reocrdToBeInserted =  wrapper.listOfobject;
                        }
                        finalDataList.add(reocrdToBeInserted);
                    }
                }
            }  else {
                isfullDataLoad = true;
            }
            
            //updating looup data between two related objects           
            if(finalDataList.size() >1) {
                parentRecordList = finalDataList.get(0);
                childRecordList = finalDataList.get(1);
            } else if(finalDataList.size() ==1)  {
                parentRecordList = finalDataList.get(0);
            }
            
            //updating target Target_SFDC_ID__c filed of source object records
            if(parentRecordList != null && parentRecordList.size() >0 ) {
                //Sustain_Utils.updateSourceObjectRecords(scope, parentRecordList, parentRecordList.get(0).getSObjectType().getDescribe().getName());
            }
            if(childRecordList != null && childRecordList.size() >0) {
                //Sustain_Utils.updateSourceObjectRecords(scope, childRecordList, childRecordList.get(0).getSObjectType().getDescribe().getName());
            }
            system.debug('execute isfullDataLoad2 : '  + new List<String>(objMap.keySet())[0] +' : '+  isfullDataLoad);
        } catch(exception e) {
            errorMessage= e.getMessage();
            dataReq.End_Date_Time__c = System.now();
            dataReq.Status__c = 'Failed';
            update dataReq;
            system.debug('Sustain_FinalDataLoadBatch:error-->' + e);
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
            
            system.debug('finish isfullDataLoad2 : ' + new List<String>(objMap.keySet())[0] +' : '+ isfullDataLoad);
            user us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
            List<String> emailAddress = new List<String>();
            emailAddress.add(us.email);
            String emailTemplate = '';   
            if(objMap != null) {
                list<Object_Mappings__c> lst = new List<Object_Mappings__c>();
                system.debug('inside finish method-->errorMessage :  ' + errorMessage);
                system.debug('inside finish method-->isfullDataLoad :  ' + isfullDataLoad);    
                for(String str : objMap.keyset())  { 
                    for(Object_Mappings__c each :  objMap.get(str)) {
                        if(String.isBlank(errorMessage) && (isfullDataLoad== null || isfullDataLoad )) {
                            each.Status__c = 'Completed';
                        } else if(String.isNotBlank(errorMessage) || (isfullDataLoad !=null && !isfullDataLoad)) {
                            each.Status__c = 'Error';
                        } 
                        lst.add(each);
                        system.debug('inside finish method-->Status__c :  ' + each.Status__c);   
                    }
                }
                update lst; 
            }
            
            List<Sustain_SampleLoadObjects__mdt> datalist ;
            list<Object_Mappings__c> objMappingList;
            
            sequenceNo = sequenceNo != null ? ++sequenceNo : null;       
            Integer batchSize = 200;    
            if('Sample Data Load'.equalsIgnoreCase( dataReq.Data_Load_Type__c) && String.isBlank(errorMessage)) {
                if(!test.isRunningTest()) {
                    objMap = new  map<String, list<Object_Mappings__c>>();
                    fldMap = new Map<String,List<Field_Mappings__c>> ();  
                    string mdtQuery = 'select Source_Object__c, Sequence_Number__c from Sustain_SampleLoadObjects__mdt where Sequence_Number__c=:sequenceNo';
                    datalist?.clear();
                    datalist = database.query(mdtQuery);    
                    system.debug('datalist--->' + datalist);
                    if(datalist != null && datalist.size() >0) {
                        objMappingList?.clear();
                        String objName = datalist[0].Source_Object__c;
                        double sequence = double.valueOf(datalist[0].Sequence_Number__c);
                        string sqlStr = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c,Batch_Size__c from Object_Mappings__c where Sequence_Number__c=: sequenceNo and  Status__c = \'Not Started\'  and mapping_included__c=true and target_object__c !=\'StnryAssetCrbnFtprntItm\' order by  sequence_number__c,Target_Object__c nulls last';
                        objMappingList = Database.query(sqlStr);
                        system.debug('objMappingList----->' + objMappingList);
                        list<id> recordIds =  new list<id>();
                        for(Object_Mappings__c obj : objMappingList) {
                            recordIds.add(obj.id);
                            string key = obj.Source_Object__c + '-' +obj.Source_Record_Type__c.replaceAll('sustain_app__','').replaceAll('Sustain_app__','');
                            if(objMap.keyset().contains(key)) {
                                objMap.get(key).add(obj);
                            } else {
                                list<Object_Mappings__c> tempList = new list<Object_Mappings__c>();
                                tempList.add(obj);
                                objMap.put(key,tempList);
                                batchSize = obj.Batch_Size__c != null ? obj.Batch_Size__c.intValue() : 200 ;
                            }
                        }
                        
                        //preparing filed map based on object mapping record
                        String querySql = 'SELECT id, Object_Mapping__c,Reference_To__c,Source_Field__c,Target_Field__c,Object_Mapping__r.Source_Object__c,Object_Mapping__r.Source_Record_Type__c,Source_Field_Type__c,Object_Mapping__r.Target_Object__c,Object_Mapping__r.Target_Record_Type__c,New_Field__c FROM Field_Mappings__c where Object_Mapping__c in :recordIds  and mapping_included__c=true and calculated__c=false order by Object_Mapping__c nulls last';  
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
                        if(objMap != null && fldMap != null) {
                            Sustain_FinalDataLoadBatch nextBatch = new Sustain_FinalDataLoadBatch(objMap, fldMap, sequenceNo,orgAssetIds,dataLoadReqId);
                            database.executeBatch(nextBatch, (batchSize != null && batchSize !=0) ? batchSize : 200);
                        }
                    } else if(datalist == null || datalist.size() ==0){
                        system.debug('end of batch');
                        integer  processedRcrdCount ;
                        integer  totalRcrdCount ;
                        if('Sample Data Load'.equalsIgnoreCase( dataReq.Data_Load_Type__c)) {
                            list<string> mdtQueryList = new List<string>();
                            for(Sustain_SampleLoadObjects__mdt seq : [select Source_Object__c, Sequence_Number__c from Sustain_SampleLoadObjects__mdt LIMIT 1000]) {
                                mdtQueryList.add(seq.Source_Object__c);       
                            }                  
                            totalRcrdCount = database.countQuery('SELECT count() FROM Object_Mappings__c where source_object__c in:mdtQueryList and mapping_included__c=true and Object_Type__c != \'custom\'');
                            processedRcrdCount = database.countQuery('SELECT count() FROM Object_Mappings__c where source_object__c in:mdtQueryList and mapping_included__c=true and status__c =\'Completed\' AND Object_Type__c != \'custom\'');
                        } else {
                            totalRcrdCount = database.countQuery('SELECT count() FROM Object_Mappings__c where mapping_included__c=true AND Object_Type__c != \'custom\'');
                            processedRcrdCount = database.countQuery('SELECT count() FROM Object_Mappings__c where mapping_included__c=true and status__c =\'Completed\' AND Object_Type__c != \'custom\'');
                        }
                        if(totalRcrdCount == processedRcrdCount) {
                            dataReq.Status__c = 'Completed';
                            emailTemplate = 'Sustain_FinalDataLoadEmails';
                        } else if(processedRcrdCount == 0) {
                            dataReq.Status__c = 'Failed';
                            emailTemplate = 'Sustain_Error_FinalDataLoadEmails';
                        } else {
                            dataReq.Status__c = 'Partial Complete';
                            emailTemplate = 'Sustain_SampleDataLoadEmails';
                        }
                        dataReq.End_Date_Time__c = System.now();
                        try {
                            update dataReq;
                        } catch(exception e) {
                            system.debug('dataReq update error-->' + e);
                            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
                        }              
                        
                        Sustain_SendNotification sendData =new Sustain_SendNotification();
                        sendData.sendEmailNotification(emailTemplate,emailAddress);   
                    }
                    
                }            
                
            }else if(!'Sample Data Load'.equalsIgnoreCase(dataReq.Data_Load_Type__c)  && String.isBlank(errorMessage)) {
                objMap = new  map<String, list<Object_Mappings__c>>();
                fldMap = new Map<String,List<Field_Mappings__c>> (); 
                string sqlStr ='';
                sequenceNo = Sustain_Utils.getSequebnceNo(sequenceNo);
                if(sequenceNo != null && sequenceNo <= maxSequence) {
                    sqlStr = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c,Batch_Size__c from Object_Mappings__c where Sequence_Number__c=: sequenceNo and Status__c = \'Not Started\' AND Object_Type__c != \'custom\'  and mapping_included__c=true  and target_object__c !=\'StnryAssetCrbnFtprntItm\' order by  sequence_number__c,Target_Object__c nulls last';
                } else {
                    sqlStr = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c,Batch_Size__c from Object_Mappings__c where Status__c = \'Not Started\' AND Object_Type__c != \'custom\'  and mapping_included__c=true  and target_object__c !=\'StnryAssetCrbnFtprntItm\' order by  sequence_number__c,Target_Object__c nulls last';
                }
                objMappingList = Database.query(sqlStr);
                list<Object_Mappings__c> customObjectList;
                
                if(objMappingList == null || objMappingList.size() == 0){
                    sqlStr = 'select id,Target_Object__c,Source_Object__c,Source_Record_Type__c,Target_Record_Type__c,Batch_Size__c from Object_Mappings__c where Status__c = \'Not Started\' AND Object_Type__c = \'custom\' and mapping_included__c=true  and target_object__c !=\'StnryAssetCrbnFtprntItm\' order by  sequence_number__c,Target_Object__c nulls last limit 1';    
                    customObjectList = Database.query(sqlStr);
                }
                system.debug('objMappingList-->' + objMappingList);
                system.debug('customObjectList-->' + customObjectList);
                list<id> recordIds =  new list<id>();
                if(objMappingList != null && objMappingList.size()> 0) {
                    for(Object_Mappings__c obj : objMappingList) {
                        recordIds.add(obj.id);
                        string key = obj.Source_Object__c + '-' +obj.Source_Record_Type__c?.replaceAll('sustain_app__','')?.replaceAll('Sustain_app__','');
                        if(objMap.keyset().contains(key)) {
                            objMap.get(key).add(obj);
                        } else {
                            list<Object_Mappings__c> tempList = new list<Object_Mappings__c>();
                            tempList.add(obj);
                            objMap.put(key,tempList);
                            batchSize = obj.Batch_Size__c != null ? obj.Batch_Size__c.intValue() : 200 ; 
                        }
                    }
                    
                    //preparing filed map based on object mapping record
                    String querySql = 'SELECT id, Object_Mapping__c,Reference_To__c,Source_Field__c,Target_Field__c,Object_Mapping__r.Source_Object__c,Source_Field_Type__c,Object_Mapping__r.Target_Object__c,Object_Mapping__r.source_Record_Type__c,Object_Mapping__r.Target_Record_Type__c,New_Field__c FROM Field_Mappings__c where Object_Mapping__c in :recordIds and mapping_included__c=true and Calculated__c = false order by Object_Mapping__c asc'; 
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
                    Sustain_FinalDataLoadBatch nextBatch = new Sustain_FinalDataLoadBatch(objMap, fldMap, sequenceNo,null,dataLoadReqId);
                    database.executeBatch(nextBatch, (batchSize != null && batchSize !=0) ? batchSize : 200);            
                } else if(customObjectList!=null && customObjectList.size() > 0){                
                    Sustain_UpdateCustomObjectRefBatch nextcustBatch = new Sustain_UpdateCustomObjectRefBatch(customObjectList[0], 'FinalDataLoad');
                    database.executeBatch(nextcustBatch, (customObjectList[0].Batch_Size__c != null && customObjectList[0].Batch_Size__c.intValue() !=0) ? customObjectList[0].Batch_Size__c.intValue() : 200);                       
                } else {
                    system.debug('end of batch final');
                    integer  processedRcrdCount ;
                    integer  totalRcrdCount ;
                    if('Sample Data Load'.equalsIgnoreCase( dataReq.Data_Load_Type__c)) {
                        list<string> mdtQueryList = new List<string>();
                        for(Sustain_SampleLoadObjects__mdt seq : [select Source_Object__c, Sequence_Number__c from Sustain_SampleLoadObjects__mdt LIMIT 1000]) {
                            mdtQueryList.add(seq.Source_Object__c);       
                        }                  
                        totalRcrdCount = database.countQuery('SELECT count() FROM Object_Mappings__c where source_object__c in:mdtQueryList and mapping_included__c=true AND Object_Type__c != \'custom\'');
                        processedRcrdCount = database.countQuery('SELECT count() FROM Object_Mappings__c where source_object__c in:mdtQueryList and mapping_included__c=true and status__c =\'Completed\' AND Object_Type__c != \'custom\'');
                    } else {
                        totalRcrdCount = database.countQuery('SELECT count() FROM Object_Mappings__c where mapping_included__c=true AND Object_Type__c != \'custom\'');
                        processedRcrdCount = database.countQuery('SELECT count() FROM Object_Mappings__c where mapping_included__c=true and status__c =\'Completed\' AND Object_Type__c != \'custom\'');
                    }
                    if(totalRcrdCount == processedRcrdCount) {
                        dataReq.Status__c = 'Completed';
                        emailTemplate = 'Sustain_FinalDataLoadEmails';
                    } else if(processedRcrdCount == 0) {
                        dataReq.Status__c = 'Failed';
                        emailTemplate = 'Sustain_Error_FinalDataLoadEmails';
                    } else {
                        dataReq.Status__c = 'Partial Complete';
                        emailTemplate = 'Sustain_SampleDataLoadEmails';
                    }
                    dataReq.End_Date_Time__c = System.now();
                    try {
                        update dataReq;
                    } catch(exception e) {
                        system.debug('dataReq update error-->' + e);
                        Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
                    }
                    
                    Sustain_SendNotification sendData =new Sustain_SendNotification();
                    sendData.sendEmailNotification(emailTemplate,emailAddress);   
                    sendData.sendChatterNotification('FinalDataLoadEmails');
                }
                
            }
            
        } catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);   
            dataReq.End_Date_Time__c = System.now();
            dataReq.Status__c = 'Failed';
            update dataReq;  
            user us = [Select id,Name,email from User where id=:Userinfo.getUserId() limit 1];
            List<String> emailAddress = new List<String>();
            emailAddress.add(us.email);            
            Sustain_SendNotification sendData =new Sustain_SendNotification();
            sendData.sendEmailNotification('Sustain_Error_FinalDataLoadEmails',emailAddress); 
        }
    }
    
    private list<SObject> partialProcessingforSelfLookup(String objAPI,List<sObject> scope,List<Field_Mappings__c> fldDtls){
        List<sObject> effectedList=new List<sObject>();
        list<SObject> reocrdToBeInserted = new  list<SObject>();
        Sustain_utils.SustainUtilWrapper wrapper;
        
        
        if(objAPI.equals(orgAssetObjAPI)){
            map<string, string> parentChildRS = new Map<String,string>();
            set<String> objList = new  set<String>();
            for(integer  i = (scope.size()-1) ; i>= 0 ; i--){
                if(scope[i].get('sustain_app__ParentAsset__c')==null){
                    effectedList.add(scope[i]);
                    scope.remove(i);
                } 
            }
            system.debug('effectedList1-->'+ effectedList);
            if(!scope.isEmpty()) {
                for(sobject s : scope) {
                    objList.add((String)s.get('sustain_app__ParentAsset__c'));
                }
                String sql = 'select id, target_sfdc_id__c from ' + objAPI +  ' where id in :objList';
                for(Sobject each : database.query(sql)) {
                    if( each.get('target_sfdc_id__c') != null) {
                        parentChildRS.put((String)each.get('id'), (String)each.get('target_sfdc_id__c'));
                    }
                }
                
            }
            wrapper = Sustain_Utils.createGenericRecords(effectedList, fldDtls);
            isfullDataLoad = ('Success' == wrapper.status ) ? true : false;
            List<SObject> tempList =  wrapper.listOfobject;
            system.debug('tempList1-->'+ tempList);
            if(tempList != null) {
                reocrdToBeInserted.addAll(tempList);
                system.debug('reocrdToBeInserted1-->'+ reocrdToBeInserted);
                while(scope.size()>0 && tempList != null && !tempList.isEmpty()){
                    Map<Id,Id> srcIdMap=new Map<Id,Id>(); 
                    if(tempList != null) {
                        for(Sobject s :tempList){
                            srcIdMap.put((id)s.get('Source_Record_ID__c'),(id)s.get('Id'));
                        }
                    }
                    effectedList?.clear();
                    for(integer  i = (scope.size()-1) ; i>= 0 ; i--){
                        if(srcIdMap.containsKey((id)scope[i].get('sustain_app__ParentAsset__c'))){
                            String srcField='sustain_app__ParentAsset__r';
                            scope[i].getSObject(srcField).put('Target_SFDC_ID__c',(id)srcIdMap.get((id)scope[i].get('sustain_app__ParentAsset__c')));
                            effectedList.add(scope[i]);
                            scope.remove(i);
                        }
                    }
                    tempList?.clear();
                    system.debug('effectedList2-->'+ effectedList);
                    wrapper = Sustain_Utils.createGenericRecords(effectedList, fldDtls);
                    isfullDataLoad = (wrapper.status == 'Success') ? true : false;
                    tempList = wrapper.listOfobject;
                    system.debug('tempList2-->'+ tempList);
                    if(tempList != null) {
                        reocrdToBeInserted.addAll(tempList);
                    }
                    system.debug('reocrdToBeInserted2-->'+ reocrdToBeInserted);
                }
            }
            if(scope.size()>0){
                List<SObject> listToProcess= new  List<SObject>();
                for(Sobject s : scope){
                    if(parentChildRS.containsKey((String)s.get('sustain_app__ParentAsset__c'))){
                        String srcField='sustain_app__ParentAsset__r';
                        s.getSObject(srcField).put('Target_SFDC_ID__c',(id)parentChildRS.get((String)s.get('sustain_app__ParentAsset__c')));
                        listToProcess.add(s);
                    }
                }
                wrapper = Sustain_Utils.createGenericRecords(listToProcess, fldDtls);
                isfullDataLoad = (wrapper.status == 'Success') ? true : false;
                tempList = wrapper.listOfobject;
                system.debug('tempList2-->'+ tempList);
                if(tempList != null) {
                    reocrdToBeInserted.addAll(tempList);
                }
            }
        } else if(objAPI.equals(carbonFootPrintObjAPI)){
            map<string, string> parentChildRS = new Map<String,string>();
            set<String> objList = new  set<String>();
            system.debug('scope.size() before-->'+ scope.size());
            for(integer  i = (scope.size()-1) ; i>= 0 ; i--){
                system.debug('scope brfore-->'+ scope[i]);
                if(scope[i].get('sustain_app__PY_Annual_Consumption_Report__c')==null){
                    system.debug('scope inside-->'+ scope[i]);
                    effectedList.add(scope[i]);
                    scope.remove(i);
                }
            }
            if(!scope.isEmpty()) {
                for(sobject s : scope) {
                    objList.add((String)s.get('sustain_app__PY_Annual_Consumption_Report__c'));
                }
                String sql = 'select id, target_sfdc_id__c from ' + objAPI +  ' where id in :objList';
                for(Sobject each : database.query(sql)) {
                    if( each.get('target_sfdc_id__c') != null) {
                        parentChildRS.put((String)each.get('id'), (String)each.get('target_sfdc_id__c'));
                    }
                }
                
            }
            system.debug('scope.size() after-->'+ scope.size());
            system.debug('effectedList3 -->'+ effectedList.size());
            
            wrapper = Sustain_Utils.createGenericRecords(effectedList, fldDtls);
            isfullDataLoad = (wrapper.status == 'Success') ? true : false;
            List<SObject> tempList =  wrapper.listOfobject;
            system.debug('tempList3-->' + tempList);
            system.debug('reocrdToBeInserted3-->' + reocrdToBeInserted);
            if(tempList != null) {
                reocrdToBeInserted.addAll(tempList);
                while(scope.size()>0 && tempList != null && !tempList.isEmpty()){
                    Map<Id,Id> srcIdMap=new Map<Id,Id>(); 
                    if(tempList != null) {
                        for(Sobject s :tempList){
                            srcIdMap.put((id)s.get('Source_Record_ID__c'),(id)s.get('Id'));
                        }
                    }
                    effectedList.clear();
                    for(integer  i = (scope.size()-1) ; i>= 0 ; i--){
                        if(srcIdMap.containsKey((id)scope[i].get('sustain_app__PY_Annual_Consumption_Report__c'))){
                            String srcField='sustain_app__PY_Annual_Consumption_Report__r';
                            scope[i].getSObject(srcField).put('Target_SFDC_ID__c',(id)srcIdMap.get((id)scope[i].get('sustain_app__PY_Annual_Consumption_Report__c')));
                            effectedList.add(scope[i]);
                            scope.remove(i);
                        }
                    }
                    tempList.clear();
                    system.debug('effectedList4 -->'+ effectedList.size());
                    wrapper = Sustain_Utils.createGenericRecords(effectedList, fldDtls);
                    tempList = wrapper.listOfobject;
                    isfullDataLoad = (wrapper.status == 'Success') ? true : false;
                    if(tempList != null) {
                        reocrdToBeInserted.addAll(tempList);
                    }
                    system.debug('tempList3-->' + tempList);
                    system.debug('reocrdToBeInserted3-->' + reocrdToBeInserted);
                }     
            }
            if(scope.size()>0){
                List<SObject> listToProcess= new  List<SObject>();
                for(Sobject s : scope){
                    if(parentChildRS.containsKey((String)s.get('sustain_app__PY_Annual_Consumption_Report__c'))){
                        String srcField='sustain_app__PY_Annual_Consumption_Report__r';
                        s.getSObject(srcField).put('Target_SFDC_ID__c',(id)parentChildRS.get((String) s.get('sustain_app__PY_Annual_Consumption_Report__c')));
                        listToProcess.add(s);
                    }
                }
                wrapper = Sustain_Utils.createGenericRecords(listToProcess, fldDtls);
                isfullDataLoad = (wrapper.status == 'Success') ? true : false;
                tempList = wrapper.listOfobject;
                system.debug('tempList2-->'+ tempList);
                if(tempList != null) {
                    reocrdToBeInserted.addAll(tempList);
                }
            }   
        }
        return reocrdToBeInserted;
    }
}