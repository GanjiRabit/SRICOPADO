/*  Copyright [2018] [salesforce.com]
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
/**
 * @description
 **/
public with sharing class IBot_CryptoService implements IBot_ServiceInterface{
    private static IBot_CryptoService  cryptoService = new IBot_CryptoService ();
	private static String cryptoKey = '';
	//read cryptokey from secret store. A managed package store for secrets and tokens

    /*
        private constructor to make a singleton instance
     */
    private IBot_CryptoService () {
    }

    /*
     * Static method that returns singleton instance.
     */
    public static IBot_CryptoService getInstance() {
        return cryptoService;
    }
	public String encryptAndEncode64(String toEncrypt) {
		if(String.isBlank(cryptoKey))
			return toEncrypt;

		Blob cryptoKey = EncodingUtil.base64Decode(cryptoKey);
		Blob data2encrypt = Blob.valueOf(toEncrypt);
		Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data2encrypt);
		String cryptData = EncodingUtil.base64Encode(encryptedData);
		return cryptData;
	}

	public String decryptAndDecode64(String toDecrypt) {
		if(String.isBlank(cryptoKey))
			return toDecrypt;

		Blob cryptoKey = EncodingUtil.base64Decode(cryptoKey);
		Blob data2decrypt = EncodingUtil.base64Decode(toDecrypt);
		Blob decryptedDataBlob = Crypto.decryptWithManagedIV('AES256', cryptoKey, data2decrypt);
		String decryptedData = decryptedDataBlob.toString();
		return decryptedData;
	}
}