//
//  ChatViewController.swift
//  whare
//
//  Created by LaoWen on 16/7/4.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textMessage: UITextField!
    
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    var targetJID: XMPPJID!//好友JID
    private var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textMessage.delegate = self
        initialFetchedResultsController()
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 55
        scrollToBottom()
        
        //处理软键盘
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onKeyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onKeyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tableView.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()//NSValue和NSNumber的关系
            
        let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animateWithDuration(duration, animations: {
            self.bottomViewBottomConstraint.constant = keyboardFrame.height//TODO:循环引用
            //这里我并没有使用弱引用指针，但是当页面返回的时候deinit确实被调用了，有待研究
            self.view.layoutIfNeeded()//必须有这句，否则没有动画效果
            self.scrollToBottom()
        })
    }
    
    func onKeyboardWillHide(notification: NSNotification) {
        let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animateWithDuration(duration) { 
            self.bottomViewBottomConstraint.constant = 0//TODO:循环引用
            self.view.layoutIfNeeded()
        }
    }
    
    func onTap() {
        self.view.endEditing(true)
    }
    
    @IBAction func onBtnSendClicked(sender: UIButton) {
        sendMessage()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
    
    private func sendMessage() {
        if let textToSend = textMessage.text {
            if textToSend == "" {
                return
            }
            
            let xmppMessage = XMPPMessage(type: "chat", to: targetJID)
            xmppMessage.addBody(textToSend)
            XmppManager.sharedInstance.stream.sendElement(xmppMessage)
            
            textMessage.text = ""
        }
    }

/*    lazy private var fetchedResultsController1: NSFetchedResultsController = {
        let entityName = "XMPPMessageArchiving_Message_CoreDataObject"
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)//按时间从大到小
        fetchRequest.sortDescriptors = [sortDescriptor]
        //TODO:这是一个懒加载，而targetJID为可空，所以这里不能用？
        let bareJidStr = targetJID.bare()
        let predicate = NSPredicate(format: "bareJidStr==%@", bareJidStr)
        
    }()
*/
    
    func initialFetchedResultsController() {
        let entityName = "XMPPMessageArchiving_Message_CoreDataObject"
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)//按时间从大到小
        fetchRequest.sortDescriptors = [sortDescriptor]
        //TODO:这是一个懒加载，而targetJID为可空，所以这里不能用？
        let bareJidStr = targetJID.bare()//TODO:（注意）OC中没参数有返回值的函数在swift中不能当属性用，要当函数用
        let predicate = NSPredicate(format: "bareJidStr==%@", bareJidStr)
        fetchRequest.predicate = predicate
        
        let context = XmppManager.sharedInstance.messageArchivingStorage.mainThreadManagedObjectContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)//TODO: 后两个参数
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch (let error) {
            print("获得聊天记录出错:\(error)")
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
        scrollToBottom()
    }
    
    func scrollToBottom() {
        if let rowCount = fetchedResultsController.sections?.last?.numberOfObjects {
            let indexPath = NSIndexPath(forRow: rowCount-1, inSection: fetchedResultsController.sections!.count-1)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: ChatCell!
        let message = fetchedResultsController.objectAtIndexPath(indexPath) as! XMPPMessageArchiving_Message_CoreDataObject
        
        if message.isOutgoing {
            cell = tableView.dequeueReusableCellWithIdentifier("ChatOutGoingCell", forIndexPath: indexPath) as! ChatCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("ChatInComingCell", forIndexPath: indexPath) as! ChatCell
        }
        cell.labelMessage.text = message.body
        //TODO:显示头像
        
        return cell
    }

    deinit {
        print("Chat View Controller deinit")
    }
}
