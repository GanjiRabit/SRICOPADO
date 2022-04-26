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
public with sharing class IBot_ServiceFactory {
	private static IBot_ServiceFactory sFactory = null;

	private IBot_ServiceFactory() {

	}

	public static IBot_ServiceFactory getInstance() {
		if (sFactory == null) {
			sFactory = new IBot_ServiceFactory();
		}
		return sFactory;
	}

	public IBot_ServiceInterface getService(String serviceName) {
		IBot_ServiceInterface service = null;
		if(String.isNotBlank(serviceName)) {
			if(serviceName.equals('TravelRequest')) {
				service = getTravelRequestService();
			} else if(serviceName.equals('LostCard')) {
				service = getLostCardService();
			} else if(serviceName.equals('Case')) {
				service = getCaseService();
			} else if(serviceName.equals('Crypto')) {
				service = getCryptoService();
			} else if(serviceName.equals('Dao')) {
				service = getDaoService();
			} else if(serviceName.equals('GenericEmail')) {
				service = getGenericEmailService();
			} else if(serviceName.equals('GenericMessaging')) {
				service = getGenericMessagingService();
			} else if(serviceName.equals('GenericTimebasedOTPAuth')) {
				service = getGenericTimebasedOTPService();
			}
            
		}
		return service;
	}

	private FscBot_TravelRequestService getTravelRequestService() {
		return FscBot_TravelRequestService.getInstance();
	}
    
    private FscBot_LostCardService getLostCardService() {
		return  FscBot_LostCardService.getInstance();
	}

	private IBot_CaseService getCaseService() {
		return IBot_CaseService.getInstance();
	}

	private IBot_CryptoService getCryptoService() {
		return IBot_CryptoService.getInstance();
	}

	private IBot_DaoService getDaoService() {
		return IBot_DaoService.getInstance();
	}

	private IBot_GenericEmailService getGenericEmailService() {
		return  IBot_GenericEmailService.getInstance();
	}

	private IBot_GenericMessagingService getGenericMessagingService() {
		return  IBot_GenericMessagingService.getInstance();
	}

	private IBot_GenericTimebasedOTPAuthService getGenericTimebasedOTPService() {
		return  IBot_GenericTimebasedOTPAuthService.getInstance();
	}   
}