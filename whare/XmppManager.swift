//
//  XmppManager.swift
//  whare
//
//  Created by LaoWen on 16/7/4.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import Foundation

//TODO:（注意）因为XmppManager要做为XMPPStream的代理，所以必须继承自NSObject，否则运行（登录）时会报如下错误：
//does not implement methodSignatureForSelector: -- trouble ahead

class XmppManager: NSObject, XMPPStreamDelegate, XMPPRosterDelegate {
    private static let instance = XmppManager()//TODO:static和class的区别
    class var sharedInstance: XmppManager {//单例
        return instance
    }
    
    var stream: XMPPStream!//TODO:只读，不隐式拆箱行吗？
    
    var rosterStorage: XMPPRosterCoreDataStorage!
    var roster: XMPPRoster!
    
    var vCardStorage: XMPPvCardCoreDataStorage!
    var vCardTempModule: XMPPvCardTempModule!
    var vCardAvatarModule: XMPPvCardAvatarModule!
    
    var messageArchivingStorage: XMPPMessageArchivingCoreDataStorage!
    var messageArchiving: XMPPMessageArchiving!
    override init() {
        //流
        stream = XMPPStream()
        
        //花名册相关
        rosterStorage = XMPPRosterCoreDataStorage()
        roster = XMPPRoster(rosterStorage: rosterStorage)
        roster.autoFetchRoster = true
        roster.autoAcceptKnownPresenceSubscriptionRequests = true
        roster.activate(stream)
        
        //头像相关
        vCardStorage = XMPPvCardCoreDataStorage.sharedInstance()
        vCardTempModule = XMPPvCardTempModule(vCardStorage: vCardStorage)
        vCardAvatarModule = XMPPvCardAvatarModule(vCardTempModule: vCardTempModule)
        vCardTempModule.activate(stream)
        vCardAvatarModule.activate(stream)
        
        //消息持久化存储相关
        messageArchivingStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        messageArchiving = XMPPMessageArchiving(messageArchivingStorage: messageArchivingStorage)
        messageArchiving.activate(stream)
        
        super.init()//调用这个之前不能使用self
        
        stream.addDelegate(self, delegateQueue: dispatch_get_main_queue())//如果成员变量有不可空的，那在所有不可空的成员变量被初始化之前是不能使用self的
    }
    
    private var password: String = ""
    private func connect(username username: String, password: String) {//TODO:外部形参
        if stream.isConnected() {
            stream.disconnect()
        }
        self.password = password
        stream.hostName = "wen.local"//TODO:统一管理
        stream.hostPort = 5222
        stream.myJID = XMPPJID.jidWithUser(username, domain: "wen.local", resource: "iPhone")
        do {
            try stream.connectWithTimeout(120)
        } catch (let error) {
            print("XMPP连接失败:\(error)")
        }
    }
    
    // MARK: 登录
    private var isLogin = false
    func login(username username: String, password: String) {
        isLogin = true
        connect(username: username, password: password)
    }
    
    // MARK: 连接成功
    @objc func xmppStreamDidConnect(sender: XMPPStream!) {
        print("xmppStreamDidConnect")
        if isLogin {//登录
            do {
                try stream.authenticateWithPassword(password)
            } catch (let error) {
                print("登录出错:\(error)")
            }
        } else {//注册
            do {
                try stream.registerWithPassword(password)
            } catch (let error) {
                print("注册出错:\(error)")
            }
        }
    }
    
    // MARK: 连接断开
    @objc func xmppStreamDidDisconnect(sender: XMPPStream!, withError error: NSError!) {
        print("xmppStreamDidDisconnect:\(error)")
    }
    
    //上线
    func goOnLine() {
        let presence = XMPPPresence()
        stream.sendElement(presence)
    }
    
    // MARK: 登录成功
    @objc func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        print("登录成功")
        goOnLine()
    }
    
    @objc func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        print("登录失败:\(error)")//TODO: 显示错误
    }
    
    @objc func xmppStreamDidRegister(sender: XMPPStream!) {
        print("注册成功")
    }
    
    @objc func xmppStream(sender: XMPPStream!, didNotRegister error: DDXMLElement!) {
        print("注册失败")
    }
}