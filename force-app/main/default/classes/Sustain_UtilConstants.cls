/**
 * @description       : 
 * @author            : Accenture
 * @group             : 
 * @last modified on  : 09-23-2021
 * @last modified by  : Accenture
**/
public without sharing class Sustain_UtilConstants {
    public static final string standardLabel='standard';
    public static final string standardWithCustFieldLabel='standard with custom field';
    public static final string customLabel='custom';
    public static final string CustomwithCORE='Custom Object with Core Object';
    public static final string removedLabel ='Removed';
    public static final string customFieldLabel= 'Custom Field';
    public static final string referenceLabel='Reference';
    public static final string masterLabel = 'Master';
    public static final string lookupLabel = 'Lookup';
    public static final string Picklistabel = 'Picklist';
    public static final string masterDetailLabel = 'Master-Detail';
    public static final string EMISSIONFACTOROTHER = 'sustain_app__EmissionFactorOther__c';
    public static final Map<String,String> stageStepMap=new  Map<String,String>{'Org Data Scan Output' => 'step1','Review/Update Object Mapping' => 'step2','Review/Update Field Mapping' => 'step3',
                                                                'Confirm Data Mapping' => 'step4','Verify Sample Data Load' => 'step5','Complete Data Load' => 'step6'}; 
    public static final Map<String,String> stepStageMap=new  Map<String,String>{'step1' => 'Org Data Scan Output','step2' => 'Review/Update Object Mapping','step3' => 'Review/Update Field Mapping',
                                                                'step4' => 'Confirm Data Mapping','step5' => 'Verify Sample Data Load','step6' => 'Complete Data Load'}; 
    public static final Map<String,String> coreObjectMap=new  Map<String,String>{'Carbon Emissions Scope Allocation' => 'CrbnEmssnScopeAlloc','Carbon Emissions Scope Allocation Value' => 'CrbnEmssnScopeAllocVal','Generated Waste' => 'GeneratedWaste',
                                                                'Waste Footprint' => 'WasteFootprint','Waste Footprint Item' => 'WasteFootprintItem'}; 
    public static final List<String> stdFieldList=new List<String>{'OwnerId','CreatedById','LastModifiedById','LastModifiedDate','Id','IsDeleted','CreatedDate',
                                                                   'SystemModstamp','LastViewedDate','LastReferencedDate','LastActivityDate','Source_Record_ID__c'};
                                                                       
     public static final List<String> MIGRATION_DATA_OBJECTS=new List<String>{'sustain_app__EmissionFactorElectricity__c','sustain_app__EmissionFactorOther__c','sustain_app__EmissionFactorScope3Dataset__c','sustain_app__EmissionFactorScope3__c','sustain_app__BuildingEnergyIntensity__c',
                                                                   'sustain_app__InflationRate__c'};
    
    public static final Set<String> STATICFIELDNAMES =new Set<String>{'Error_Details__c','Migration_Status__c','Target_SFDC_ID__c', 'Source_Record_ID__c'};

    public static final Set<String> SCFirstCoreObjectNames =new Set<String>{'AirTravelEmssnFctr','AirTravelEnrgyUse',
                        'BldgEnrgyIntensity','BldgEnrgyIntensityVal','BldgSizeCategory', 'ElectricityEmssnFctrSet', 'FrgtHaulingEmssnFctr',
                        'FrgtHaulingEnrgyUse','GroundTravelEmssnFctr','GroundTravelEnrgyUse' };
    
    public static final Set<String> SCSecondCoreObjectNames =new Set<String>{'HotelStayEmssnFctr', 'HotelStayEnrgyUse', 'InflationRate',
                        'OtherEmssnFctrSet','OtherEmssnFctrSetItem','PcmtEmssnFctrSet','RefrigerantEmssnFctr', 'RentalCarEmssnFctr', 'RentalCarEnrgyUse',
                        'Scope3CrbnFtprnt' };

    public static final Set<String> SCThirdCoreObjectNames =new Set<String>{'Scope3EmssnSrc','Scope3PcmtItem','Scope3PcmtSummary', 'StnryAssetCrbnFtprnt', 
                        'StnryAssetCrbnFtprntItm', 'StnryAssetEnrgyUse','StnryAssetEnvrSrc','VehicleAssetCrbnFtprnt','VehicleAssetEmssnSrc', 'VehicleAssetEnrgyUse' };
    
    public static final Set<String> SCFourCoreObjectNames =new Set<String>{'PcmtEmssnFctrSetItem' };

    public static final Map<Integer,String>  EURecordTypesMap = new Map<Integer,String>{1 => 'Real_Estate_Facility', 2 => 'Data_Center_Facility', 
            3 => 'FreightHauling', 4 => 'Air_Travel', 5 => 'Ground_Travel', 6 => 'Fleet_Vehicle', 7 => 'Private_Jet', 8 => 'Hotel_Stay',9 => 'Rental_Car'};
    
    public static String castTypeToString(Schema.DisplayType inputType){
        System.debug(inputType);
        switch on inputType{
            when String{
                return 'String';
            }
            when Boolean{
                return 'Boolean';
            }
            when Picklist{
                return 'Picklist';
            }
            When Integer{
                return 'Integer';
            }
            When Double{
                return 'Double';
            }
            When Percent{
                return 'Percent';
            }
            When Id{
                return 'Id';
            }
            When Date{
                return 'Date';
            }
            When DateTime{
                return 'DateTime';
            }
            When Time{
                return 'Time';
            }
            When URL{
                return 'URL';
            }
            When Email{
                return 'Email';
            }
            When Phone{
                return 'Phone';
            }
            When Long{
                return 'Long';
            }
            When MultiPicklist{
                return 'MultiPicklist';
            }
            When EncryptedString{
                return 'EncryptedString';
            }
            When Reference{
                return 'Reference';
            }
            When Address{
                return 'Address';
            }
            When Combobox{
                return 'Combobox';
            }
            When Currency{
                return 'Currency';
            }
            When Location{
                return 'Location';
            }
            When TextArea{
                return 'TextArea';
            }
            when else{
                return '';
            }
        }
    }
    
    public static List<String> getUtilityItems(){
        List<String> utilityFieldList=new List<String>();
        for(Sustain_MigrationWizardMetaData__mdt mdt :[select Sustain_MetaDataName__c from Sustain_MigrationWizardMetaData__mdt]){
            utilityFieldList.add(mdt.Sustain_MetaDataName__c);
        }
        return utilityFieldList;
    }
    public static Map<String,Sustain_FuelTypeInformation__mdt> getFuelTypeConsumptionMdt(String objAPI){
        Map<String,Sustain_FuelTypeInformation__mdt> fieldFuelTypeMap=new Map<String,Sustain_FuelTypeInformation__mdt>();
        for(Sustain_FuelTypeInformation__mdt mdt :[select Parent_Total_Field__c,Field_Unit__c,Fuel_Type__c,Field_Name__c from Sustain_FuelTypeInformation__mdt where Object_Name__c=:objAPI]){
            fieldFuelTypeMap.put(mdt.Field_Name__c,mdt);
        }
        return fieldFuelTypeMap;
    }
    public static Map<String,Sustain_PicklistMigration__mdt> getPickListTrnsfrmMdt(){
        Map<String,Sustain_PicklistMigration__mdt> fieldFuelTypeMap=new Map<String,Sustain_PicklistMigration__mdt>();
        for(Sustain_PicklistMigration__mdt mdt :[select Sustain_Source_Value__c,Sustain_Target_Value__c  from Sustain_PicklistMigration__mdt]){
            fieldFuelTypeMap.put(mdt.Sustain_Source_Value__c,mdt);
        }
        return fieldFuelTypeMap;
    }
    public static Map<String,Sustain_PicklistMigration__mdt> gettransfromPickListValsMdt(){
        Map<String,Sustain_PicklistMigration__mdt> fieldFuelTypeMap=new Map<String,Sustain_PicklistMigration__mdt>();
        for(Sustain_PicklistMigration__mdt mdt :[select Sustain_Source_Value__c,Sustain_Target_Value__c,Source_Record_Type__c,Source_Field_Name__c,Target_Object_Name__c  from Sustain_PicklistMigration__mdt]){
            String str = mdt.Target_Object_Name__c + mdt.Source_Field_Name__c ; 
            str+= (String.isNotBlank(mdt.Source_Record_Type__c) &&  mdt.Source_Record_Type__c !=Sustain_UtilConstants.masterLabel) ? mdt.Source_Record_Type__c : '';
            str+=mdt.Sustain_Source_Value__c;
            System.debug('key is '+str);
            fieldFuelTypeMap.put(str,mdt);
        }
        return fieldFuelTypeMap;
    }
}