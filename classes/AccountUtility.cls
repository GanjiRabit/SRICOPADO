public class AccountUtility {
    Public Static Void viewAnnualRevenue(){
        List<Account> accountsList= [SELECT Name, AnnualRevenue FROM Account];
        for (Account Acc: accountsList){
        String acctRev = 'Name: ' + Acc.Name + ', Annual Revenue : ' + Acc.AnnualRevenue;
            system.debug(acctRev);
        }
    }
}