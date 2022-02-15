public without sharing class Sustain_FieldMappingTriggerHandler {
    private static final string CurrentClassName = 'Sustain_FieldMappingTriggerHandler';
    public static void updateMigrationStatus(List<Field_Mappings__c> fieldMappingList, Map<Id,Field_Mappings__c> oldMap){
        string CurrentMethodName = 'updateMigrationStatus';
        try{
        boolean temp = false;
        for(Field_Mappings__c fm : fieldMappingList ) {
            system.debug('fm.New_Field__c'+fm.New_Field__c);
            if(oldMap != null && fm.New_Field__c != oldMap.get(fm.Id).New_Field__c && fm.New_Field__c == true ){
                fm.Target_Field_Label__c = fm.Source_Field_Label__c;
                fm.Target_Field__c = fm.Source_Field__c;
                fm.Target_Field_Type__c = fm.Source_Field_Type__c;
                temp = true;
                //break;
            }
        } 
            system.debug('temp-->'+temp);
        if(temp == true){
            Migration_Status__c mig = Migration_Status__c.getOrgDefaults();
            mig.Metadata_Created__c = false;
            update mig;
        }
        }catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
    }
}