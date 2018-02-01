//
//  SubclassConversationViewController.swift
//  badfbdfbfdb
//
//  Created by osvinuser on 7/21/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import LayerKit
import Atlas


class ConversationParticipantProtocol: NSObject, ATLParticipant {
    
    // @abstract The first name of the participant as it should be presented in the user interface.
    var firstName: String = ""
    
    // @abstract The last name of the participant as it should be presented in the user interface.
    var lastName: String = ""
    
    // @abstract The full name of the participant as it should be presented in the user interface.
    var displayName: String = ""
    
    // @abstract The unique identifier of the participant as it should be used for Layer addressing.
    // @discussion This identifier is issued by the Layer identity provider backend.
    var userID: String = ""
    
    // @abstract Returns the image URL for an avatar image for the receiver.
    var avatarImageURL: URL?
    
    // @abstract Returns the avatar image of the receiver.
    var avatarImage: UIImage?
    
    // @abstract Returns the avatar initials of the receiver.
    var avatarInitials: String?
    
    // @abstract Returns the presence status information.
    var presenceStatus: LYRIdentityPresenceStatus
    
    // @abstract Sets whether the presence status is shown for this AvatarView. Default is true.
    var presenceStatusEnabled: Bool
    
    init(firstName: String, lastName: String, displayName: String, userID: String, avatarImageURL: URL?, presenceStatus: LYRIdentityPresenceStatus, presenceStatusEnabled: Bool) {
        
        //super.init()
        self.firstName = firstName
        self.lastName = lastName
        self.userID = userID
        self.displayName = displayName
        self.avatarImageURL = avatarImageURL //URL(string: "http://lorempixel.com/400/200/")
        self.presenceStatus = presenceStatus
        self.presenceStatusEnabled = presenceStatusEnabled
    }
    
}

class SubclassConversationViewController: ATLConversationViewController, ATLConversationViewControllerDelegate, ATLConversationViewControllerDataSource {

    var dateFormatter: DateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self
        self.addressBarController.delegate = self
        self.addressBarController.addressBarView.addressBarTextView.isEditable = false
        
        //self.shouldDisplayAvatarItemForOneOtherParticipant = true;
        //self.shouldDisplayAvatarItemForAuthenticatedUser = true;
        
        self.marksMessagesAsRead = true
        self.showProfileDataOnNavigationBar()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let backbutton: UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "BackButton"), style: .plain, target: self, action: #selector(self.backButtonAction))
        self.navigationItem.leftBarButtonItems = [backbutton]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func backButtonAction() {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - show Profile Data On Navigation Bar.
    func showProfileDataOnNavigationBar() {
        
//        guard let participants = self.getParticipantsDataFromMetaData(conversation: conversation) else {
//            return
//        }
        
        let userData = LayerChatSingleton.sharedInstance.getConversationTitle(conversation: conversation)
        let profileIcon  = LayerChatSingleton.sharedInstance.getConversationImage(conversation: conversation)
        
        //1
        let navView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH, height: 44))
        
        //2
        let imageView_Profile: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        imageView_Profile.sd_setImage(with: URL(string: profileIcon), placeholderImage: UIImage(named: "avatarSingleIcon"))
        imageView_Profile.layer.cornerRadius = 18
        imageView_Profile.clipsToBounds = true
        imageView_Profile.backgroundColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0)
        imageView_Profile.contentMode = .scaleAspectFill
        
        //3
        let label_Title: ActiveLabel = ActiveLabel(frame: CGRect(x: 40, y: 5, width: navView.frame.size.width-54, height: 20))
        label_Title.text = title
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProSemiBold, size: 17.0)
        label_Title.textAlignment = .left
        
        label_Title.customize { label in
            
            label.text = "@" + userData.title
            
            label.mentionColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 12)
            
            label.highlightFontName = FontNameConstants.SourceSansProSemiBold
            label.highlightFontSize = 16
            
            label.minimumLineHeight = 10
            
            label.handleMentionTap {_ in
                
                print("Mention")
                
                if userData.isSingleChat == true {
                
                    if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
                        
                        let authUserID: String = String(userInfoModel.id ?? 0)
                        
                        if let userID = userData.dict?["user_id"] {
                            
                            if authUserID != userID {
                                let userModel = AUserInfoModel(id: Int(userID)!)
                                self.showUserProfile(userModel)
                            }
                        }
                        
                    }
                    
                } else {
                
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "GroupDetailsShowViewController") as! GroupDetailsShowViewController
                    viewController.groupMetaData = userData.groupDict
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                }
                
            }
            
        }
        
        
        
        //4
        navView.addSubview(imageView_Profile)
        navView.addSubview(label_Title)
        
        //5
        self.navigationItem.titleView = navView
        
    }
    

    //MARK: - ATLConversationViewController data source
    func conversationViewController(_ conversationViewController: ATLConversationViewController, participantFor identity: LYRIdentity) -> ATLParticipant {
        
        // print(identity)
        
        let atlParticipant = ConversationParticipantProtocol(firstName: identity.firstName!, lastName: identity.lastName!, displayName: identity.displayName!, userID: identity.userID, avatarImageURL: identity.avatarImageURL, presenceStatus: identity.presenceStatus, presenceStatusEnabled: true)
        
        return atlParticipant
        
    }
    
    func conversationViewController(_ conversationViewController: ATLConversationViewController, attributedStringForDisplayOf date: Date) -> NSAttributedString {
        let attributes: NSDictionary = [ NSFontAttributeName : UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName : UIColor.gray]
        return NSAttributedString(string: dateFormatter.string(from: date), attributes: attributes as? [String : AnyObject])
    }
    
    
    func conversationViewController(_ conversationViewController: ATLConversationViewController, attributedStringForDisplayOfRecipientStatus recipientStatus: [AnyHashable : Any]) -> NSAttributedString {
        
        print(recipientStatus.keys)
        
        var statusString: NSAttributedString = NSAttributedString()
        if recipientStatus.count == 0 { return statusString }
        
        let recipientStatusDict = recipientStatus as NSDictionary
        let allKeys = recipientStatusDict.allKeys as NSArray
        
        var textColor: UIColor = UIColor.lightGray
        
        var array_Status = [Int]()
        
        allKeys.enumerateObjects({ participant, _, _ in
            
            let participantAsString = participant as! String
            if (participantAsString == layerClient.authenticatedUser?.userID || participantAsString.count > 60) {
                return
            }
            
            let status: LYRRecipientStatus! = LYRRecipientStatus(rawValue: Int((recipientStatusDict[participantAsString]! as AnyObject).uintValue))
            // print(status)
            
            switch status! {
                case .sent:
                    array_Status.append(1)
//                    textColor = UIColor.lightGray
                case .delivered:
                    array_Status.append(2)
//                    textColor = UIColor.orange
                case .read:
                    array_Status.append(3)
//                    textColor = UIColor.green
                default:
                    array_Status.append(0)
//                  textColor = UIColor.lightGray
            }
            
        })
        
        if array_Status.contains(0) || array_Status.contains(1) {
            textColor = UIColor.lightGray
        } else if array_Status.contains(2) {
            textColor = UIColor.orange
        } else {
            textColor = UIColor.green
        }
        
        statusString = NSAttributedString(string: "✔︎", attributes: [NSForegroundColorAttributeName: textColor])
        return statusString
        
    }
    
    
    // MARK: - ATLConversationViewControllerDelegate methods
    func conversationViewController(_ viewController: ATLConversationViewController, didSend message: LYRMessage) {
        print("Message sent!")
    }
    
    func conversationViewController(_ viewController: ATLConversationViewController, didFailSending message: LYRMessage, error: Error) {
        print("Message failed to sent with error: \(String(describing: error))")
    }
    
    func conversationViewController(_ viewController: ATLConversationViewController, didSelect message: LYRMessage) {
        print("Message selected")
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
