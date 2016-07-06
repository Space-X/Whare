//
//  RoomViewController.swift
//  whare
//
//  Created by LaoWen on 16/7/5.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, XMPPRoomDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textMessage: UITextField!
    
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        textMessage.delegate = self
        
        initialRoom()
        initialFetchedResultsController()
        
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
    
    private var roomStorage: XMPPRoomCoreDataStorage!
    private var room: XMPPRoom!
    func initialRoom() {
        let roomJID = XMPPJID.jidWithString("lwgroup@conference.wen.local")
        roomStorage = XMPPRoomCoreDataStorage.sharedInstance()
        room = XMPPRoom(roomStorage: roomStorage, jid: roomJID)
        room.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        room.activate(XmppManager.sharedInstance.stream)
        let nickName = XmppManager.sharedInstance.stream.myJID.bare()//TODO:换成可以设置的昵称（登录时的用户名）
        room.joinRoomUsingNickname(nickName, history: nil)
    }
    
    private var fetchedResultsController: NSFetchedResultsController!
    func initialFetchedResultsController() {
        let entityName = "XMPPRoomMessageCoreDataStorageObject"
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "localTimestamp", ascending: true)//按时间从大到小
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let context = roomStorage.mainThreadManagedObjectContext
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
    
    func xmppRoomDidJoin(sender: XMPPRoom!) {
        print("加入聊天室")
    }
    
    func xmppRoom(sender: XMPPRoom!, occupantDidJoin occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
        print("有人加入聊天室")
    }
    
    func xmppRoom(sender: XMPPRoom!, didReceiveMessage message: XMPPMessage!, fromOccupant occupantJID: XMPPJID!) {
        print("收到消息:\(message.body)")
    }

    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: RoomCell!
        let message = fetchedResultsController.objectAtIndexPath(indexPath) as! XMPPRoomMessageCoreDataStorageObject
        
        if message.isFromMe {
            cell = tableView.dequeueReusableCellWithIdentifier("RoomOutGoingCell", forIndexPath: indexPath) as! RoomCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("RoomInComingCell", forIndexPath: indexPath) as! RoomCell
        }
        cell.message.text = message.body
        //TODO:显示头像
        
        return cell
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

    func sendMessage() {
        if let textToSend = textMessage.text {
            if textToSend == "" {
                return
            }
            room.sendMessageWithBody(textMessage.text)
            textMessage.text = ""
        }
    }
    
    @IBAction func onBtnSendClicked(sender: UIButton) {
        sendMessage()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
