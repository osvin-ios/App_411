//
//  FindFriendViewController.swift
//  App411
//
//  Created by osvinuser on 7/5/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage

class FindFriendViewController: UIViewController, ShowAlert {

    @IBOutlet var tableView_Main: UITableView!
    @IBOutlet var textField_Search: DesignableTextField!
    @IBOutlet var sendRequestBarButton: UIBarButtonItem!
    
    var array_FriendList = [AFindFriendInfoModel]()
    var array_SelectedFriendList = [AFindFriendInfoModel]()
    var dataLoading: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView_Main.register(UINib(nibName: "TableViewCellFriendList", bundle: nil), forCellReuseIdentifier: "TableViewCellFriendList")
        textField_Search.becomeFirstResponder()
        
        sendRequestBarButton.isEnabled = false
        
        self.setViewBackground()
        
    }

    //MARK:- send Friend Requset
    @IBAction func sendFriendRequest(_ sender: Any) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.sendFriendRequestAPI()
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }

    
    //MARK:- Did Receive Memory Warning.
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

extension FindFriendViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return array_SelectedFriendList.count > 0 ? 2 : 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if array_SelectedFriendList.count > 0 {
        
            return section == 0 ? array_SelectedFriendList.count : array_FriendList.count

        } else {
        
            return array_FriendList.count

        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellFriendList = tableView.dequeueReusableCell(withIdentifier: "TableViewCellFriendList") as! TableViewCellFriendList
        
        let aFindFriendInfoModel: AFindFriendInfoModel = array_SelectedFriendList.count > 0 ? indexPath.section == 0 ? self.array_SelectedFriendList[indexPath.row] : self.array_FriendList[indexPath.row] : self.array_FriendList[indexPath.row]
        
        cell.imageView_image.sd_setImage(with: URL(string: aFindFriendInfoModel.image ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarSmallImage"))
        
        cell.label_Title.text = aFindFriendInfoModel.fullname
        
        cell.label_description.text = aFindFriendInfoModel.email
        
        cell.selectionStyle = .none
        
        return cell
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.array_FriendList.count > 0 {
            
            let aFindFriendInfoModel: AFindFriendInfoModel = self.array_FriendList[indexPath.row]
            
            let objContain: Bool = array_SelectedFriendList.contains(where: { $0.id == aFindFriendInfoModel.id  })
            if objContain == false {
                array_SelectedFriendList.append(aFindFriendInfoModel)
            }
            
            sendRequestBarButton.isEnabled = true
            
            self.tableView_Main.reloadData()
        } else {
            sendRequestBarButton.isEnabled = false
            
            self.tableView_Main.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 40 : dataLoading  ? 80 : 40
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        hearderView.backgroundColor = UIColor.clear
        
        
        let loadIndicator:UIActivityIndicatorView = UIActivityIndicatorView (activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        let indicatorCenter: CGPoint = CGPoint(x: hearderView.center.x, y: hearderView.center.y + 40)
        loadIndicator.center = indicatorCenter
        
        if array_SelectedFriendList.count > 0  {
            
            if section == 0 {
                
                hearderView.addSubview(self.addLabelAtHeaderView(text: "Selected Friends"))
                
            } else {
            
                hearderView.addSubview(self.addLabelAtHeaderView(text: "Search Results"))
                
                if dataLoading {
                    hearderView.addSubview(loadIndicator)
                    loadIndicator.startAnimating()
                }
            }
            
        } else {
            
            hearderView.addSubview(self.addLabelAtHeaderView(text: "Search Results"))
            
            if dataLoading {
                hearderView.addSubview(loadIndicator)
                loadIndicator.startAnimating()
            }
            
        }
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    
    internal func addLabelAtHeaderView(text: String) -> UILabel {
    
        let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 2, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 38))
        
        label_Title.text = text
        
        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 16)
        
        return label_Title
        
    }
    
    
}

extension FindFriendViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        let newString = fullText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if newString.characters.count > 0 {
            
            if Reachability.isConnectedToNetwork() == true {
                self.searchFriendAPI(name: newString)
            } else {
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            }
            
        } else {
            self.array_FriendList.removeAll()
            self.dataLoading = false
            self.tableView_Main.reloadData()
            return string == "" ? true : false
        } // end else.
        
        return true
        
    }
    
}
