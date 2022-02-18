/***************************************************************************************************************
* Name - Sustain_UpdateCustomObjectRelationship
* Description - This class is used to update all managed package relationship field if any exist.
* Author - Accenture (Bindhyachal)
* Created Date - 9/8/2021
* Last Modified By & Date - Accenture, 9/8/2021
* ***************************************************************************************************************/

public with sharing class Sustain_UpdateCustomObjectRelationship{
    private static final string CurrentClassName = 'Sustain_UpdateCustomObjectRelationship';    
    
    // This method is used to get all relationship field for managed package objects on custom object 
    public static List<Sobject> updateCustomObjectRecords(List<Sobject> sourceRecords, List<Field_Mappings__c> fieldMappings){ 
        string CurrentMethodName = 'updateCustomObjectRecords';
        try{
            Map<String, String> sourceVsTargetFieldMap = new Map<String, String>();
            String sobjectType;
            Set<String> sourceFields = new Set<String>();
            String targetRecId;
            
            for(Field_Mappings__c fm: fieldMappings){                    
                sourceVsTargetFieldMap.put(fm.Source_Field__c+fm.Reference_To__c, fm.Target_Field__c);            
            }
            
            for(Sobject rec: sourceRecords){
                for(Field_Mappings__c fm: fieldMappings){
                    if(rec.get(fm.Source_Field__c) != null){
                        SObject tempObj = rec.getSObject(fm.Source_Field__c.remove('__c')+'__r');
                        
                        String newSourceField = tempObj != null && tempObj.get('Target_SFDC_ID__c') != null ? (String) tempObj.get('Target_SFDC_ID__c') : '';
                        System.debug('newSourceField '+newSourceField);
                        if(!sourceFields.contains(fm.Source_Field__c) && newSourceField != null){
                            if(newSourceField.contains(',')){
                                List<Id> ids=newSourceField.split(',');
                                for(Id tempId : ids){
                                    sobjectType =tempId.getsobjecttype().getDescribe().getName();                      
                                    System.debug('sobjectType '+sobjectType);                         
                                    System.debug('tempId '+tempId);
                                    if(sourceVsTargetFieldMap.get(fm.Source_Field__c+sObjectType) != null){
                                        rec.put(sourceVsTargetFieldMap.get(fm.Source_Field__c+sObjectType), tempId);
                                        break;
                                    }
                                }
                            }else{
                                sObjectType = ((ID)newSourceField).getsobjecttype().getDescribe().getName();
                                if(sourceVsTargetFieldMap.get(fm.Source_Field__c+sObjectType) != null){
                                    rec.put(sourceVsTargetFieldMap.get(fm.Source_Field__c+sObjectType), newSourceField);                               
                                }
                            }
                            sourceFields.add(fm.Source_Field__c);
                        }  
                    }              
                    
                }
            }            
        }catch(Exception e){
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName); 
        }
        return sourceRecords;
    }
    
    // This method is used to get all relationship field for managed package objects on custom object 
    public static String getSOQLString(List<Field_Mappings__c> fieldMappings){ 
        string CurrentMethodName = 'getSOQLString';
        try {
            Set<String> sourceFields = new Set<String>();           
            String soqlStr = 'Select Id, Name';
            
            for(Field_Mappings__c fmap: fieldMappings){
                if(!sourceFields.contains(fmap.Source_Field__c)){
                    soqlStr = soqlStr + ',' + fmap.Source_Field__c;
                    soqlStr = soqlStr + ',' + fmap.Source_Field__c.remove('__c')+'__r.Target_SFDC_ID__c';
                    sourceFields.add(fmap.Source_Field__c);                
                }
            }
            
            soqlStr = soqlStr + ' from ' + fieldMappings[0].Object_Mapping__r.Source_Object__c;
            System.debug('soqlStr ' + soqlStr);
            return soqlStr;
            
        }catch(exception e) {
            Sustain_UtilityError.createErrorLog(e, CurrentClassName, CurrentMethodName);
        }
        return '';
         
    }
    
    // This method is used to get all custom object mappings 
    public static List<Object_Mappings__c> getCustomObjectMappingtoUpdate(){    
        return [Select Id, Name, Status__c,Batch_Size__c from Object_Mappings__c where Status__c = 'Not Started' AND Object_Type__c =:Sustain_UtilConstants.customLabel AND Mapping_Included__c = true order by Source_Object__c limit 1];       
    }
}