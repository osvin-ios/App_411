//
//  NotificationsViewController.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage

class NotificationsViewController: UIViewController, ShowAlert {

    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    fileprivate var array_NotificationList = [ANotificationInfoModel]()
    
    fileprivate var refreshControl: UIRefreshControl!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView_Main.register(UINib(nibName: "TabelViewCellNotifications", bundle: nil), forCellReuseIdentifier: "TabelViewCellNotifications")
        
        self.setViewBackground()
        
        self.refreshControlAPI()
        
    }
    
    override func viewWillAppear(_ animation: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    

    internal func refreshControlAPI() {
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadAPI), for: .valueChanged)
        tableView_Main.addSubview(refreshControl) // not required when using UITableViewController
        
        // First time automatically refreshing.
        refreshControl.beginRefreshingManually()
        self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)
        
    }
    
    
    internal func reloadAPI() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.notificationListAPI()
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    
    //MARK: - resend OTP at email.
    internal func notificationListAPI() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.notificationList, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                // Refresh end.
                self.refreshControl.endRefreshing()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    self.array_NotificationList.removeAll()
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if let notificationList = jsonResult["notification"] as? [Dictionary<String, AnyObject>] {
                                
                                for notificationInfoObj in notificationList {
                                    if let notificationInfoMapperObj = Mapper<ANotificationInfoModel>().map(JSONObject: notificationInfoObj) {
                                        self.array_NotificationList.append(notificationInfoMapperObj)
                                    }
                                }
                                
                            }
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                
                                // self.showAlert(jsonResult["message"] as? String ?? "")
                                if self.array_NotificationList.count <= 0 {
                                    
                                    let view_NoData = UIViewIllustration(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                                    
                                    view_NoData.label_Text.text = "No Data Found"
                                    
                                    self.tableView_Main.backgroundView = view_NoData
                                    
                                } else {
                                    
                                    self.tableView_Main.backgroundView = nil
                                }
                                
                            })
                            
                        }
                        
                        self.refreshControl.endRefreshing()
                        self.tableView_Main.reloadData()
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                // Refresh end.
                self.refreshControl.endRefreshing()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
    }
    
    
    
    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array_NotificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TabelViewCellNotifications = tableView.dequeueReusableCell(withIdentifier: "TabelViewCellNotifications") as! TabelViewCellNotifications
        
        cell.selectionStyle = .none
        
        
        let aNotificationInfoModel: ANotificationInfoModel = self.array_NotificationList[indexPath.row]
        
        cell.label_Text.enabledTypes = [.mention, .hashtag, .url]
        cell.label_Text.textColor = .black

        
        var dateString = ""
        if let date = self.getDateFormatterFromServer(stringDate: aNotificationInfoModel.updated_at ?? "") {
            dateString =  date.timeAgo
        }
        
        
        let customType = ActiveType.custom(pattern: "\\s\(dateString)\\b") //Looks for "are"
        cell.label_Text.enabledTypes.append(customType)
        cell.label_Text.tag = indexPath.row
        
        cell.label_Text.customize { label in
            
            var notification = ""
            
            notification = aNotificationInfoModel.notification_message ?? ""
            notification += "\n" + dateString
            
            label.text = notification
            label.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)

            label.hashtagColor = .black
            label.mentionColor = .black
            label.URLColor     = appColor.URLColorNotification
            
            label.highlightFontName = FontNameConstants.SourceSansProSemiBold
            label.highlightFontSize = 17
            
            label.customColor[customType] = UIColor.lightGray

            
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                case customType:
                    atts[NSFontAttributeName] = isSelected ? UIFont(name: FontNameConstants.SourceSansProRegular, size: 12) : UIFont(name: FontNameConstants.SourceSansProRegular, size: 12)
                default: ()
                }
                
                return atts
            }
            
            
            label.handleCustomTap(for: customType) {_ in 
                print("click on date..!")
            }
            
            
            label.handleMentionTap { mention in
                print("You just tapped the \(mention) Mention")
            
                let selectedNotificationObj: ANotificationInfoModel = self.array_NotificationList[label.tag]
                let userInfo = selectedNotificationObj.user
                
                if let userID = userInfo?["id"] {
                   
                    let userObj = AUserInfoModel(id: userID as! Int)
                    self.showUserProfile(userObj)
                    
                }
            }
            
            
            label.handleHashtagTap { hashtag in
                print("You just tapped the \(hashtag) Hashtag")
                
                let selectedNotificationObj: ANotificationInfoModel = self.array_NotificationList[label.tag]
                let eventInfo = selectedNotificationObj.event
                
                if let notificationInfoMapperObj = Mapper<ACreateEventInfoModel>().map(JSONObject: eventInfo) {
                    self.moveToDetailEvent(row: 0, arrayObject: [notificationInfoMapperObj])
                }
                
            }
            
            
            label.handleURLTap { url in
                print("You just tapped the \(url) URL")
            }
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
}
