//
//  ServiceAPI.swift
//  WalletHakathon
//
//  Created by Андрей on 25.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//
import UIKit
import SwiftyJSON

let serverAddress = "http://walletmsg.azurewebsites.net/api"

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
    
    static func getDefaultClassResult(dictionary: Dictionary<String, String>, requestString: String, noncompletedHandler: @escaping(String) -> Void, completedParser: @escaping(JSON) -> Void) {
        
        RequestSender.sendRequest(requestString: requestString, params: dictionary) {
            (data, error) in
            JSONParser.checkJSONWithDefaultClass(data: data, error: error, nonCompleteHandler: noncompletedHandler) {
                (json) in
                completedParser(json)
            }
        }
    }
    
    static func changePsd(last: String, new: String, completedHandler: @escaping() -> Void, noncompletedHandler: @escaping(String) -> Void) {
        if var dictionary = ServiceAPI.loadDictionary() {
            dictionary["last"] = last
            dictionary["new"] = new
            
            let requestStr = serverAddress + "/user/chpsd"
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) {
                (json) in
                
                
            }
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
        
        ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) { (json) in
            print(json)
            if let token = json["defaultClass"]["token"].string, let userID = json["userID"].int {
                UserDefaults.standard.set(token, forKey: "token")
                UserDefaults.standard.set(userID, forKey: "appUserId")
            }
            completionHandler()
        }
    }
    
    static func loginUser(phone: String, password: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        var dictionary: [String: String] = [:]
        dictionary["phone"] = phone
        dictionary["hashpsd"] = md5(password)
        
        let requestStr = serverAddress + "/user/log"
        
        ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) { (json) in
            print(json)
            if let token = json["defaultClass"]["token"].string, let userID = json["userID"].int {
                UserDefaults.standard.set(token, forKey: "token")
                UserDefaults.standard.set(userID, forKey: "appUserId")
            }
            completionHandler()
        }
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
    
    
    static func getConversations(noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        
        let coreDataService = CoreDataService.sharedInstance
        
        if let dictionary = loadDictionary() {
            let request = serverAddress + "/conv/gets"
            
            print("Getting conversations")
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                let dialogs = json["dialogs"]
                
                for (index, subJSON):(String, JSON) in dialogs {
                    print(subJSON)
                
                    let user = subJSON["userProfile"]
                    
                    guard let conversationID = subJSON["dialogID"].int, let balance = subJSON["balance"].double,
                    let name = user["name"].string, let phone = user["phone"].string, let image = user["image"].string, let userID = user["userID"].int else {
                        noncompletedHandler("Неверный JSON")
                        return
                    }
                    
                    let avatar = Data(base64Encoded: image)
                    if let mobilePhone = Int(phone){
                        coreDataService.insertConversation(userID: userID, conversationID: conversationID, name: name, mobilePhone: mobilePhone, balance: balance, avatar: avatar)
                    } else {
                        noncompletedHandler("Неверный формат телефона")
                    }
                }
            }
            
            completionHandler()
        }
    }
    
    static func createDialog(phoneNumber: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        
        let coreDataService = CoreDataService.sharedInstance
        
        if var dicionary = loadDictionary() {
            dicionary["phone"] = phoneNumber
            
            let request = serverAddress + "/dialog/create"
            
            let requestPhone = serverAddress + "/user/getubyphn"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: requestPhone, noncompletedHandler: noncompletedHandler) { (json) in
                guard let name = json["name"].string, let balance = json["balance"].double,
                    let phoneStr = json["phone"].string, let phone = Int(phoneStr), let userID = json["userID"].int else {
                        noncompletedHandler("Неверный формат JSON")
                        return
                }
                
                var avatar: Data? = nil
                if let image = json["image"].string {
                    avatar = Data(base64Encoded: image)
                }
                
                ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                    
                    guard let conversationID = json["ID"].int else {
                        noncompletedHandler("Неверный формат JSON при создании диалога")
                        return
                    }
                    
                    coreDataService.insertConversation(userID: userID, conversationID: conversationID, name: name, mobilePhone: phone, balance: 0.0, avatar: avatar)
                    
                    
                    completionHandler()
                }
                
            }
            
            
        }
    }
    
    static func getByPhone(phoneNumber: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["phone"] = phoneNumber
            
            let request = serverAddress + "/user/getubyphn"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    static func getDialogInfo(dialogID: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        
        let coreDataService = CoreDataService.sharedInstance
     
        if var dicionary = loadDictionary() {
            dicionary["dialogID"] = dialogID
            
            let request = serverAddress + "/dialog/get"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                guard let transactionID = json["transactionID"].int, let dateString = json["date"].string,
                    let text = json["text"].string, let money = json["money"].double, let cash = json["isCash"].bool, let userID = json["userID"].string else {
                        noncompletedHandler("Неверный формат JSON")
                        return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: dateString)
                
                coreDataService.findUserBy(id: userID)
                
                //coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: <#T##Conversation?#>, group: nil, reciver: <#T##User?#>, sender: <#T##User?#>)
                
                completionHandler()
            }
        }
    }
    
    public static func alert(viewController: UIViewController, title: String = "Ошибка!", desc: String) {
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
}
