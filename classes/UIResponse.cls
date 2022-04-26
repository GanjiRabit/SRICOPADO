/**
 * @File Name          : AP52_Q2E_UIResponseTemplate.cls
 * @Description        : 
 * @Author             : Balaji C Garapati
 * @Group              : B5G Professional Services
 * @Last Modified By    : Balaji C Garapati
 * @Last Modified On    : 04/26/2020
 * @Modification Log    : 
 * Ver       Date            Author      		    Modification
 * 1.0      04/26/2020       Balaji C Garapati      Initial Version
**/
public abstract class UIResponse extends CommonServices{
    public static string prepareUIResponse( boolean isSuccess , object message){
        Map<String,object> response = new Map<string,object>();
        response.put( 'isSuccess' , isSuccess);
        response.put( 'message' , message);
        return JSON.serialize(response);
    }
}