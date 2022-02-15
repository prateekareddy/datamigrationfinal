/*****************************************************************************************************
@Name: Sustain_TestDateFactory
@author : Accenture ATCI (Gopal) 
@purpose: Created  class to hold all reusable methods and data related to test class
@created date (mm/dd/yyyy) :
******************************************************************************************************/

public Without Sharing class  Sustain_TestDataFactory {
    
    public static Object_Mappings__c createObjectMapping() {
        
        Object_Mappings__c obj = new Object_Mappings__c();
        obj.Source_Object__c= 'Test__c';
        obj.Target_Object__c = 'GeneratedWaste';
        obj.Source_Object_Label__c = 'Test';
        obj.Mapping_Included__c = true;
        obj.Source_Record_Type__c='reference';
        obj.Target_Record_Type__c='string';
        obj.Sequence_Number__c=4;
        obj.Status__c='Completed';
        return obj;
    }
    
    public static sustain_app__Asset__c createAsset() {
        
        sustain_app__Asset__c asset=new sustain_app__Asset__c();
        asset.Name='140 Mission St';
        asset.RecordTypeId   = Schema.SObjectType.sustain_app__Asset__c.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
        asset.sustain_app__AssetType__c='Business Travel';
        asset.sustain_app__BusinessRegion__c='AMER';
        asset.sustain_app__CBECSDivision__c='Pacific';
        asset.sustain_app__City__c='Fruita';
        asset.sustain_app__Country__c='US';
        asset.sustain_app__Description__c='Developer office';
        asset.sustain_app__FacilityId__c='XXC-445112';
        asset.sustain_app__GreenBuildingCertified__c=false;
        asset.sustain_app__LeaseID__c='LID-P-4494';
        asset.sustain_app__Occupied_Building_Floor_Area_m2__c=46497.80893968;
        asset.sustain_app__Occupied_Building_Floor_Area_Unit__c='sqft';
        asset.sustain_app__Occupied_Building_Floor_Area__c=500498.25;
        asset.sustain_app__OwnedAsset__c=true;
        asset.sustain_app__State__c='CO';
        asset.sustain_app__StreetAddress__c='45 Main St';
        asset.sustain_app__TotalBuildingFloorAreaUnit__c='sqft';
        asset.sustain_app__TotalBuildingFloorArea__c=667331.0;
        asset.sustain_app__ZipCode__c=  '94106';
        
        return asset;
        
    }
    
    public static sustain_app__EnergyConsumption__c createEnergyConsumption() {
        
        sustain_app__EnergyConsumption__c asset=new sustain_app__EnergyConsumption__c();
        asset.Name='140 Mission St';
        asset.RecordTypeId   = Schema.SObjectType.sustain_app__EnergyConsumption__c.getRecordTypeInfosByDeveloperName().get('Real_Estate_Facility').getRecordTypeId();
        asset.sustain_app__AllocatedRenewableEnergykWh__c=102680.0;
        asset.sustain_app__Cooling_Consumption_kWh__c=100;
        asset.sustain_app__Currency__c='USD';
        asset.sustain_app__Diesel_Consumption_kWh__c=10636.1;
        asset.sustain_app__Electricity_Consumption_kWh__c=175000.0;
        asset.sustain_app__EndDate__c   =system.today();
        asset.sustain_app__Fuel_Oil_Consumption_kWh__c=10751.81;
        asset.sustain_app__Heat_Consumption_kWh__c=29300.10 ;
        asset.sustain_app__kWhFromBiomassLocationBased__c=4900.0;
        asset.sustain_app__kWhFromBiomassMarketBased__c=45;
        asset.sustain_app__kWhFromBiomassMarketBased__c=2024.96;
        asset.sustain_app__kWhFromCoalLocationBased__c=29300.10 ;
        asset.sustain_app__kWhFromCoalMarketBased__c=4900.0;
        asset.sustain_app__kWhFromGasLocationBased__c=2024.96;  
        asset.sustain_app__kWhFromGasMarketBased__c=29300.10    ;
        asset.sustain_app__kWhFromGeothermalLocationBased__c=45;
        asset.sustain_app__kWhFromGeothermalMarketBased__c=2024.96;         
        asset.sustain_app__kWhFromHydroLocationBased__c=4900.0;
        asset.sustain_app__kWhFromHydroMarketBased__c=2024.96;         
        asset.sustain_app__kWhFromHydroMarketBased__c=29300.10  ;
        asset.sustain_app__kWhFromNonRenewablesLocationBased__c=2024.96;
        asset.sustain_app__kWhFromNonRenewablesMarketBased__c=29300.10  ;
        asset.sustain_app__kWhFromNuclearLocationBased__c=2024.96;
        asset.sustain_app__kWhFromNuclearMarketBased__c=29300.10    ;
        asset.sustain_app__kWhFromOtherFossilFuelLocationBased__c=2024.96;
        asset.sustain_app__kWhFromOtherFossilFuelMarketBased__c=29300.10    ;
        asset.sustain_app__kWhFromOtherFuelLocationBased__c=4900.0;
        asset.sustain_app__kWhFromOtherFuelMarketBased__c=2024.96;         
        asset.sustain_app__kWhFromSolarLocationBased__c=2024.96;
        asset.sustain_app__kWhFromSolarMarketBased__c=29300.10  ;
        asset.sustain_app__kWhFromWindLocationBased__c=2024.96;
        asset.sustain_app__kWhFromWindMarketBased__c=29300.10   ;
        asset.sustain_app__Mobile_Fuel_Type__c='Diesel';         
        asset.sustain_app__Month_Year__c=system.today();
        asset.sustain_app__Normalized_Monthly_Electricity_Use_kWh__c=2024.96;
        asset.sustain_app__Occupied_Building_Floor_Area_m2__c=2024.96;
        asset.sustain_app__Occupied_Building_Floor_Area_Unit__c='sqft';         
        asset.sustain_app__Occupied_Building_Floor_Area__c=2024.96;
        asset.sustain_app__Refrigerant_Emissions_tCO2e__c=2024.96;
        asset.sustain_app__Reported_PUE__c=1;
        asset.sustain_app__Scope2LocationBasedEmissionsTCO2e__c=2024.96;
        asset.sustain_app__Scope_1_Emissions_tCO2e__c=2024.96;         
        asset.sustain_app__Scope_2_Market_Based_Emissions_tCO2e__c=2024.96;
        
        asset.sustain_app__Segment_Distance_Unit__c='Kilometers';         
        asset.sustain_app__Steam_Consumption_kWh__c=146500.5;
        asset.sustain_app__System_Generated__c=true;         
        asset.sustain_app__TotalBuildingFloorAreaUnit__c='sqft';
        asset.sustain_app__TotalBuildingFloorArea__c=2024.96;         
        asset.sustain_app__TotalRenewableEnergykWhWithoutHydro__c=2024.96;
        asset.sustain_app__Total_Electricity_Consumption__c=12; 
        asset.sustain_app__Total_Renewable_Energy_kWh__c=2024.96;         
        asset.sustain_app__TypeOfRenewableEnergyProject__c='Solar';
        asset.sustain_app__Unit_Cooling_Consumption__c='kWh';
        asset.sustain_app__Unit_Diesel_Consumption__c='Liters';
        asset.sustain_app__Unit_Electricity_Consumption__c='kWh';
        asset.sustain_app__Unit_Fuel_Oil_Consumption__c='Liters';
        asset.sustain_app__Unit_Heat_Consumption__c ='Therms';
        
        asset.sustain_app__Unit_IT_Electricity_Consumption__c='kWh';
        asset.sustain_app__Unit_Natural_Gas_Consumption__c='Therms';
        asset.sustain_app__Unit_Propane_Consumption__c='propane_kWh';
        asset.sustain_app__Unit_Steam_Consumption__c='Therms';
        asset.sustain_app__Value_Cooling_Consumption__c =100.0;
        asset.sustain_app__Value_Diesel_Consumption__c  =100.0;
        asset.sustain_app__Value_Electricity_Consumption__c =100.0;
        asset.sustain_app__Value_Fuel_Oil_Consumption__c    =100.0;
        asset.sustain_app__Value_Heat_Consumption__c    =100.0;
        asset.sustain_app__Value_Natural_Gas_Consumption__c =100.0;
        asset.sustain_app__Value_Steam_Consumption__c   =100.0;
        return asset;
    }
    
    
    public static Field_Mappings__c  createFieldMapping() { 
        Field_Mappings__c objF = new Field_Mappings__c();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_datetime__c';
        objF.Source_Field_Type__c = 'DateTime';
        objF.Source_Field_Label__c = 'test datetime';
        objF.Required__c = true;
        return objF;
    }
    public static Data_Load_Request__c createDataLoadRequest(){
        Data_Load_Request__c dLReq= new Data_Load_Request__c();
        dLReq.Request_Job_Name__c= 'Complete Data Load';
        dLReq.Status__c='Completed';
        return dLReq;
    }
    public static User createAdmninUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'newUser', Email='aforce@aforceorg.com',
                           EmailEncodingKey='UTF-8', LastName='aforce', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='aforce@aforceorg.com');
        return u1;
    } 
    
    public static sustain_app__ConsumptionReport__c createCarbonFootPrnt() {
        sustain_app__ConsumptionReport__c carbonFt = new sustain_app__ConsumptionReport__c();
        carbonFt.name = 'Rental Cars - All Org - FY20';
        carbonFt.RecordTypeId    = Schema.SObjectType.sustain_app__ConsumptionReport__c.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
        carbonFt.sustain_app__AuditApprovalStatus__c = 'Approved';
        carbonFt.sustain_app__Carbon_Source_Approved__c = false;
        carbonFt.sustain_app__ReportingYear__c = '2020';
        carbonFt.sustain_app__Reporting_Date__c = system.today();
        carbonFt.sustain_app__Scope3BusinessTravelEnergyUse__c = 33.953117267   ;
        carbonFt.sustain_app__Stage__c = 'Finished';
        carbonFt.sustain_app__TotalBuildingFloorAreaUnit__c = 'sqft';
        carbonFt.sustain_app__TotalScope3EmissionstCO2e__c = 33.953117267;
        carbonFt.sustain_app__Travel_Type__c = 'Rental Cars';
        return carbonFt;
    }
    public static sustain_app__Contact__c createContact() {
        
        sustain_app__Contact__c contact=new sustain_app__Contact__c();
        contact.Name='Sonali Agarwhal';
        contact.sustain_app__Contact_Notes__c='Has no access to data center info';
        contact.sustain_app__Department__c='    DC-Operations';
        contact.sustain_app__Email__c=' sonali@nomail.demo';
        contact.sustain_app__Phone__c=' (303) 883-1112';
        contact.sustain_app__Title__c='Manager';
        return contact;
    }
    
    
    
    public static sustain_app__Contract__c createContract() {
        
        sustain_app__Contract__c contract=new sustain_app__Contract__c();
        contract.Name='L-Mass LLC SO-4 FY21';
        contract.sustain_app__Contract_Type__c='Utility Renewable Energy Tariff';
        contract.sustain_app__Renewable_Energy_Project_Type__c='Solar';
        
        return contract;
    }
    
    
    public static sustain_app__EmissionFactorElectricity__c createElectricity() {
        
        sustain_app__EmissionFactorElectricity__c electricity=new sustain_app__EmissionFactorElectricity__c();
        electricity.Name='CAMX - eGRID2018';
        electricity.sustain_app__EmissionFactorUpdateYear__c='2018';
         electricity.sustain_app__CH4_Unit__c='lbs / GWh';
        electricity.sustain_app__CO2e_MarketBasedTotal_Unit__c='lbs / GWh';
        electricity.sustain_app__N2O_Unit__c='lbs / GWh';
        electricity.sustain_app__CO2_Unit__c='lbs / GWh';
        electricity.sustain_app__CO2e_Total_Unit__c='lbs / GWh';
        electricity.sustain_app__Country2__c='US';
        electricity.sustain_app__SubRegion__c='CAMX';
        electricity.sustain_app__RevisionDate__c=system.today();
        electricity.sustain_app__DataSource__c='https://www.epa.gov/energy/emissions-generation-resource-integrated-database-egrid';
        electricity.sustain_app__USZipCodes__c='00012;00016;00017;00018;00019;00020;00022;00026;00028;00029;00031;00032;00033;00037';
  

        electricity.sustain_app__OtherFuelMixMarketBased__c= 100.0;
  
        electricity.sustain_app__OtherUnknownPurchasedFuelMix__c=100.0;
        return electricity;
    }      
    
    
    public static sustain_app__EmissionFactorOther__c createOther() {
        
        sustain_app__EmissionFactorOther__c other=new sustain_app__EmissionFactorOther__c();
        other.Name='General Conversion Factors';
        other.RecordTypeId   = Schema.SObjectType.sustain_app__EmissionFactorOther__c.getRecordTypeInfosByDeveloperName().get('Refrigerants').getRecordTypeId();
        other.sustain_app__Cooling_CO2e_Factor_tCO2e_MWh__c=0.25212;
        other.sustain_app__Diesel_CH4_Factor_g_mmBtu__c=0.25212;
        other.sustain_app__Diesel_CO2_Factor__c=0.25212;
        other.sustain_app__Diesel_N2O_Factor_g_mmBtu__c=0.25212;
        other.sustain_app__Fuel_Oil_CH4_Factor_g_mmBtu__c=0.25212;
        other.sustain_app__Fuel_Oil_CO2_Factor_kg_mmBtu__c=0.25212;
        other.sustain_app__Fuel_Oil_N2O_Factor_g_mmBtu__c=0.25212;
        other.sustain_app__GWP_CH4__c=0.25212;
        other.sustain_app__GWP__c=0.25212;
        other.sustain_app__GWP_N2O__c=0.25212;
        other.sustain_app__Heating_CO2e_Factor_tCO2e_MWh__c=0.25212;
        
        other.sustain_app__jet_fuel_co2_factor_g__c=0.25212;
        other.sustain_app__jet_fuel_n2o_factor_g_gal__c=0.25212;
        other.sustain_app__Natural_Gas_Cal_Conversion_kWh_m3__c=0.25212;
        other.sustain_app__Natural_Gas_CH4_Factor_g_mmBtu__c=0.25212;
        
        other.sustain_app__Natural_Gas_N2O_Factor_g_mmBtu__c=0.25212;
        other.sustain_app__Natural_Gas_CO2_Factor__c=0.25212;
        other.sustain_app__Propane_CH4_Factor__c=   0.01023642489;
        
        other.sustain_app__Propane_CO2_Factor__c=   0.214521;
        other.sustain_app__Propane_N2O_Factor__c    =0.002047284978;
        other.sustain_app__RefrigerantLeakageRatekgITkWh__c =1.6;
        other.sustain_app__RefrigerantLeakageRatekgM2__c    =0.002153;
        other.sustain_app__RefrigerantLeakageRatekgSqft__c  =2.000202;
        other.sustain_app__Steam_CH4_Factor_g_mmBtu__c= 1.25;
        
        other.sustain_app__Steam_CO2_Factor_kg_mmBtu__c =66.33;
        other.sustain_app__Steam_N2O_Factor_g_mmBtu__c= 0.13;
        other.sustain_app__Data_Source__c=' https://www.gov.uk/government/collections/government-conversion-factors-for-company-reporting;https://www.epa.gov/sites/production/files/2018-03/documents/emission-factors_mar_2018_0.pdf';
        other.sustain_app__Emission_Factor_Update_Year__c   ='2018';
        return other;
    }      
    
    public static sustain_app__ServiceProvider__c createProvider() {
        
        sustain_app__ServiceProvider__c provider=new sustain_app__ServiceProvider__c();
        provider.Name='Xcel Energy';
        return provider;
    }
    
    
    
    
    
    
}