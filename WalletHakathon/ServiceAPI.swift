//
//  ServiceAPI.swift
//  WalletHakathon
//
//  Created by Андрей on 25.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import SwiftyJSON

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

    static func getDefaultClassResult(dictionary: Dictionary<String, String>, requestString: String, noncompletedHandler: @escaping(String) -> Void, completedHandler: @escaping() -> Void) {
        
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
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler, completedHandler: completedHandler)
        } else {
            noncompletedHandler("token error")
        }
    }
    
    static func registerUser(phone: String, name: String, password: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        var dictionary: [String: String] = [:]
        dictionary["phone"] = phone
        dictionary["name"] = name
        dictionary["hashpsd"] = md5(password)
        
        let requestStr = serverAddress + "/user/reg"
        
        ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler, completedHandler: completionHandler)
    }
    
    static func loginUser(phone: String, password: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        var dictionary: [String: String] = [:]
        dictionary["phone"] = phone
        dictionary["hashpsd"] = md5(password)
        
        let requestStr = serverAddress + "/user/log"
        
        ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler, completedHandler: completionHandler)
    }
    
    private static func md5(_ string: String) -> String {
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
}
