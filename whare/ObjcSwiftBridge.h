//
//  ObjcSwiftBridge.h
//  whare
//
//  Created by LaoWen on 16/6/30.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#ifndef ObjcSwiftBridge_h
#define ObjcSwiftBridge_h

#import "SVProgressHUD/SVProgressHUD.h"//OC的工程可以直接写SVProgressHUD.h，Swift的工程必须写SVProgressHUD/SVProgressHUD.h?

#import "XMPPFramework.h"//XMPPFramework用到了xml库，所以要包括/usr/include/libxml2目录，并添加libxml2.tbd、libresolv.tbd库
#import "XMPPRoster.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPvCardTemp.h"
#import "XMPPvCardTempModule.h"
#import "XMPPVCardAvatarModule.h"
#import "XMPPMessageArchivingCoredataStorage.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPRoom.h"
#import "XMPPJID.h"

//人脸识别
#import "LWFaceDetector.h"

#endif /* ObjcSwiftBridge_h */
