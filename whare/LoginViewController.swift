//
//  LoginViewController.swift
//  whare
//
//  Created by LaoWen on 16/6/30.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD//为什么这里还要导入SVProgressHUD?删除线又是什么意思
//TODO:SVProgressHUD显示期间UI扔可以操作，要改掉

//TODO: 放到一个单独的文件里
let kUrlLogin = "http://wen.local/php/SkyEye/Login.php"
let kUrlVerifyLogin = "http://wen.local/php/SkyEye/VerifyToken.php"
let kUrlRegister = "http://wen.local/php/SkyEye/Register.php"

class LoginViewController: UIViewController {
    @IBOutlet weak var textStudentId: UITextField!

    @IBOutlet weak var textPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBtnLoginClicked(sender: AnyObject) {
        //TODO:检查参数输入
        SVProgressHUD.show()
        
        let parameters = ["StudentId": textStudentId.text!, "Password": textPassword.text!]
        Alamofire.request(.POST, kUrlLogin, parameters: parameters)
            .validate()
            .responseJSON { (response) in
                let loginResult = JSON(response.result.value!)
                if loginResult["result"] == "success" {
                    print("登录成功")
                    SVProgressHUD.dismiss()
                    //self.token = loginResult["token"].string
                    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    delegate.token = loginResult["token"].string
                    
                    self.saveUserInfo()
                    
                    //TODO:
                    XmppManager.sharedInstance.login(username: "hello", password: "hello")
                    
                    //跳到菜单页面
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let menuNav = sb.instantiateViewControllerWithIdentifier("MenuNav")
                    self.view.window?.rootViewController = menuNav
                } else {
                    print("登录失败")
                    let errorMessage = loginResult["message"].string
                    let message = "登录失败\n\(errorMessage ?? "")"
                    SVProgressHUD.showErrorWithStatus(message)
                }
        }
    }

    //保存用户信息
    func saveUserInfo() {
        let udf = NSUserDefaults.standardUserDefaults()
        let userInfo = ["StudentId": textStudentId.text!, "Password": textPassword.text!]//可空类型不能转换为NSDictionary
        udf.setObject(userInfo as NSDictionary, forKey: "UserInfo")
        udf.synchronize()
    }
    
    //加载用户信息
    func loadUserInfo() {
        let udf = NSUserDefaults.standardUserDefaults()
        if let userInfo = udf.objectForKey("UserInfo") as? [String: String] {
            textStudentId.text = userInfo["StudentId"]
            textPassword.text = userInfo["Password"]
        }
    }
}
