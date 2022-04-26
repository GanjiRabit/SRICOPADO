//comments added and no sca run
Public Class AccountCreation
{
Public List<Account> CreateAccount(String s, String p){
List<Account> a = new List<Account>();
for(Account acc:a)
{
acc.Name=s;
acc.phone=p;
insert acc;
}
return a;
}
}