/**
 * @description       : 
 * @author            : Accenture
 * @group             : 
 * @last modified on  : 02-01-2022
 * @last modified by  : Accenture
**/
global class Sustain_CreateVendorRecordBatch implements Database.Batchable<sObject>,Database.Stateful {

    public Set<String> euRecordTypes = new Set<String>();
    public Integer currentEURecordTypeNo; 
    public List<String> userEmails; 
    public String orgIDS; 
    public Boolean noErrorExist = true;
    public static final string CurrentClassName = 'Sustain_CreateVendorRecordBatch';   
    
    public Sustain_CreateVendorRecordBatch(Integer energyUseRecordTypeNo, List<String> userEmails, String orgIDS){
        this.currentEURecordTypeNo = energyUseRecordTypeNo;  
        this.userEmails = userEmails;
        this.orgIDS = orgIDS;       
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {               
        String currentEURecordType = Sustain_UtilConstants.EURecordTypesMap.get(currentEURecordTypeNo);
        String query = 'SELECT id,Name,RecordType.Name,sustain_app__VendorName__c from sustain_app__EnergyConsumption__c where sustain_app__VendorName__c != null AND RecordType.DeveloperName =:currentEURecordType';
        return Database.getQueryLocator(query);
    }
    
    // Execute method
    global void execute(Database.BatchableContext BC, List<sustain_app__EnergyConsumption__c> scope) {
        string CurrentMethodName = 'execute';
        try{
            
            List<Vendor__c> insertResultLst = new List<Vendor__c>();
            
            system.debug('value of scope>>>'+scope);
            
            Set<String> VendorSet = new Set<String>();
            Set<String> vendorNames = new Set<String>();
            
            for(sustain_app__EnergyConsumption__c eurData : scope){
                system.debug('value of eurData.RecordTypeName >>'+eurData.RecordType.Name);
                system.debug('value of eurData.sustain_app__VendorName__c >>'+eurData.sustain_app__VendorName__c);
                VendorSet.add(eurData.sustain_app__VendorName__c);                
            }
            system.debug('value of vendor set >>>>>>>'+VendorSet);                
            
            for(Vendor__c ven: [select Id, Name, Vendor_Name__c from Vendor__c where Vendor_Name__c IN: vendorSet ]){
                vendorNames.add(ven.Vendor_Name__c);
            }
            
            for(sustain_app__ServiceProvider__c sup: [select Id, Name from sustain_app__ServiceProvider__c where Name IN: vendorSet ]){
                vendorNames.add(sup.Name);
            }
                        
            for(String venName: VendorSet){
                if(!vendorNames.contains(venName)){
                    Vendor__c vendor = new Vendor__c();
                    vendor.Vendor_Name__c = venName;
                    insertResultLst.add(vendor);
                    system.debug('value of vendor rec>>>>>>>'+insertResultLst);
                }
            }
            
            if(!insertResultLst.isEmpty()){
                database.insert(insertResultLst);
            }
            
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
            noErrorExist = false;
        }
    }
    
    global void finish(Database.BatchableContext BC) {        
        System.debug('currentEURecordTypeNo '+currentEURecordTypeNo);
        string CurrentMethodName = 'finish';
        try{
            if(Sustain_UtilConstants.EURecordTypesMap.containsKey(currentEURecordTypeNo+1)){
                Sustain_CreateVendorRecordBatch nextcustBatch = new Sustain_CreateVendorRecordBatch(currentEURecordTypeNo+1, userEmails, orgIDS);
                database.executeBatch(nextcustBatch, 1000);
            } else{
                List<Object_Mappings__c> objMaptobeUpdate = new List<Object_Mappings__c>();
                // Get those records based on the IDs
                for(Object_Mappings__c oMap:[select id,Source_Record_Type__c,Source_Object__c,Target_Object__c from Object_Mappings__c where Source_Object__c = 'Vendor__c']){
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
            
                Migration_Status__c ms = Migration_Status__c.getInstance(orgIDs);
                if(ms==null){
                    ms = new Migration_Status__c();                              
                }
                ms.Current_Migration_Stage__c   = 'Org Data Scan Output'; 
                ms.Ready_To_Launch__c = false;
                ms.MetaData_Created__c = false;
                ms.VendorRecordStatus__c = noErrorExist;
                upsert ms;
                
                Sustain_SendNotification sendData =new Sustain_SendNotification();
                sendData.sendEmailNotification('Sustain_VendorRecordsEmail',userEmails);
            }
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
            noErrorExist = false;
            Sustain_SendNotification sendData =new Sustain_SendNotification();
            sendData.sendEmailNotification('Sustain_VendorRecordsErrorEmail',userEmails);
        }
    }
}