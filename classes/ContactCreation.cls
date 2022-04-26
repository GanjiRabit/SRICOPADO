public class ContactCreation {
Public List<Contact> CreateContact(String s, String p){
List<Contact> a = new List<Contact>();
for(Contact cont:a)
{
cont.LastName=s;
    insert cont;
    
}
return a;
}
}