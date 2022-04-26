public class Accountcreation2 {
    //comments added and no sca run
Public List<Account> CreateAccount(String s, String p){
List<Account> a = new List<Account>();
for(Account acc:a)
{
acc.Name=s;
acc.phone=p;
insert acc;
    //comments added and no sca run
}
return a;
}
}