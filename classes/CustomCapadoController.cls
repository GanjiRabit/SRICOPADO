public with sharing class CustomCapadoController {
    public CustomCapadoController() {

    }

    @AuraEnabled
    public static List<CustomCapadoController.capadoLicenseInfoWrp> getLicenseInformation(){
        copado.GlobalAPI obj = new copado.GlobalAPI();
        List<copado.GlobalAPI.UserLicense> capadolicenseList = obj.listCopadoLicenses();
        List<CustomCapadoController.capadoLicenseInfoWrp> resList = new List<CustomCapadoController.capadoLicenseInfoWrp>();
        for(copado.GlobalAPI.UserLicense item : capadolicenseList){
            CustomCapadoController.capadoLicenseInfoWrp objwrp = new CustomCapadoController.capadoLicenseInfoWrp(item);
            resList.add(objwrp);
        }
        return resList;
    } 

    public class capadoLicenseInfoWrp{
        @AuraEnabled
        public Boolean isCADenabled;
        @AuraEnabled
        public Boolean isCCHenabled;
        @AuraEnabled
        public Boolean isCCMenabled;
        @AuraEnabled
        public Boolean isCopadoEnabled;
        @AuraEnabled
        public Boolean isCSTenabled;
        @AuraEnabled
        public Id userId;

        public capadoLicenseInfoWrp(){

        }

        public capadoLicenseInfoWrp(copado.GlobalAPI.UserLicense item){
            this.isCADenabled = item.isCADenabled;
            this.isCCHenabled = item.isCCHenabled;
            this.isCCMenabled = item.isCCMenabled;
            this.isCopadoEnabled = item.isCopadoEnabled;
            this.isCSTenabled = item.isCSTenabled;
            this.userId = item.userId;

        }
    }
}