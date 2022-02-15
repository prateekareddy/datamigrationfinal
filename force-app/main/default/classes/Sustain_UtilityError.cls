public with sharing class Sustain_UtilityError {
   // public Sustain_UtilityError(){}
    public static void createErrorLog(Exception e, String className, String methodName ){
        try{
           // String stackTrace = e.getStackTraceString().substringBefore('\n');
           // String className = stackTrace.substringAfter('Migration_Util.').substringBefore('.');  // updated by Karan to remove the namespace from Class name 
           // String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
            Error_Logs__c el=new Error_Logs__c(Apex_Class_Name__c=className,Method_Name__c=methodName,
                                               Error_Details__c=e.getMessage(),Line_Number__c=e.getLineNumber());
            Database.insert(el,false);
        }
        catch(Exception ex){
           throw new AuraHandledException('Error while creating error logs records');
        }
    }
}