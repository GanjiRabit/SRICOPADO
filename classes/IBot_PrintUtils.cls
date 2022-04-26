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
public with sharing class IBot_PrintUtils {
	
	public static void print(String msg) {
		if(IBot_ConfigSettings.getInstance().isDebugEnabled()) {
		    System.debug('User Debug ' + msg);	
		}
	}
	
	public static void print(Object msg) {
		if(IBot_ConfigSettings.getInstance().isDebugEnabled()) {
		    System.debug('User Debug ' + String.valueOf(msg));	
		}
	}
	
	public static void print(String obj, String method, 	String msg) {
		if(IBot_ConfigSettings.getInstance().isDebugEnabled()) {
			System.debug('User Debug ' + '@Class ' + obj + ' @Method ' + method + ' @message: ' + msg);
		}
	}
}