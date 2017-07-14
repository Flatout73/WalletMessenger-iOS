//
//  DialogViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 24.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import CoreData

class DialogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, TableViewUpdateDelegate, UpdateTable {
    
    
    var fetchedResultsController: NSFetchedResultsController<Transaction>!
    
    var coreDataService = CoreDataService.sharedInstance
    var userPhoto:UIImage?
    var dialogID: Int!
    var phone: Int64!
    var name: String!
    
    var refreshControl: UIRefreshControl!
    
    var loadMoreStatus = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    func update(index: IndexPath) {
        DispatchQueue.main.async {
            try? self.fetchedResultsController.performFetch()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.tableView.reloadRows(at: [index], with: .top)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("id диалога: ", dialogID)
        
        tableView.delegate = self
        tableView.dataSource = self
        

        activityIndicator.hidesWhenStopped = true
        
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        
        tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
        fetchedResultsController = coreDataService.getFRCForTransactions(dialogID: dialogID)
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        } catch{
            print(error.localizedDescription)
        }
        
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Идет обновление...")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refreshControl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        tableView.addSubview(refreshControl)
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
//        
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.tabBarController?.tabBar.isHidden = true
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
//    func adjustForKeyboard(notification: Notification) {
//        let userInfo = notification.userInfo!
//        
//        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
//        
//        if notification.name == Notification.Name.UIKeyboardWillHide {
//            tableView.contentInset = UIEdgeInsets.zero
//            
//
//            
//            moneyField.isHidden = true
//            stepper.isHidden = true
//            goButton.isHidden = true
//        } else {
//            tableView.contentInset = UIEdgeInsets(top: keyboardViewEndFrame.height + 32, left: 0, bottom: 0, right: 0)
//            bottomConstraint.constant = keyboardViewEndFrame.height
//            
//            cancelButton.isEnabled = true
//        }
//        
//        tableView.scrollIndicatorInsets = tableView.contentInset
//        tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshControl.beginRefreshing()
        refresh(sender: self)
    }
    
    func refresh(sender: Any) {
        
        if (!loadMoreStatus) {
            self.loadMoreStatus = true
            
            refreshBegin { (x:Int) -> () in
                try? self.fetchedResultsController.performFetch()
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
                
                self.loadMoreStatus = false
            }
        } else {
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshBegin(refreshEnd:@escaping (Int) -> ()) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            if let this = self {
                
                ServiceAPI.getDialogInfo(dialogID: this.dialogID, noncompletedHandler: this.errorHandler) {
                    DispatchQueue.main.async {
                        refreshEnd(0)
                    }
                }
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset < 0 && currentOffset > 0 {
            loadMore()
        }
    }
    
    func loadMore() {
        if (!loadMoreStatus) {
            self.loadMoreStatus = true
            self.activityIndicator.startAnimating()
            self.tableView.tableFooterView?.isHidden = false
            loadMoreBegin(
                loadMoreEnd: {(x:Int) -> () in
                    
                    try! self.fetchedResultsController.performFetch()
                    self.tableView.reloadData()
                    self.loadMoreStatus = false
                    self.activityIndicator.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
            })
        }
    }
    
    func loadMoreBegin(loadMoreEnd:@escaping (Int) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            print("loadmore")
            
            //try? self.fetchedResultsController.performFetch()
            if(!self.fetchedResultsController.sections!.isEmpty) {
                if let sectionInfo = self.fetchedResultsController.sections?[0]{
                    if (sectionInfo.numberOfObjects > 0) {
                        print(sectionInfo.numberOfObjects)
                        let trans = self.fetchedResultsController.object(at: IndexPath(row: sectionInfo.numberOfObjects - 1, section: 0))
                        
                        ServiceAPI.getDialogTransactions(transactionID: Int(trans.transactionID), dialogID: self.dialogID, noncompletedHandler: self.errorHandler){
                            DispatchQueue.main.async  {
                                loadMoreEnd(0)
                            }
                        }
                    } else {
                        ServiceAPI.getDialogInfo(dialogID: self.dialogID, noncompletedHandler: self.errorHandler) {
                            DispatchQueue.main.async  {
                                loadMoreEnd(0)
                            }
                            
                        }
                    }
                    
                    
                    
                }
                
            }
        }
    }
    
    func errorHandler(error:String) {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
            self.loadMoreStatus = false
            self.tableView.tableFooterView?.isHidden = true
            ServiceAPI.alert(viewController: self, title: "Ошибка!", desc: error)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let count = fetchedResultsController.sections?.count {
            return count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(!fetchedResultsController.sections!.isEmpty) {
            if let sectionInfo = fetchedResultsController.sections?[section]{
                return sectionInfo.numberOfObjects
            } else {
                print("Unexpected Section")
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: MessageTableViewCell
        guard let section = fetchedResultsController.sections?[0] else {
            print("Нет такой секции")
            let c = tableView.dequeueReusableCell(withIdentifier: "toMe", for: indexPath) as! MessageTableViewCell
            c.sum.text = "error"
            return c
        }
        
        //let newIndexPath = IndexPath(row: section.numberOfObjects - indexPath.row - 1, section: indexPath.section)
        let transaction = fetchedResultsController.object(at: indexPath)
        
        if(transaction.sender!.userID == Int32(self.coreDataService.appUserID)) {
            cell = tableView.dequeueReusableCell(withIdentifier: "fromMe", for: indexPath) as! MessageTableViewCell
        } else{
            if(transaction.proof == 0 && transaction.isCash){
                cell = tableView.dequeueReusableCell(withIdentifier: "toMe", for: indexPath) as! MessageTableViewCell
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "toMeApproved", for: indexPath) as! MessageTableViewCell
            }
            
        }
        
        
        
        transaction.managedObjectContext?.performAndWait {[weak self] in
            if(transaction.isCash){
                if(transaction.proof == 1) {
                    //cell.hideButtons()
                    cell.makeIndicator(green: true)
                    cell.messView.layer.opacity = 1
                }else if (transaction.proof == -1){
                    //cell.hideButtons()
                    cell.makeIndicator(green: false)
                    cell.messView.layer.opacity = 0.5
                } else{
                    cell.indicator.backgroundColor = UIColor.yellow
                    cell.messView.layer.opacity = 0.5
                    cell.cellIndex = indexPath
                }
                cell.qiwiorNal.image = #imageLiteral(resourceName: "icon_money")
                
                
            } else{
                cell.qiwiorNal.image = #imageLiteral(resourceName: "qiwi_logo")
                //cell.hideButtons()
                cell.makeIndicator(green: true)
                cell.messView.layer.opacity = 1
            }
        }

        cell.cellIndex = indexPath
        cell.sender = transaction.sender
        cell.reciever = transaction.reciever
        cell.date = transaction.date as Date?
        cell.textInfo = transaction.text
        
        cell.userPhoto.image = #imageLiteral(resourceName: "no_photo")
        cell.sum.text = String(transaction.money) + " руб."
        cell.transText.text = transaction.text
        
        if let avatar = self.userPhoto {
            cell.userPhoto.image = avatar
        }
        
        if(!cell.isReversed){
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            cell.isReversed = true
        }
        
        cell.delegate = self
        cell.transactionID = Int(transaction.transactionID)
        
        return cell
    }
    
    
    
//    var isCash = true
//    @IBAction func sendMoney(_ sender: Any) {
    
        //messeges.insert("678", at: 0)
        //tableView.reloadData()
        
        
        //ServiceAPI.sendTransaction(dialogID: <#T##Int#>, money: <#T##Double#>, cash: <#T##Bool#>, text: <#T##String?#>, noncompletedHandler: <#T##(String) -> Void#>, completionHandler: <#T##() -> Void#>)
        
        //        DispatchQueue.main.async {[weak self] in
        //            if let this = self {
        //                let indexPath = IndexPath(row: this.messeges.count - 1, section: 0)
        //                this.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        //            }
        //        }
        
        
//        isCash = true
//        showStepper()
//    }
//    
//    var transactionQiwiID: Int64!
//    @IBAction func sendQiwi(_ sender: Any) {
//        isCash = false
//        transactionQiwiID = Int64(round(Date().timeIntervalSince1970))
//        showStepper()
//    }
    
    
//    func showStepper() {
//        tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
//        tableView.scrollIndicatorInsets = tableView.contentInset
//        
//        if(tableView.numberOfRows(inSection: 0) > 0){
//            tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
//        }
//        
//        moneyField.isHidden = false
//        stepper.isHidden = false
//        goButton.isHidden = false
//    }
//    
    var oldValue = 0.0
    
//    @IBAction func stepperChanged(_ sender: UIStepper) {
//        
//        if(moneyField.text == "") {
//            moneyField.text = "0.0"
//        }
//        
//        if(sender.value > oldValue){
//            moneyField.text = String(Double(moneyField.text!)! + 1)
//            
//        } else{
//            moneyField.text = String(Double(moneyField.text!)! - 1)
//        }
//        oldValue = sender.value
//        
//    }
    
//    func sendMoneyOnServer(_ sender: Any) {
//        
//        if (moneyField.text! != "") {
//            
//            activityIndicator.startAnimating()
//            if(!isCash){
//                ServiceAPI.sendMoneyQiwi(phoneToSend: phone, summa: Double(moneyField.text!)!, transactionID: transactionQiwiID, noncomplitedHandler: errorHandler) {
//                    
//                    ServiceAPI.sendTransaction(dialogID: self.dialogID, money: Double(self.moneyField.text!)!, cash: self.isCash, text: "Нет текста", noncompletedHandler: self.errorHandler) {
//                        
//                        self.updateTableForTransactions()
//                    }
//                }
//            } else {
//                
//                ServiceAPI.sendTransaction(dialogID: dialogID, money: Double(moneyField.text!)!, cash: isCash, text: "Нет текста", noncompletedHandler: errorHandler) {
//                    
//                    self.updateTableForTransactions()
//                }
//            }
//        }
//        
//        tableView.contentInset = UIEdgeInsets.zero
//        tableView.scrollIndicatorInsets = tableView.contentInset
//        
//        moneyField.isHidden = true
//        stepper.isHidden = true
//        goButton.isHidden = true
//        
//        self.view.endEditing(true)
//    }
    
    func updateTableForTransactions(){
        DispatchQueue.main.async {
            try? self.fetchedResultsController.performFetch()
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func cancelEditing(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SendTransactionTableViewController{
//            vc.groupId = groupID
//            vc.delegate = self
            vc.dialogID = dialogID
            vc.delegate = self
            vc.name = self.name
            vc.phone = self.phone.description
        } else if let vc = segue.destination as? TransactionTableViewController {
            if let cell = sender as? MessageTableViewCell {
                vc.transactionID = cell.transactionID
                vc.sender = cell.sender
                
                vc.reciever = cell.reciever
                
                vc.dateNumber = cell.date 
                vc.info = cell.textInfo
                
                vc.summa = cell.sum.text
            }
        }
    }
    
}

extension DialogViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex),
                                     with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex),
                                     with: .automatic)
        case .move, .update: break
        }
    }
}

extension DialogViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "chat_logo")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var str = NSMutableAttributedString(string: "Здесь будут ваши транзакции")
        return str
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSMutableAttributedString(string: "Потяните снизу, чтобы загрузить новые.")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor.white
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func isReversed(_ scrollView: UIScrollView) -> Bool{
        return true
    }
}
