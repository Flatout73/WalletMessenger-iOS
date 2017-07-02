//
//  ChatsViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 24.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import CoreData

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ContactDialogDelegate, ContactGroupDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var dialogID = -1
    
    var coreDataService: CoreDataService!
    
    var refreshControl: UIRefreshControl!
    
    var loadMoreStatus = false
    
    var isDialogs: Bool = true
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var frcGroup: NSFetchedResultsController<GroupConversation>!
    var fetchedResultsController: NSFetchedResultsController<Conversation>!// {
//        didSet {
//            do {
//                if let frc = fetchedResultsController {
//                    frc.delegate = self
//                    try frc.performFetch()
//                }
//                tableView.reloadData()
//            } catch let error {
//                print("NSFetchedResultsController.performFetch() failed: \(error)")
//            }
//        }
//    }
    
    //let cells = ["Диалог"]

    @IBOutlet var segment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        activityIndicator.hidesWhenStopped = true

        coreDataService = CoreDataService.sharedInstance
      
        fetchedResultsController = coreDataService.getFRCForChats()
        frcGroup = coreDataService.getFRCForGroups()
        
        fetchedResultsController.delegate = self
        frcGroup.delegate = self
        do{
            try fetchedResultsController.performFetch()
            try frcGroup.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        
        
        //print(fetchedResultsController.delegate)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Идет обновлени...")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.addSubview(refreshControl)
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self

    }

    
    @IBAction func segmentSwitched(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0){
            isDialogs = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } else {
            isDialogs = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    func refresh(sender: Any) {
        if (!loadMoreStatus) {
            self.loadMoreStatus = true
            
            refreshBegin { (x:Int) -> () in
                if(self.isDialogs){
                    try? self.fetchedResultsController.performFetch()
                } else {
                    try? self.frcGroup.performFetch()
                }
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                
                self.loadMoreStatus = false
            }
        } else {
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshBegin(refreshEnd:@escaping (Int) -> ()) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            if let this = self {
                if(this.isDialogs){
                    ServiceAPI.getDialogs(noncompletedHandler: this.errorHandler) {
                        DispatchQueue.main.async {
                            refreshEnd(0)
                        }
                    }
                } else{
                    ServiceAPI.getGroups(noncompletedHandler: this.errorHandler) {
                        DispatchQueue.main.async {
                            refreshEnd(0)
                        }
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 && currentOffset > 0 {
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
                            
                            if(self.isDialogs){
                                try? self.fetchedResultsController.performFetch()
                            } else{
                                try? self.frcGroup.performFetch()
                            }
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
            
            if(self.isDialogs){
                if(!self.fetchedResultsController.sections!.isEmpty) {
                    if let sectionInfo = self.fetchedResultsController.sections?[0]{
                        if(sectionInfo.numberOfObjects > 0) {
                            let conv = self.fetchedResultsController.object(at: IndexPath(row: sectionInfo.numberOfObjects - 1, section: 0))
                            guard let date = conv.date as Date? else {
                                print("Нет даты")
                                return
                            }
                            ServiceAPI.getDialogsHist(date1: Int64(date.timeIntervalSince1970), noncompletedHandler: self.errorHandler){
                                DispatchQueue.main.async  {
                                    loadMoreEnd(0)
                                }
                            }
                        } else {
                            ServiceAPI.getDialogs(noncompletedHandler: self.errorHandler) {
                                DispatchQueue.main.async  {
                                    loadMoreEnd(0)
                                }
                            }
                        }
                    }
                    
                }
            }
            else {
                if(!self.frcGroup.sections!.isEmpty) {
                    if let sectionInfo = self.frcGroup.sections?[0]{
                        if(sectionInfo.numberOfObjects > 0) {
                            let conv = self.frcGroup.object(at: IndexPath(row: sectionInfo.numberOfObjects - 1, section: 0))
                            guard let date = conv.date as Date? else {
                                print("Нет даты")
                                return
                            }
                            ServiceAPI.getGroupsHist(date1: Int64(date.timeIntervalSince1970), noncompletedHandler: self.errorHandler) {
                                loadMoreEnd(0)
                            }
                        } else {
                            ServiceAPI.getDialogs(noncompletedHandler: self.errorHandler) {
                                DispatchQueue.main.async  {
                                    loadMoreEnd(0)
                                }
                            }
                            ServiceAPI.getGroups(noncompletedHandler: self.errorHandler) {
                                
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func errorHandler(error: String) {
        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.loadMoreStatus = false
            self.activityIndicator.stopAnimating()
            self.tableView.tableFooterView?.isHidden = true
            let alert = UIAlertController(title: "Ошибка!", message: error, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
//    var k = 2
//    let idTrans = round(Date().timeIntervalSince1970)
    @IBAction func testCreationDialog(_ sender: Any) {
        
        ServiceAPI.createGroup(name: "Друзья", noncompletedHandler: self.errorHandler) {
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 1
        
        if(isDialogs){
            if(!fetchedResultsController.sections!.isEmpty) {
                if let sectionInfo = fetchedResultsController.sections?[section]{
                    return sectionInfo.numberOfObjects
                } else {
                    print("Unexpected Section")
                }
            }
        } else {
            if(!frcGroup.sections!.isEmpty) {
                if let sectionInfo = frcGroup.sections?[section]{
                    return sectionInfo.numberOfObjects
                } else {
                    print("Unexpected Section")
                }
            }
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return cells.count
        if(isDialogs){
            if let count = fetchedResultsController.sections?.count {
                return count
            }
        } else{
            if let count = frcGroup.sections?.count{
                return count
            }
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: ChatTableViewCell
        if(isDialogs){
            cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableViewCell
            
            //cell.name.text = cells[indexPath.row]
            
            let conversation = fetchedResultsController.object(at: indexPath)
            
            if let participant = conversation.participant {
                
                conversation.managedObjectContext?.performAndWait {
                    //                for user in participants{
                    //                    cell.name.text = user.name
                    //                    break
                    //                }
                    cell.name.text = participant.name
                    cell.dialogID = Int(conversation.conversationID)
                    cell.balance.text = String(conversation.summa) + " руб."
                    cell.mobilePhone.text = String(participant.mobilePhone)
                    
                    if let avatar = participant.avatar {
                        cell.avatar.image = UIImage.init(data: avatar as Data)
                    }
                }
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! ChatTableViewCell
            
            let conversation = frcGroup.object(at: indexPath)
            
            conversation.managedObjectContext?.performAndWait {
                
                cell.name.text = conversation.name
                cell.dialogID = Int(conversation.conversationID)
                cell.balance.text = String(conversation.myBalance) + " руб."
                cell.adminID = Int(conversation.admin!.userID)
            }
        }
        
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DialogViewController{
            if let cell = sender as? ChatTableViewCell {
                vc.dialogID = cell.dialogID
                vc.title = cell.name.text
                vc.phone = Int64(cell.mobilePhone.text!)
            } else if let info = sender as? DialogInfo {
                vc.dialogID = info.dialogID
                vc.title = info.user?.name
                vc.phone = info.user?.mobilePhone
            } else {
                print("Какой-то неправильный у вас сендер")
            }
        } else if let vc = segue.destination as? UINavigationController{
            if let v = vc.viewControllers.first as? ContactsTableViewController{
                v.dialogDelegate = self
                v.groupDelegate = self
            }
        } else if let vc = segue.destination as? ConferenceViewController {
            if let cell = sender as? ChatTableViewCell{
                vc.title = cell.name.text
                vc.groupID = cell.dialogID
                vc.adminID = cell.adminID
            }
        }
    }
    
    func openDialog(withDialogInfo: DialogInfo){
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showDialog", sender: withDialogInfo)
        }
    }
    
    func openGroup(withGroupID: Int){
        //self.performSegue(withIdentifier: "showGroup", sender: withID)
    }
}


extension ChatsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "chat_logo")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSMutableAttributedString(string: "Здесь будут ваши диалоги")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSMutableAttributedString(string: "Потяните вверх, чтобы загрузить\n Чтобы добавить новый диалог нажмите на плюс в правом верхнем углу")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor.white
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}


extension ChatsViewController: NSFetchedResultsControllerDelegate {
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

