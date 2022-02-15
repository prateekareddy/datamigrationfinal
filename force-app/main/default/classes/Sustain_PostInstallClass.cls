/***************************************************************************************************************
 * Name - Sustain_PostInstallClass 
 * Description - This class is used to create mappings on Install of managed package.
 * Author - Accenture (Bindhyachal)
 * Created Date - 9/13/2021
 * Last Modified By & Date - Accenture, 9/13/2021
 * ***************************************************************************************************************/
 
global without sharing class Sustain_PostInstallClass implements InstallHandler {
    global void onInstall(InstallContext context) {
        //calling post install script method to create mappings
        User u = [Select Id, Email from User where Id =:context.installerID()];   
        String toAddress= u.Email;
        String[] toAddresses = new String[]{toAddress};
        Sustain_CreateMigrationMapping.emailAdress = toAddresses;
        
        Sustain_CreateMigrationMapping.createObjectMapping('SustainDataMigration_ObjectMapping');                   
    }
}