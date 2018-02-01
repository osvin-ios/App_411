//
//  LoginViewController.swift
//  App411
//
//  Created by osvinuser on 6/12/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper




class LoginViewController: UIViewController, ShowAlert {

    // private outlet
    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    
    var params: [String: String] = ["email" : "", "password" : ""]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        tableView_Main.register(UINib(nibName: "TableViewCellTextFieldEnterText", bundle: nil), forCellReuseIdentifier: "TableViewCellTextFieldEnterText")

        self.setViewBackground()

    }

    //MARK:- Login Button.
    @IBAction func loginButtonAction(_ sender: Any) {
        
        if validation() {
        
            if Reachability.isConnectedToNetwork() == true {
                
                self.userLoginAPI()
                
            } else {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
            
        }
        
    }
    
    //MARK:- Validation
    internal func validation() -> Bool {
    
        if (params["email"]?.count)! <= 0 && (params["password"]?.count)! <= 0 {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.Empty_Email_Password)
            
        } else if (params["email"]?.count)! <= 0 {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.Empty_Email)
            
        } else if (params["password"]?.count)! <= 0 {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.Empty_Password)
            
        } else {
            
            if !(params["email"]?.isValidEmail())! {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.Valid_Email)
                
            } else if !(params["password"]?.isPasswordValid())! {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.Password_Valid)
                
            } else {
                
                return true
            }
            
        }
        
        return false

    }
    
    // MARK:- Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
   z // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellTextFieldEnterText = tableView.dequeueReusableCell(withIdentifier: "TableViewCellTextFieldEnterText") as! TableViewCellTextFieldEnterText
        
        cell.textField_EnterData.placeholder = indexPath.section == 0 ? "Email" : "Password"
        
        cell.textField_EnterData.isSecureTextEntry = indexPath.section == 0 ? false : true
        
        cell.textField_EnterData.delegate = self
        
        cell.textField_EnterData.tag = indexPath.section
        
        cell.textField_EnterData.rightViewMode = .always
        
        if indexPath.section == 0 {
            cell.textField_EnterData.keyboardType = .emailAddress
        }
        cell.selectionStyle = .none
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 44.0 : 0.1;
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return section == 0 ? 10.0 : 44.0
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
        
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 2, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
            
            label_Title.text = "Log in to XP"
            
            label_Title.textColor = UIColor.darkGray
            
            label_Title.font = UIFont(name: FontNameConstants.SourceSansProSemiBold, size: 22)
            
            hearderView.addSubview(label_Title)
            
            return hearderView
            
        } else {
        
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
            
        }

    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 1 {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            let label_Title: ActiveLabel = ActiveLabel(frame: CGRect(x: 15, y: 2, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 44))
            
            let customType = ActiveType.custom(pattern: "Forgot Password?") //Looks for "are"
            
            label_Title.enabledTypes.append(customType)

            label_Title.textColor = UIColor.darkGray
            
            label_Title.textAlignment = .center
            
            label_Title.text = "Forgot Password?"
            
            label_Title.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
            
            label_Title.customColor[customType] = UIColor.darkGray
            
            label_Title.handleCustomTap(for: customType, handler: { (String) in
                //print("Tap On forgot password")
                //print(String)
                self.performSegue(withIdentifier: "segueForgotPassword", sender: self)
                
            })
            
            hearderView.addSubview(label_Title)
            
            return hearderView
            
        } else {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
            
        }
        
    }
    
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag == 0 {
            
            if let textFiledText: String = textField.text {
            
                if textFiledText.count > 0 {
                
                    if !textFiledText.isValidEmail() {
                        
                        self.showAlert(AKErrorHandler.CommonErrorMessages.Valid_Email)
                        textField.rightView = self.correctTextFieldText(typeBool: false, textField: textField)
                        
                    } else {
                        
                        textField.rightView = self.correctTextFieldText(typeBool: true, textField: textField)
                        params["email"] = textFiledText
                    }
                    
                } else {
                
                    textField.rightView = nil
                    self.showAlert(AKErrorHandler.CommonErrorMessages.Empty_Email)
                    textField.textColor = appColor.appButtonUnSelectedColor
                    
                }
                
            }
            
        } else {
            
            if let textFiledText: String = textField.text {
                
                if textFiledText.count > 0 {
                    
                    if !textFiledText.isPasswordValid() {
                        
                        textField.rightView = nil
                        self.showAlert(AKErrorHandler.CommonErrorMessages.Password_Valid)
                        textField.rightView = self.correctTextFieldText(typeBool: false, textField: textField)
                        
                    } else {
                        
                        textField.rightView = self.correctTextFieldText(typeBool: true, textField: textField)
                        params["password"] = textFiledText
                        
                    }
                    
                } else {
                
                    textField.rightView = nil
                    self.showAlert(AKErrorHandler.CommonErrorMessages.Empty_Password)
                    textField.textColor = appColor.appButtonUnSelectedColor

                }
                
            }
            
        }
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        let newString = fullText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if newString.count > 0 {
            
            /* Set statment block */
            
        } else {
            
            textField.rightView = nil
            return string == "" ? true : false
            
        } // end else.
        
        return true
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func correctTextFieldText(typeBool: Bool, textField: UITextField) -> UIView {
    
        let imageViewIcon: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 30 , height:50))
        let imageViewImage: UIImageView = UIImageView(frame: CGRect(x: 0, y: 14, width: 22 , height:22))
        imageViewImage.image = typeBool == true ? #imageLiteral(resourceName: "CorrectText") : #imageLiteral(resourceName: "IncorrectText")
        textField.textColor = typeBool == true ? appColor.appButtonUnSelectedColor : appColor.appButtonSelectedColor
        imageViewIcon.addSubview(imageViewImage)
        
        return imageViewIcon
    }
    
}


