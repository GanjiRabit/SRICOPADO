public class WebProduct {

@AuraEnabled
public String model;

@AuraEnabled
public String brand;

//Because the identifiers information is an array in the JSON schema, we create a separate class called Identifiers and define a property that contains a List.
@AuraEnabled
public List<Identifiers> identifiers;

//This field has an Apex-defined data type in the Price Apex class.
@AuraEnabled
public Price price;

//This method is used as part of the Create Apex Action section.
public static WebProduct parse(String json) {
return (WebProduct) System.JSON.deserialize(json, WebProduct.class);
}
}