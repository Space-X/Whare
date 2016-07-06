//
//  MessageViewController.swift
//  whare
//
//  Created by LaoWen on 16/7/5.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit

class MessageViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        initialFetchedResultsController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var fetchedResultsController: NSFetchedResultsController!
    func initialFetchedResultsController() {
        let context = XmppManager.sharedInstance.messageArchivingStorage.mainThreadManagedObjectContext
        let entityName = "XMPPMessageArchiving_Contact_CoreDataObject"
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "mostRecentMessageTimestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)//TODO:后两个参数
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print("创建消息fetchedResultsController出错:\(error)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        let message = fetchedResultsController.objectAtIndexPath(indexPath) as! XMPPMessageArchiving_Contact_CoreDataObject
        cell.displayName.text = message.bareJidStr//TODO:显示为名字
        cell.message.text = message.mostRecentMessageBody
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        let messageDate = dateFormatter.stringFromDate(message.mostRecentMessageTimestamp)
        cell.date.text = messageDate

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = tableView.indexPathForSelectedRow
        let contact = fetchedResultsController.objectAtIndexPath(indexPath!) as! XMPPMessageArchiving_Contact_CoreDataObject
        let chatVC = segue.destinationViewController as! ChatViewController
        chatVC.targetJID = contact.bareJid
    }
}
