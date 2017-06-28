//
//  ChatsViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 24.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import CoreData

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
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
        fetchedResultsController = coreDataService.getFRCForChats()
    
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    
        //print(fetchedResultsController.delegate)
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
        
        DispatchQueue.main.async { [weak this=self] () in
            this?.coreDataService.insertConversation(id: (this?.k)!)
            this?.k += 1
            
            this?.tableView.reloadData()
        }
        try! fetchedResultsController.performFetch()
        
        //print(fetchedResultsController.fetchedObjects)
        
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

