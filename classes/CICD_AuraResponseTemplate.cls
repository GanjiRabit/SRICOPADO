public abstract class CICD_AuraResponseTemplate {
   public static string returnAuraResponse( Boolean isSuccess , Object response){
       Map<string,object> returnMessage = new Map<string, object>();
       returnMessage.put('isSuccess' , isSuccess);
       returnMessage.put('message' , response);

       return JSON.serialize(returnMessage);
    }
}