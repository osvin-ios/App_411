//
//  SubclassConversationListViewController.swift
//  badfbdfbfdb
//
//  Created by osvinuser on 7/21/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import LayerKit
import Atlas
import ObjectMapper
import Cloudinary


class ConversationATLAvatarItemProtocol: NSObject, ATLAvatarItem {
    
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
    
    init(avatarImageURL: URL?, avatarImage: UIImage,  presenceStatus: LYRIdentityPresenceStatus, presenceStatusEnabled: Bool) {
        
        //super.init()
        self.avatarImageURL = avatarImageURL
        self.avatarImage = avatarImage
        self.presenceStatus = presenceStatus
        self.presenceStatusEnabled = presenceStatusEnabled
    }
    
}

class SubclassConversationListViewController: ATLConversationListViewController, ATLConversationListViewControllerDataSource, ATLConversationListViewControllerDelegate, ATLParticipantTableViewControllerDelegate, LYRQueryControllerDelegate, ShowAlert {

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.dataSource = self;
        self.delegate = self;
                
        self.displaysAvatarItem = true
        self.shouldDisplaySearchController = false
        self.allowsEditing = false

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        let createChatView = UIButton(type: .custom)
        createChatView.setImage(#imageLiteral(resourceName: "CreateChat"), for: .normal)
        createChatView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        createChatView.addTarget(self, action: #selector(self.barButtonSingleChatAction), for: .touchUpInside)
        let createMsg = UIBarButtonItem(customView: createChatView)
        
        let createGroupView = UIButton(type: .custom)
        createGroupView.setImage(#imageLiteral(resourceName: "CreateGroup"), for: .normal)
        createGroupView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        createGroupView.addTarget(self, action: #selector(self.barButtonGroupChatAction), for: .touchUpInside)
        let createGroupMsg = UIBarButtonItem(customView: createGroupView)
        
        self.navigationItem.rightBarButtonItems = [createMsg, createGroupMsg]
        
        layerClient = appDelegateShared.layerClient
        
        NotificationCenter.default.addObserver(self, selector: #selector(blockUserFromLayerChatByUserID), name: NSNotification.Name(rawValue: "blockUserFromLayerChatByUserIDNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(unblockUserFromLayerChatByUserID), name: NSNotification.Name(rawValue: "unblockUserFromLayerChatByUserIDNotification"), object: nil)

    }
    

    // MARK: - Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Notification Block and Unblock user.
    
    func blockUserFromLayerChatByUserID(notification: NSNotification) {
        
        if let userID = notification.userInfo?["userID"] as? String {
            self.blockLayerChatUser(userID: userID)
        }
        
    }
    
    func unblockUserFromLayerChatByUserID(notification: NSNotification) {
        
        if let userID = notification.userInfo?["userID"] as? String {
            self.unblocklayerChatUser(userID: userID)
        }
        
    }
    
    
    func conversationListViewController(_ conversationListViewController: ATLConversationListViewController, titleFor conversation: LYRConversation) -> String {
        return LayerChatSingleton.sharedInstance.getConversationTitle(conversation: conversation).title
    }
    
    func conversationListViewController(_ conversationListViewController: ATLConversationListViewController, avatarItemFor conversation: LYRConversation) -> ATLAvatarItem? {
        
        print(conversation.metadata ?? "No Meta data found")
        
        print(conversation)


        let isSingleChat: Bool = LayerChatSingleton.sharedInstance.checkConversationGroupOrSingle(conversation: conversation)

        // avatar protocol.
        let atlAvatarItem: ConversationATLAvatarItemProtocol!
        
        // avatar image fro url
        let avatarImageURl: String = LayerChatSingleton.sharedInstance.getConversationImage(conversation: conversation)
        
        if isSingleChat == true {
        
            let participantIdentifiers = self.participants(forIdentifiers: conversation.participants)
            
            let lyrIdentity: LYRIdentity = participantIdentifiers.first as! LYRIdentity
            
            print(lyrIdentity)
            
            atlAvatarItem = ConversationATLAvatarItemProtocol(avatarImageURL: URL(string: avatarImageURl), avatarImage: UIImage(named: "avatarSingleIcon")!, presenceStatus: lyrIdentity.presenceStatus, presenceStatusEnabled: false)
            
        } else {
        
            atlAvatarItem = ConversationATLAvatarItemProtocol(avatarImageURL: URL(string: avatarImageURl), avatarImage: UIImage(named: "avatarSingleIcon")!, presenceStatus: .invisible, presenceStatusEnabled: true)
        
        }
        
        return atlAvatarItem
        
    }
    
    
    func conversationListViewController(_ conversationListViewController: ATLConversationListViewController, didSelect conversation: LYRConversation) {
        
        self.presentConversationControllerForConversation(conversation: conversation)
        
    }
    
    
    

    // MARK: - Participant Delegate
    func participantTableViewController(_ participantTableViewController: ATLParticipantTableViewController, didSelect participant: ATLParticipant) {
        
        self.navigationController?.dismiss(animated: false, completion: {
        
            /*
            print(participant.userID)
            print(participant.displayName)
            print(participant.firstName)
            print(participant.lastName)
            print(participant.avatarImageURL ?? "")
            */
        
            if let authenticatedUser = self.layerClient.authenticatedUser?.userID {
                
                // Participants for chat.
                let participants: Set<String> = [authenticatedUser, participant.userID]
                // print(participants)
                
                // meta data
                let metaData = LayerChatSingleton.sharedInstance.createMetaDataOfSingleConversation(participant: participant)
                // print(metaData)
                
                // Start new single conversation.
                self.startNewConversationWithParticipants(participants: participants, conversationMetaData: metaData)
                
            }
            
        })
        
    }
    
    
    /**
     @abstract Informs the delegate that a search has been made with the following search string.
     @param participantTableViewController The participant table view controller in which the search was made.
     @param searchString The search string that was just used for search.
     @param completion The completion block that should be called when the results are fetched from the search.
     */
    func participantTableViewController(_ participantTableViewController: ATLParticipantTableViewController, didSearchWith searchText: String, completion: @escaping (Set<AnyHashable>) -> Void) {
        
    }
    
    
    
    // MARK: - present Conversation Controller
    // MARK: - Helpers
    func presentConversationControllerForConversation(conversation: LYRConversation) {
        
        let controller = SubclassConversationViewController(layerClient: self.layerClient)
        controller.conversation = conversation;
        controller.displaysAddressBar = false;
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    func participants(forIdentifiers identifiers: Set<AnyHashable>) -> Set<AnyHashable> {
        
        var participants = Set<AnyHashable>() /* capacity: identifiers.count */
        
        let authenticatedUserID: String = self.layerClient.authenticatedUser?.userID ?? ""
        
        print(authenticatedUserID)
        
        for identifier in identifiers {
            
            let lyrIdentity: LYRIdentity = identifier as! LYRIdentity
            
            if lyrIdentity.userID != authenticatedUserID {
                
                participants.insert(identifier)
                
            }
            
        }
        
        return participants
    }
    
    
    
    // MARK: - Create new chat single or group chat
    
    func startNewConversationWithParticipants(participants: Set<String>, conversationMetaData: [AnyHashable: Any]) {
    
        do {
            
            let conversationOptions = LYRConversationOptions()
            conversationOptions.metadata = conversationMetaData
                        
            let conversation: LYRConversation = try self.layerClient.newConversation(withParticipants: participants, options: conversationOptions)
            
            print(conversation.identifier)
            
            self.presentConversationControllerForConversation(conversation: conversation)
            
        } catch let error as NSError {
            
            print(error)
            
            // print(lyrErrorValue ?? "No Found")
            // print(LYRError.distinctConversationExists.rawValue)
            // print(LYRError.distinctConversationExists.hashValue)
            
            if UInt(error.code) == LYRError.distinctConversationExists.rawValue {
                
                if let conversation: LYRConversation = error.userInfo[LYRExistingDistinctConversationKey] as? LYRConversation {
                    self.presentConversationControllerForConversation(conversation: conversation)
                }
                
            }
            
        }
        
    }
    
    

    
    // MARK: - IBAction

    func barButtonGroupChatAction() {
        
        self.performSegue(withIdentifier: "segueCreateGroup", sender: self)
        
    }
    
    func barButtonSingleChatAction() {
    
        if Reachability.isConnectedToNetwork() == true {
            
            self.getFollowerFollowingList()
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    // Get Friend Request List.
    func getFollowerFollowingList() {
        
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        // user authentication toker
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&user_id=\(userInfoModel.id ?? 0)&list_status=\(0)"
        print(paramsStr)
        //page=1&per_page=5auth_token, user_id, list_status, 0 denotes followers, 1 denotes followings
        
        Methods.sharedInstance.showLoader(object: self.view)

        // Friend list web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.followerFollowingList, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader(object: self.view)

            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            var participants = Set<AnyHashable>()
                            
                            if let friendList = jsonResult["user"] as? [Dictionary<String, AnyObject>] {
                                
                                for friendInfoObj in friendList {
                                    
                                    if let friendInfoMapperObj = Mapper<AUserInfoModel>().map(JSONObject: friendInfoObj) {
                                        
                                        print(friendInfoMapperObj.fullname!)
                                        print(friendInfoMapperObj.image ?? "No Data")
                                        
                                        let user = ConversationParticipantProtocol(firstName: friendInfoMapperObj.fullname!, lastName: friendInfoMapperObj.fullname!, displayName: friendInfoMapperObj.fullname!, userID: String(friendInfoMapperObj.id ?? 0), avatarImageURL: URL(string: friendInfoMapperObj.image ?? "http://xyphr.herokuapp.com/chat.png")!, presenceStatus: .away, presenceStatusEnabled: true)
                                        _ = participants.insert(user)
                                        
                                    }
                                }
                            }
                            
                            print(participants)
                            
                            self.presentParticipantTableViewController(participants: participants)
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
                            })
                            
                        }
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
        
    }
    
    // MARK: - Present Participant Table View Controller.
    func presentParticipantTableViewController(participants: Set<AnyHashable>) {
        
        let participantTableViewController: ATLParticipantTableViewController = ATLParticipantTableViewController(participants: participants, sortType: .firstName)
        participantTableViewController.delegate = self
        participantTableViewController.presenceStatusEnabled = false
        participantTableViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.dismissparticipantTableViewControllerLocal))
        
        let navigationLocal: UINavigationController = UINavigationController(rootViewController: participantTableViewController)
        
        self.navigationController?.present(navigationLocal, animated: true, completion: nil)
        
    }
    
    func dismissparticipantTableViewControllerLocal() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Block User
    
    func blockLayerChatUser(userID: String) {
        
        let blockPolicy = LYRPolicy(type: .block)
        blockPolicy.sentByUserID = userID
        
        if ((try? layerClient.addPolicy(blockPolicy)) != nil) {
            
            // handle error in blockUserError
            print("block successfully")
            print(self.layerClient.policies ?? "Block User List Not Found.")
            
        } else {
            
            print("Getting Error")
            
        }
        
    }
    
    func unblocklayerChatUser(userID: String) {
        
        print(self.layerClient.policies ?? "Block User List Not Found.")
        
        if let policiesList = self.layerClient.policies {
            
            if policiesList.count > 0 {
                
                var matchUnblockPolicy: LYRPolicy? = nil
                
                for policieObj in policiesList {
                    
                    if let obj = policieObj as? LYRPolicy, obj.sentByUserID == userID {
                        matchUnblockPolicy = policieObj as? LYRPolicy
                        break
                    }
                    
                }
                
                
                if matchUnblockPolicy != nil {
                    
                    // Unblock ID Found.
                    try? self.layerClient.removePolicy(matchUnblockPolicy!)
                    
                    print("Participant successfully unblocked")
                    print(self.layerClient.policies ?? "Block User List Not Found.")
                    
                } else {
                    
                    // Unblock ID Not Found.
                    print("Participant Not Found.")
                    
                }
                
                
            }
            
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueCreateGroup" {
            let viewController = segue.destination as! GroupDetailsViewController
            viewController.delegate = self
        }
    }
 

}

extension SubclassConversationListViewController: GroupDetailsViewControllerDelegate {

    func createGroupWithSelectedParticipants(participants: [AnyHashable], groupTitle: String, groupImage: UIImage) {
    
        let groupProfileImage = "groupID_".randomString(length: 60)
        
        print(groupProfileImage)
        
        self.uploadProfilePicName(imageName: groupProfileImage, participants: participants, groupTitle: groupTitle, groupImage: groupImage)
        
    }
    
    
    internal func uploadProfilePicName(imageName: String, participants: [AnyHashable], groupTitle: String, groupImage: UIImage) {
        
        Methods.sharedInstance.showLoader(object: self.view)
        
        let config = CLDConfiguration(cloudinaryUrl: CLOUDINARY_URL)
        let cloudinary = CLDCloudinary(configuration: config!)
        
        let params = CLDUploadRequestParams()
        params.setTransformation(CLDTransformation().setGravity(.northWest))
        params.setPublicId(imageName)
        
        cloudinary.createUploader().signedUpload(data: UIImageJPEGRepresentation(groupImage, 1.0)!, params: params, progress: { (progress) in
            
            print(progress)
            
        }, completionHandler: { (respone, error) in
            
            Methods.sharedInstance.hideLoader(object: self.view)
            
            if error != nil {
                
                self.showAlert(error?.localizedDescription ?? "No Error Found")
                
            } else {
                
                print(respone ?? "Not Found")
                
                if let cldUploadResult: CLDUploadResult = respone {
                    
                    if let url = cldUploadResult.url {
                        
                        self.createGroupNewConversation(participants: participants, groupTitle: groupTitle, groupImageName: cldUploadResult.publicId!, groupImage: url)
                        
                    }

                }
                
            }
            
        }) 
        
        
    }
    
    
    func createGroupNewConversation(participants: [AnyHashable], groupTitle: String, groupImageName: String,  groupImage: String) {
        
        if let authenticatedUser = self.layerClient.authenticatedUser?.userID {
            
            // Participants for chat.
            let participantsIds: Set<String> = LayerChatSingleton.sharedInstance.createSetForGroupParticipants(authenticatedUser: authenticatedUser, participants: participants)
            // print(participantsIds)
            
            // meta data
            let metaData = LayerChatSingleton.sharedInstance.createMetaDataOfGroupConversation(participants: participants, groupTitle: groupTitle, groupImageName: groupImageName, groupImageURL: groupImage)
            // print(metaData)
            
            // Start new single conversation.
            self.startNewConversationWithParticipants(participants: participantsIds, conversationMetaData: metaData)
            
        }
    
    }
    
}

