//
//  RegisterViewController.swift
//  whare
//
//  Created by LaoWen on 16/6/30.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

import UIKit
import Alamofire//为什么也有删除线

class RegisterViewController: UIViewController {

    @IBOutlet weak var textStudentId: UITextField!
    
    @IBOutlet weak var textName: UITextField!
    
    @IBOutlet weak var textPassword1: UITextField!
    
    @IBOutlet weak var textPassword2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkInput() -> (success:Bool, message:String) {
        if textStudentId.text == "" {
            return (false, "学号不能为空")
        }
        if textName.text == "" {
            return (false, "姓名不能为空")
        }
        if textPassword1.text == "" {
            return (false, "密码不能为空")
        }
        if textPassword2.text == "" {
            return (false, "确认密码不能不空")
        }
        if textPassword1.text != textPassword2.text {
            return (false, "密码不一至")
        }
        return (true, "")
    }
    
    @IBAction func onBtnRegisterClicked(sender: AnyObject) {
        let (success, message) = checkInput()//检查用户输入是否合法
        if !success {//输入信息不合法，提示用户
            let alert = UIAlertController(title: "错误", message: message, preferredStyle: .Alert)
            let action = UIAlertAction(title: "确定", style: .Default, handler:nil)
            alert.addAction(action)
            
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        //TODO:增加HUD
        //用户输入合法，开始注册
        let parameters = ["Name": textName.text!, "StudentId": textStudentId.text!, "Password": textPassword1.text!]
        Alamofire.request(.POST, kUrlRegister, parameters: parameters)
            .validate()
            .responseJSON { (response) in
                let registerResult = JSON(response.result.value!)
                if registerResult["result"] == "success" {
                    print("注册成功")
                    self.dismissViewControllerAnimated(true, completion: nil)//TODO:用更SB的方式返回
                } else {
                    let message = registerResult["message"]
                    print("注册失败:\(message)")
                }
        }
    }
    
    @IBAction func onBtnBackClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);//TODO:换成更StoryBoard的方式
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
