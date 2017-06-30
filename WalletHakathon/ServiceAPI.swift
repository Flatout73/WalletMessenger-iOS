//
//  ServiceAPI.swift
//  WalletHakathon
//
//  Created by –Р–љ–і—А–µ–є on 25.06.17.
//  Copyright ¬© 2017 HSE. All rights reserved.
//
import UIKit
import SwiftyJSON

let serverAddress = "http://walletmsg.azurewebsites.net/api"
//let serverAddress = "http://localhost:8080"

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
                
                CoreDataService.sharedInstance.createAppUser(phone: Int(phone)!, name: name, id: userID, avatar: nil)
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
            if let token = json["defaultClass"]["token"].string, let userID = json["userID"].int, let name = json["name"].string {
                UserDefaults.standard.set(token, forKey: "token")
                UserDefaults.standard.set(userID, forKey: "appUserId")
                
                var avatar: Data?
                if let image = json["image"].string {
                    avatar = Data(base64Encoded: image)
                }
                
                CoreDataService.sharedInstance.createAppUser(phone: Int(phone)!, name: name, id: userID, avatar: avatar)
            } else {
                noncompletedHandler("–Э–µ–≤–µ—А–љ—Л–є JSON")
                return
            }
            completionHandler()
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
    
    static func changeName(name: String, completedHandler: @escaping() -> Void, noncompletedHandler: @escaping(String) -> Void) {
        if var dictionary = ServiceAPI.loadDictionary() {
            dictionary["name"] = name
            
            let requestStr = serverAddress + "/user/chname"
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) {
                (json) in
                
                
            }
        } else {
            noncompletedHandler("token error")
        }
    }
    
    //фото тип string пока стоит
    static func changePhoto(photo: String, completedHandler: @escaping() -> Void, noncompletedHandler: @escaping(String) -> Void) {
        if var dictionary = ServiceAPI.loadDictionary() {
            dictionary["photo"] = photo
            
            let requestStr = serverAddress + "/user/chphoto"
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) {
                (json) in
                
                
            }
        } else {
            noncompletedHandler("token error")
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
    
    //этого метда не будет, используйте код дл€ других
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
                            noncompletedHandler("–Э–µ–≤–µ—А–љ—Л–є JSON")
                            return
                    }
                    
                    let avatar = Data(base64Encoded: image)
                    if let mobilePhone = Int(phone){
                        coreDataService.insertConversation(userID: userID, conversationID: conversationID, name: name, mobilePhone: mobilePhone, balance: balance, avatar: avatar)
                    } else {
                        noncompletedHandler("–Э–µ–≤–µ—А–љ—Л–є —Д–Њ—А–Љ–∞—В —В–µ–ї–µ—Д–Њ–љ–∞")
                    }
                }
                
                completionHandler()
            }
        }
    }
    
    //здесь получение диалогов и групп отдельно + истори€
    
    static func getDialogs(noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            
            let request = serverAddress + "/conv/getdialogs"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    static func getGroups(noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if let dicionary = loadDictionary() {
            
            let request = serverAddress + "/conv/getgroups"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    //подгружает более старые диалоги в список диалогов (подавать меньшее значение в date)
    static func getDialogsHist(date: Int64, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["date"] = String(date)
            
            let request = serverAddress + "/conv/gethistdialogs"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    //подгружает более старые группы в список групп (подавать меньшее значение в date)
    static func getGroupsHist(date: Int64,noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["date"] = String(date)
            
            let request = serverAddress + "/conv/gethistgroups"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    //подтверждение транзакций
    static func acceptTransaction(transactionID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["transactionID"] = String(transactionID)
            
            let request = serverAddress + "/conv/accepttr"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    static func declineTransaction(transactionID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["transactionID"] = String(transactionID)
            
            let request = serverAddress + "/conv/declinetr"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    //Dialog Controller
    
    static func getDialogInfo(dialogID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        
        let coreDataService = CoreDataService.sharedInstance
        
        if var dicionary = loadDictionary() {
            dicionary["dialogID"] = String(dialogID)
            
            let request = serverAddress + "/dialog/get"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                guard let transactionID = json["transactionID"].int, let dateLong = json["date"].int64,
                    let text = json["text"].string, let money = json["money"].double, let cash = json["isCash"].bool, let userID = json["userID"].int else {
                        noncompletedHandler("–Э–µ–≤–µ—А–љ—Л–є —Д–Њ—А–Љ–∞—В JSON")
                        return
                }
                
                //                let dateFormatter = DateFormatter()
                //                dateFormatter.dateFormat = "yyyy-MM-dd"
                //                let date = dateFormatter.date(from: dateString)
                
                let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                
                let user = coreDataService.findUserBy(id: userID)
                let conversation = coreDataService.findConversaionBy(id: dialogID)
                
                if(user?.userID == Int32(userID)) {
                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                } else {
                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                }
                
                completionHandler()
            }
        }
    }
    
    static func sendTransaction(dialogID: Int, money: Double, cash: Bool, text: String?, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        
        if var dicionary = loadDictionary() {
            dicionary["dialogID"] = String(dialogID)
            dicionary["money"] = String(money)
            dicionary["cash"] = cash ? "1": "0"
            dicionary["text"] = text ?? ""
            
            let request = serverAddress + "/dialog/sendtr"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                guard let date = json["date"].int64, let transactionID = json["id"].int else {
                    noncompletedHandler("–Э–µ–≤–µ—А–љ—Л–є —Д–Њ—А–Љ–∞—В JSON")
                    return
                }
                
                let conversation = CoreDataService.sharedInstance.findConversaionBy(id: dialogID)
                let user = conversation?.participant
                
                CoreDataService.sharedInstance.insertTransaction(id: transactionID, money: money, text: text ?? "", date: Date(timeIntervalSince1970: TimeInterval(date)), isCash: cash, conversation: conversation, group: nil, reciver: user, sender: CoreDataService.sharedInstance.appUser)
                
                completionHandler()
            }
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
                        noncompletedHandler("–Э–µ–≤–µ—А–љ—Л–є —Д–Њ—А–Љ–∞—В JSON")
                        return
                }
                
                var avatar: Data? = nil
                if let image = json["image"].string {
                    avatar = Data(base64Encoded: image)
                }
                
                ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                    
                    guard let conversationID = json["id"].int else {
                        noncompletedHandler("–Э–µ–≤–µ—А–љ—Л–є —Д–Њ—А–Љ–∞—В JSON –њ—А–Є —Б–Њ–Ј–і–∞–љ–Є–Є –і–Є–∞–ї–Њ–≥–∞")
                        return
                    }
                    
                    coreDataService.insertConversation(userID: userID, conversationID: conversationID, name: name, mobilePhone: phone, balance: 0.0, avatar: avatar)
                    
                    completionHandler()
                }
                
            }
            
            
        }
    }
    
    //без получени€ юзера по телефону
    static func createDialogWithUser(userID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        
        let coreDataService = CoreDataService.sharedInstance
        
        if var dicionary = loadDictionary() {
            dicionary["userID"] = String(userID)
            
            let request = serverAddress + "/dialog/create"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
            
        }
    }
    
    //историю транзакций подгрузит
    static func getDialogTransactions(transactionID: Int, dialogID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["transactionID"] = String(transactionID)
            dicionary["dialogID"] = String(dialogID)
            
            let request = serverAddress + "/dialog/gettransactions"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    
    //новые подгрузит
    static func getNewDialogTransactions(transactionID: Int, dialogID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["transactionID"] = String(transactionID)
            dicionary["dialogID"] = String(dialogID)
            
            let request = serverAddress + "/dialog/getnewtransactions"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    
    
    //Group Controller
    
    static func getGroupInfo(groupID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["groupID"] = String(groupID)
            
            let request = serverAddress + "/group/get"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    static func groupSendTransaction(receiverID: Int, groupID: Int, money: Double, cash: Bool, text: String?, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["receiverID"] = String(receiverID)
            dicionary["groupID"] = String(groupID)
            dicionary["money"] = String(money)
            dicionary["cash"] = cash ? "1": "0"
            dicionary["text"] = text ?? ""
            
            let request = serverAddress + "/group/sendtransaction"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    static func getGroupTransactions(groupID: Int, transactionID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["groupID"] = String(groupID)
            dicionary["transactionID"] = String(transactionID)
            
            let request = serverAddress + "/group/gettransactions"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    static func getNewGroupTransactions(groupID: Int, transactionID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["groupID"] = String(groupID)
            dicionary["transactionID"] = String(transactionID)
            
            let request = serverAddress + "/group/getnewtransactions"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    static func createGroup(name: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["name"] = name
            
            let request = serverAddress + "/group/create"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    
    static func createGroupWithUsers(name: String, phones: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["name"] = name
            dicionary["phones"] = phones
            
            //≈щЄ и сюда напишу на вс€кий случай про параметр phones
            //ќчень строгий формат строки! Ќикаких пробелов вообще! телефоны строго через зап€тую, в начале и в конце зап€тых нет:
            //ѕример: "8913,8150,4444,56774,12312124,0001" - без кавычек соответственно.
            
            let request = serverAddress + "/group/createwithusers"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    //только админ может добавл€ть (можете(!) сделать ќѕ÷»ќЌјЋ№Ќќ)
    //“ипо админ в настройках группы устанавливает все могут добавл€ть или ток он
    //на сервере проверки что это именно "админ" пытаетс€ удалить участника из группы нету
    static func groupAddUser(groupID: Int, phone: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["groupID"] = String(groupID)
            dicionary["phone"] = phone
            
            let request = serverAddress + "/group/add"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    //только админ может удал€ть (оп€ть же проверки на сервере что это именно "админ" пытаетс€ удалить участника из группы там нет)
    static func groupDelUser(groupID: Int, phone: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["groupID"] = String(groupID)
            dicionary["phone"] = phone
            
            let request = serverAddress + "/group/deluser"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    //выйти из беседы самосто€тельно
    static func groupQuit(groupID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["groupID"] = String(groupID)
            
            let request = serverAddress + "/group/quit"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    //удалить беседу
    static func groupDelGroup(groupID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["groupID"] = String(groupID)
            
            //мне тоже ненравитс€ что тут это называетс€ "leave", но переделывать не будем
            let request = serverAddress + "/group/leave"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    public static func alert(viewController: UIViewController, title: String = "–Ю—И–Є–±–Ї–∞!", desc: String) {
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
}
