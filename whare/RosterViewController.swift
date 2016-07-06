//
//  RosterViewController.swift
//  whare
//
//  Created by LaoWen on 16/7/4.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit

class RosterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    lazy var fetchedResultController: NSFetchedResultsController = {
        let context = XmppManager.sharedInstance.rosterStorage.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entityForName("XMPPUserCoreDataStorageObject", inManagedObjectContext: context)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entityDescription
        
        let sortDescriptor1 = NSSortDescriptor(key: "sectionNum", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "displayName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)//TODO:后两个参数
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch (let error) {
            print("获取好友列表错误:\(error)")
        }
        
        return fetchedResultsController
    }()//千万不要忘了后边的这对圆括号
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()//TODO:局部刷新
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultController.sections
        let sectionInfo = sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionInfo = fetchedResultController.sections?[section] {
            let sectionName = sectionInfo.name
            switch sectionName {
            case "0":
                return "在线"
            case "1":
                return "离开"
            case "2":
                return "离线"
            default:
                return ""
            }
        }
        return ""
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RosterCell", forIndexPath: indexPath) as! RosterCell

        // Configure the cell...
        let user = fetchedResultController.objectAtIndexPath(indexPath) as? XMPPUserCoreDataStorageObject
        if  user != nil {
            cell.displayName.text = user!.displayName
            //TODO:显示头像
        }

        return cell
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let chatVC = segue.destinationViewController as! ChatViewController
        let indexPath = self.tableView.indexPathForSelectedRow
        let user = fetchedResultController.objectAtIndexPath(indexPath!) as! XMPPUserCoreDataStorageObject
        chatVC.targetJID = user.jid
    }
}
