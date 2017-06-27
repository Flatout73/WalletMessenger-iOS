//
//  ChatsViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 24.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import CoreData

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var coreDataService: CoreDataService!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        coreDataService = CoreDataService()
        fetchedResultsController = coreDataService.getFRCForChats(tableView: tableView)
        //fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 1
        if(!fetchedResultsController.sections!.isEmpty) {
            if let sectionInfo = fetchedResultsController.sections?[section]{
                return sectionInfo.numberOfObjects
            } else { print("Unexpected Section") }
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return cells.count
        if let count = fetchedResultsController.sections?.count {
            return count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as!ChatTableViewCell
        
        //cell.name.text = cells[indexPath.row]
        
        let conversation = fetchedResultsController.object(at: indexPath)
        
        if let participants = conversation.participants as? Set<User> {
            
            conversation.managedObjectContext?.performAndWait {
                for user in participants{
                    cell.name.text = user.name
                    break
                }
            }
        }

        
        return cell
        
    }
    
    var k = 2
    @IBAction func createConversation(_ sender: Any) {
        coreDataService.insertConversation(id: k)
        k += 1
    }
    
    
//    //Если бы сделал через performSegue было бы меньшекода, ну ладно
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DialogVC") as? DialogViewController {
//            //viewController.hidesBottomBarWhenPushed = true
//            if let navigator = navigationController {
//                navigator.pushViewController(viewController, animated: true)
//            }
//        }
//    }
    
}

