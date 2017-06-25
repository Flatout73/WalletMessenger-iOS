//
//  ServiceAPI.swift
//  WalletHakathon
//
//  Created by Андрей on 25.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

let serverAddress = "http://localhost:8080"

class ServiceAPI: NSObject {

    static func loadDictionary() -> [String: String]? {
        var dictionary: [String: String] = [:]
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            dictionary = ["token": token]
        } else {
            return nil
        }
        return dictionary
    }

    static func getDefaultClassResult(dictionary: Dictionary<String, String>, requestString: String, completedHandler: @escaping() -> Void, noncompletedHandler: @escaping(String) -> Void) {
        
        RequestSender.sendRequest(requestString: requestString, params: dictionary) {
            (data, error) in
            JSONParser.checkJSONWithDefaultClass(data: data, error: error, nonCompleteHandler: noncompletedHandler) {
                (json) in
                completedHandler()
            }
        }
    }
    
    static func changePsd(last: String, new: String, completedHandler: @escaping() -> Void, noncompletedHandler: @escaping(String) -> Void) {
        if var dictionary = ServiceAPI.loadDictionary() {
            dictionary["last"] = last
            dictionary["new"] = new
            
            let requestStr = serverAddress + "/user/chpsd"
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, completedHandler: completedHandler, noncompletedHandler: noncompletedHandler)
        } else {
            noncompletedHandler("token error")
        }
    }
    
}
