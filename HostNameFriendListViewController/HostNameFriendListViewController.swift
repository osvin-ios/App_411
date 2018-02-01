//
//  HostNameFriendListViewController.swift
//  App411
//
//  Created by osvinuser on 7/12/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage


protocol HostNameFriendListViewControllerDelegate {
    func clickOnDoneButton(selectedFriendList: [AFriendInfoModel])
}


class HostNameFriendListViewController: UIViewController, ShowAlert {

    // IBOutlet
    @IBOutlet var tableView_Main: UITableView!
    
    @IBOutlet var barButtonDoneItem: UIBarButtonItem!

    // Variables
    var array_FriendList = [AFriendInfoModel]()
    
    var array_SelectedFriends = [AFriendInfoModel]()
    
    var refreshControl: UIRefreshControl!
    
    var isEventHost: Int = 0
    var isPresentHost: Bool!
    var isAddMembers: Bool?
    var eventInfoMapperObj: ACreateEventInfoModel?
    
    var delegate: HostNameFriendListViewControllerDelegate?
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if isEventHost == 1 {
            
            self.title = "Add Host Names"

        } else {
            
            if let isAddMember = isAddMembers, isAddMember {
                self.title = "Add Members"
                barButtonDoneItem.title = "Done"
                
            }  else {
                self.title = isPresentHost == true ? "Host Names" : "Invite Friends"
                barButtonDoneItem.title = isPresentHost == true ? "Done" : "Invite"
            }
        }
        
        
        barButtonDoneItem.isEnabled = false
        
        
        /* Set view background */
        self.setViewBackground()
        
        /* Register nib files */
        self.tableCellNibs()
        
        /* Add refresh controller */
        self.refreshControlAPI()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        
    }

    
    @IBAction func backButtonAction(_ sender: Any) {
        
        if isEventHost == 1 {
            
            _ = self.navigationController?.popViewController(animated: true)
            
        } else {
            
            if isPresentHost == false {
                
                // Get View Controller
                for viewController in (self.navigationController?.viewControllers)! {
                    if viewController is HomeEventsViewController {
                        self.navigationController?.popToViewController(viewController, animated: false)
                    }
                }
                
            } else {
                
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - table cell nibs
    internal func tableCellNibs() {
        tableView_Main.register(UINib(nibName: "TableViewCellFriendList", bundle: nil), forCellReuseIdentifier: "TableViewCellFriendList")
    }
    
    
    // MARK: - refresh control For API
    internal func refreshControlAPI() {
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadAPI), for: .valueChanged)
        tableView_Main.addSubview(refreshControl) // not required when using UITableViewController

        // First time automatically refreshing.
        refreshControl.beginRefreshingManually()
        self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)
        
    }
    
    
    // MARK: - Reload API
    func reloadAPI() {
        
        // Check network connection.
        if Reachability.isConnectedToNetwork() == true {
            
            if isEventHost == 1 {
                
                // call Friend list API.
                self.getHostsListForEvent(event_Id: "\(eventInfoMapperObj?.id ?? 0)" )
                
            } else {
            
                // call Friend list API.
                self.getFriendRequestList()
           }
        } else {

            // Refresh end.
            self.refreshControl.endRefreshing()

            // Show Internet Connection Error
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    
    // MARK:- IBAction.
    @IBAction func doneBarButtonAction(_ sender: Any) {
        
        if isEventHost == 1 {
            
            let ids = array_SelectedFriends.flatMap { String($0.id ?? 0) }
            print("Get Friends Ids:- \(ids)")
            
            let joinIdsString = ids.joined(separator: ",")
            
            print(eventInfoMapperObj?.id ?? "No Value Found.")
            
            if let createdEventDetails = eventInfoMapperObj {
                
                // Check network connection.
                if Reachability.isConnectedToNetwork() == true {
                    
                    self.addHostsForEvent(inviteUserIds: joinIdsString, event_Id: "\((createdEventDetails.id ?? 0))")

                } else {
                    
                    // Show Internet Connection Error
                    self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                    
                }
            }
            
        } else {
            
            if isPresentHost == true {
                
                delegate?.clickOnDoneButton(selectedFriendList: array_SelectedFriends)
                
                self.navigationController?.popViewController(animated: true)
                
            } else if let isAddMember = isAddMembers, isAddMember {
                
                delegate?.clickOnDoneButton(selectedFriendList: array_SelectedFriends)
                
                self.navigationController?.popViewController(animated: true)
                
            } else {
                
                //
                let ids = array_SelectedFriends.flatMap { String($0.id ?? 0) }
                print("Get Friends Ids:- \(ids)")
                
                
                let joinIdsString = ids.joined(separator: ",")
                
                print(eventInfoMapperObj?.id ?? "No Value Found.")
                
                if let createdEventDetails = eventInfoMapperObj {
                    
                    self.sendInvitationForEvent(inviteUserIds: joinIdsString, event_Id: String(createdEventDetails.id ?? 0))
                    
                }
                
            }
            
        }
        
        
    }
    
    
    // MARK:- Did Receive Memory Warning.
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

extension HostNameFriendListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 1
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 2
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_FriendList.count
    }
    
    // 3
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellFriendList = tableView.dequeueReusableCell(withIdentifier: "TableViewCellFriendList") as! TableViewCellFriendList
        
        
        // Get Model Data
        let aFriendInfoModel: AFriendInfoModel = self.array_FriendList[indexPath.row]
        
        cell.imageView_image.sd_setImage(with: URL(string: aFriendInfoModel.image ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarSmallImage"))
        
        cell.label_Title.text = aFriendInfoModel.fullname
        
        cell.label_description.text = aFriendInfoModel.email
        
        cell.selectionStyle = .none
        
        
        return cell
        
    }
    
    // 4
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Get table cell
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        // Get Friend Data.
        let aFriendInfoModel: AFriendInfoModel = self.array_FriendList[indexPath.row]

        // Check Data contain or not.
        if array_SelectedFriends.contains(where: { $0.id == aFriendInfoModel.id }) {
        
            _ = array_SelectedFriends.index(where: { $0.id ==  aFriendInfoModel.id }).map({ (Index) in
                array_SelectedFriends.remove(at: Index)
            })
            
            cell.accessoryType = .none
            
        } else {
        
            array_SelectedFriends.append(aFriendInfoModel)
            cell.accessoryType = .checkmark

        }
        
        barButtonDoneItem.isEnabled = array_SelectedFriends.count > 0 ? true : false
        
    }
    
    // 5
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // 6
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // 7
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // 8
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    // 9
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
}
