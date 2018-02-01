//
//  CreateEventViewController.swift
//  App411
//
//  Created by osvinuser on 7/10/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import GooglePlacePicker
import ObjectMapper
import Cloudinary

class CreateEventViewController: UIViewController, ShowAlert, GMSPlacePickerViewControllerDelegate, CreateEventProfileViewControllerDelegate {

    @IBOutlet fileprivate var tableView_Main: UITableView!
    fileprivate var isCauseLocation: Bool = false

    
    fileprivate var array_EnterEventDetails = ["Event Title", "Event Sub Title", "Add Location", "Select Start Date/Time", "Select End Date/Time", "Description", "Things to bring", "Things that people will get"]
    
    
    fileprivate var categoryBool = false
    fileprivate var startEventBool = false
    fileprivate var stopEventBool = false
    fileprivate var isMediaSelected = Bool()

    fileprivate var imageFullSize = UIImage()
    fileprivate var imageThumbnailSize = UIImage()
    fileprivate var videoURL : URL!
    fileprivate var eventDict = [String: Date]()
    var groupID : Int?
    var categoryEventID : Int = 0

    
    fileprivate var createEventInfoParams: [String: AnyObject] = ["EventProfile" : "" as AnyObject, "EventTitle" : "" as AnyObject, "EventSubTitle": "" as AnyObject, "EventLocation": "" as AnyObject, "EventStartTime": "" as AnyObject, "EventStopTime": "" as AnyObject, "EventDescription": "" as AnyObject, "ThingsToBring": "" as AnyObject, "ThingsThatPeopleWillGet": "" as AnyObject, "EventCategoryIds": "" as AnyObject, "EventHostIds": "" as AnyObject, "EventAvailability": "0" as AnyObject]

    fileprivate var isPresentHost: Bool!
    
    
    //MARK:- View Start
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerXIBS()
        
        self.setViewBackground()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateEventViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateEventViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    internal func registerXIBS() {
        
        tableView_Main.register(UINib(nibName: "TableViewCellDetailsOption", bundle: nil), forCellReuseIdentifier: "TableViewCellDetailsOption")
        tableView_Main.register(UINib(nibName: "TableViewCellCreateEventTextField", bundle: nil), forCellReuseIdentifier: "TableViewCellCreateEventTextField")
        tableView_Main.register(UINib(nibName: "TableViewCellCreateEventTextView", bundle: nil), forCellReuseIdentifier: "TableViewCellCreateEventTextView")
        tableView_Main.register(UINib(nibName: "TableViewCellDropDown", bundle: nil), forCellReuseIdentifier: "TableViewCellDropDown")
        tableView_Main.register(UINib(nibName: "TableViewCellLabel", bundle: nil), forCellReuseIdentifier: "TableViewCellLabel")
        tableView_Main.register(UINib(nibName: "TableViewCellSwitch", bundle: nil), forCellReuseIdentifier: "TableViewCellSwitch")
        tableView_Main.register(UINib(nibName: "TableViewCellDatePicker", bundle: nil), forCellReuseIdentifier: "TableViewCellDatePicker")
        tableView_Main.register(UINib(nibName: "DonateTableViewCell", bundle: nil), forCellReuseIdentifier: "DonateTableViewCell")

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Keyboard Notifications
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: 0.25, animations: {
                
                let edgeInsets = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
                self.tableView_Main.contentInset = edgeInsets
                self.tableView_Main.scrollIndicatorInsets = edgeInsets
            })
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.25, animations: {
            
            let edgeInsets = UIEdgeInsets.zero
            self.tableView_Main.contentInset = edgeInsets
            self.tableView_Main.scrollIndicatorInsets = edgeInsets
        })
    }

    //MARK:- IBAction
    @IBAction func barButtonAction(_ sender: Any) {
        
        if validation() {
            if Reachability.isConnectedToNetwork() == true {
                //self.createEventAPI()
                self.uploadImageToServer()
            } else {
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            }
        }
    }
    
    //MARK:- Validation
    internal func validation() -> Bool {
        
        print(createEventInfoParams["EventHostIds"] ?? "dfjgds")
        
        if (createEventInfoParams["EventTitle"] as? String ?? "").count <= 0 {
            
            self.showAlert(AKErrorHandler.CreateEvent.titleEmpty)
            
        } else if (createEventInfoParams["EventSubTitle"] as? String ?? "").count <= 0 {
            
            self.showAlert(AKErrorHandler.CreateEvent.SubtitleEmpty)
            
        } else if (createEventInfoParams["EventPlaceName"] as? String ?? "").count <= 0 &&  (createEventInfoParams["EventPlaceAddress"] as? String ?? "").count <= 0 {
            
            self.showAlert(AKErrorHandler.CreateEvent.addLocation)
            
        }else if (createEventInfoParams["EventStartTime"] as? String ?? "").count <= 0 {
            
            self.showAlert(AKErrorHandler.CreateEvent.startTime)
            
        } else if (createEventInfoParams["EventStopTime"] as? String ?? "").count <= 0 {
            
            self.showAlert(AKErrorHandler.CreateEvent.endTime)
            
        } else if (createEventInfoParams["EventDescription"] as? String ?? "").count <= 0 {
            
            self.showAlert(AKErrorHandler.CreateEvent.descriptionEmpty)
            
        }/* else if (createEventInfoParams["ThingsToBring"] as! String).characters.count <= 0 {
             
             self.showAlert(AKErrorHandler.CreateEvent.thingsTobring)
             
             }else if (createEventInfoParams["ThingsThatPeopleWillGet"] as! String).characters.count <= 0 {
             
             self.showAlert(AKErrorHandler.CreateEvent.thingsToPeople)
             
             } else if (createEventInfoParams["EventHostIds"] as! [AFriendInfoModel]).count == 0 {
             
             self.showAlert(AKErrorHandler.CreateEvent.endTime)
             
         } */ else if !isMediaSelected {
            
            self.showAlert(AKErrorHandler.CreateEvent.selectMedia)
            return false
        } else {
            
            return true
        }
        
        return false
        
    }
    
    func sendBackImageAndVideoURL(url: Any?, type: Int, error: Error!) {
        
        var imageThumbnail : UIImage?
        isMediaSelected = true
        if type == 0 {
            
            imageThumbnail = (url as! UIImage).createImageThumbnailFromImage()
            imageThumbnailSize = imageThumbnail!
            imageFullSize = url as! UIImage
            
        } else {
            
            imageThumbnail = (url as! URL).createThumbnailFromUrl()
            imageThumbnailSize = imageThumbnail!
            imageFullSize = imageThumbnail!
            videoURL = url as! URL
        }
    }
    
    
    //MARK: - Webservice Method
    internal func uploadImageToServer() {
        
        let randomIDTimelinePost = "CreateEventPublicID_".randomString(length: 60)

        Methods.sharedInstance.showLoader(object: self.view)
        
        let config = CLDConfiguration(cloudinaryUrl: CLOUDINARY_URL)
        let cloudinary = CLDCloudinary(configuration: config!)
        
        let params = CLDUploadRequestParams()
        params.setTransformation(CLDTransformation().setGravity(.northWest))
        params.setPublicId(randomIDTimelinePost)
        
        if videoURL == nil {
            
            cloudinary.createUploader().signedUpload(data: UIImageJPEGRepresentation(imageThumbnailSize, 1.0)!, params: params, progress: { (progress) in
                
                print(progress)
                
            }, completionHandler: { (respone, error) in
                
                if error != nil {
                    
                    Methods.sharedInstance.hideLoader(object: self.view)
                    
                    self.showAlert(error?.localizedDescription ?? "No Error Found")
                    
                } else {
                    
                    print(respone ?? "Not Found")
                    
                    if let cldUploadResult: CLDUploadResult = respone {
                        
                        let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                        let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                        
                        if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
                            
                            self.createEventAPI(authToken: userInfoObj.authentication_token!, imageName: cldUploadResult.publicId!, imageURL: cldUploadResult.url!, thumnailImage: "")
                            
                        }
                        
                    }

                }
            })
            
        } else {
            
            let params = CLDUploadRequestParams()
            params.setResourceType(.video)
            params.setTransformation(CLDTransformation().setGravity(.northWest))

            //Video Upload Code
            cloudinary.createUploader().signedUpload(url: videoURL, params: params , progress: { (progress) in
                print(progress)

            }, completionHandler: { (respone, error) in
                
                if error != nil {
                    
                    Methods.sharedInstance.hideLoader(object: self.view)
                    
                    self.showAlert(error?.localizedDescription ?? "No Error Found")
                    
                } else {
                    
                    print(respone ?? "Not Found")
                    
                    if let cldUploadResult: CLDUploadResult = respone {
                        
                        if let fileURL = self.videoURL {
                            
                            let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                            let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                            
                            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
                                
                                self.uploadVideoOnCloudinaryByURL(authToken: userInfoObj.authentication_token!, imageName: "", imageURL: cldUploadResult.url!, thumbnailImage: fileURL)
                                
                            }
                        }
                        
                    }
                    
                }
            })
            
        }
        
    }

    
    
    //MARK:- Create Event API.
    internal func createEventAPI(authToken: String, imageName: String, imageURL: String, thumnailImage: String) {
    
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        var hostIdsString : String?
        if let selectedFriendList: [AFriendInfoModel] = createEventInfoParams["EventHostIds"] as? [AFriendInfoModel] {
            let ids = selectedFriendList.flatMap { String($0.id ?? 0) }
            hostIdsString = ids.joined(separator: ", ")
        }
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&video_flag=\(videoURL == nil ? 0 : 1)&event_image=\(imageURL)&event_image_name=\(imageName)&title=\(createEventInfoParams["EventTitle"] as AnyObject)&sub_title=\(createEventInfoParams["EventSubTitle"] as AnyObject)&latitute=\(createEventInfoParams["EventLatitute"] as AnyObject)&longitute=\(createEventInfoParams["EventLongitute"] as AnyObject)&event_place_name=\(createEventInfoParams["EventPlaceName"] as AnyObject)&event_place_address=\(createEventInfoParams["EventPlaceAddress"] as AnyObject)&start_event_date=\(createEventInfoParams["EventStartTime"] as AnyObject)&end_event_date=\(createEventInfoParams["EventStopTime"] as AnyObject)&description=\(createEventInfoParams["EventDescription"] as AnyObject)&things_to_bring=\(createEventInfoParams["ThingsToBring"] as AnyObject)&things_people_get=\(createEventInfoParams["ThingsThatPeopleWillGet"] as AnyObject)&event_category_id=\(categoryEventID)&host_id=\(hostIdsString ?? "")&availability=\(createEventInfoParams["EventAvailability"] as AnyObject)&group_event_id=\(groupID ?? 0)&cause_address=\(createEventInfoParams["causeDonationPlaceAddress"] as AnyObject)&cause_donationType=\(createEventInfoParams["cause_donationType"] as AnyObject)&causeLat=\(createEventInfoParams["causeDonationLatitute"] as AnyObject)&causeLong=\(createEventInfoParams["causeDonationLongitute"] as AnyObject)&thumbnail_image=\(thumnailImage as AnyObject)"
        
        
        var webServiceURL = String()
        if groupID == nil {
            //group_event_id
            webServiceURL = Constants.APIs.baseURL + Constants.APIs.createEvent
        } else {
            
            webServiceURL = Constants.APIs.baseURL + Constants.APIs.createGroupEvent
        }
        
        WebServiceClass.sharedInstance.dataTask(urlName: webServiceURL, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader(object: self.view)

            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if let eventInfoMapperObj = Mapper<ACreateEventInfoModel>().map(JSONObject: jsonResult["event"]) {

                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "eventListReloadNotification"), object: self, userInfo: ["":""])
                                
                                let inviteFriendView: UIViewCreatedEventSuccessfullyVIew = UIViewCreatedEventSuccessfullyVIew(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: Constants.ScreenSize.SCREEN_HEIGHT))
                                
                                if let groupid = self.groupID, groupid > 0 {
                                  inviteFriendView.nameLabel.text = "Group Event created successfully"
                                } else if self.categoryEventID == 10 {
                                    inviteFriendView.nameLabel.text = "Cause created successfully"
                                }
                                
                                inviteFriendView.delegate = self
                                
                                inviteFriendView.eventInfoMapperObj = eventInfoMapperObj
                                
                                appDelegateShared.window?.addSubview(inviteFriendView)
                                                                
                            }
                        
                            // self.showAlertWithActions(jsonResult["message"] as? String ?? "")
                            
                        } else {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        
                        }
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
        }
    
    }
    
    // MARK: - Upload Video By URL on Cloudinary
    // Upload Video Thumbnail
    
    func uploadVideoOnCloudinaryByURL(authToken: String, imageName: String, imageURL: String, thumbnailImage: URL) {
        
        let videoThumbnailPublicID = "CreateEventThumbnailPublicID_".randomString(length: 60)

        // Configuration.
        let configurationThumbnail = CloudinarySingletonClass.sharedInstance.configurationOfCloudinary(publicID: videoThumbnailPublicID, resourceType: .image)
        let cloudinaryThumbnail: CLDCloudinary = configurationThumbnail.cloudinary
        let paramsThumbnail: CLDUploadRequestParams = configurationThumbnail.params
        
        if let image = self.generateThumnail(url: thumbnailImage) {
            
            let imageData = UIImageJPEGRepresentation(image, 0.6)
            
            cloudinaryThumbnail.createUploader().signedUpload(data: imageData!, params: paramsThumbnail, progress: { (progress) in
                print(progress)
            }, completionHandler: { (respone, error) in
                
                if error != nil {
                    
                    Methods.sharedInstance.hideLoader(object: self.view)
                    self.showAlert(error?.localizedDescription ?? "No Error Found")
                    
                } else {
                    
                    if let cldUploadResult: CLDUploadResult = respone {
                        
                        if let videoThumnailURL = cldUploadResult.url {
                            
                            self.createEventAPI(authToken: authToken, imageName: cldUploadResult.publicId!, imageURL: imageURL, thumnailImage: videoThumnailURL)

                        } else {
                            
                            print("Video Thumbnail Not Found.")
                            
                        }
                        
                    } else {
                        
                        print("Video Thumbnail Not Found.")
                        
                    }
                    
                }
                
            })
            
        } else {
            
            print("Video Thumbnail Not Found.")
            
        }
    }
    
    
    
    //MARK:- Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "seguehostname" {
            
            let destinationView = segue.destination as? HostNameFriendListViewController
            destinationView?.isPresentHost = isPresentHost
            destinationView?.eventInfoMapperObj = sender as? ACreateEventInfoModel
            destinationView?.delegate = self
            
        } else if segue.identifier == "segueUploadEventProfile" {
            
            let destinationView = segue.destination as? CreateEventProfileViewController
            destinationView?.delegate = self
            
        }
        
    }
    

}

extension CreateEventViewController: HostNameFriendListViewControllerDelegate, TableViewCellSwitchDelegates, TableViewCellDatePickerDelegate, UIViewCreatedEventSuccessfullyVIewDelegate, DonateTableViewCellDelegate {
    
    func donationMethodType(type: Int8) {
        
        createEventInfoParams["cause_donationType"] = type as AnyObject
        
    }
    
    //UIViewCreatedEventSuccessfullyVIewDelegate Cross Action
    func crossInviteAction() {
        
        if groupID == nil {
            
            self.moveToPrevious()

        } else {
            
            if SharedInstance.appDelegate?.window!.rootViewController is MainTabbarViewController {
                let tababarController = SharedInstance.appDelegate?.window!.rootViewController as! MainTabbarViewController
                tababarController.selectedIndex = 1
            }
        }
        
    }

    func clickOnDoneButton(selectedFriendList: [AFriendInfoModel]) {
        
        createEventInfoParams["EventHostIds"] = selectedFriendList as AnyObject
        tableView_Main.reloadSections(IndexSet(integer: categoryEventID == 10 ? 4 : 2), with: .automatic)
        
    }
    
    //TableViewCellSwitchDelegates Method
    func changeSwitchButtonStatus(sender: UISwitch) {
    
        createEventInfoParams["EventAvailability"] =  (sender.isOn ? false : true) as AnyObject

    }

    func selectedDateAndTime(datePicker: UIDatePicker) {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM d, yyyy h:mm a"
        
        let dateInString: String = dateFormatterGet.string(from: datePicker.date)
        
        if datePicker.tag == (100+4) {
            
            startEventBool = false
            
            eventDict["EventStartTime"] = datePicker.date
            
            createEventInfoParams["EventStartTime"] = dateInString as AnyObject
            
            if createEventInfoParams["EventStopTime"] as? String ?? "" != "" {
                createEventInfoParams["EventStopTime"] = "" as AnyObject
            }
            
        } else {
            
            if createEventInfoParams["EventStartTime"] as? String ?? "" == "" {
                
                stopEventBool  = false
                
                tableView_Main.reloadSections(IndexSet(integer: 1), with: .automatic)
                
                self.showAlert("Please select Event Start date/time first")
                
                return
            }
            
            stopEventBool  = false
            
            createEventInfoParams["EventStopTime"] = dateInString as AnyObject
        }
        
        tableView_Main.reloadSections(IndexSet(integer: 1), with: .automatic)
        
    }
    
    func inviteFriendsAction(eventInfoMapperObj: ACreateEventInfoModel) {
        
        print("Invite Friend")
        
        isPresentHost = false
        self.performSegue(withIdentifier: "seguehostname",  sender: eventInfoMapperObj)
        
    }
    
}

extension CreateEventViewController: UITextFieldDelegate, UITextViewDelegate {
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.tag == ((startEventBool == true && stopEventBool == true) ? (105+2) : (startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true) ? (105+1) : 105) {
        
            createEventInfoParams["EventDescription"] = textView.text as AnyObject
            
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        UIView.animate(withDuration: 0.25, animations: {
            
            let pointInTable:CGPoint = textView.superview!.convert(textView.frame.origin, to: self.tableView_Main)
            var contentOffset:CGPoint = self.tableView_Main.contentOffset
            contentOffset.y  = pointInTable.y
            if let accessoryView = textView.inputAccessoryView {
                contentOffset.y -= accessoryView.frame.size.height
            }
            self.tableView_Main.contentOffset = contentOffset
        })
       
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag == 100 {
            
            createEventInfoParams["EventTitle"] = textField.text as AnyObject
            
        } else if textField.tag == 101 {
        
            createEventInfoParams["EventSubTitle"] = textField.text as AnyObject

        } else if textField.tag == ((startEventBool == true && stopEventBool == true) ? (106+2) : (startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true) ? (106+1) : 106) {
            
            createEventInfoParams["ThingsToBring"] = textField.text as AnyObject
            
        } else if textField.tag == ((startEventBool == true && stopEventBool == true) ? (107+2) : (startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true) ? (107+1) : 107) {
            
            createEventInfoParams["ThingsThatPeopleWillGet"] = textField.text as AnyObject
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        let newString = fullText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if newString.count > 0 {
            
            if textField.tag == 100 {
                
                createEventInfoParams["EventTitle"] = textField.text as AnyObject
                
            } else if textField.tag == 101 {
                
                createEventInfoParams["EventSubTitle"] = textField.text as AnyObject
                
            } else if textField.tag == ((startEventBool == true && stopEventBool == true) ? (106+2) : (startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true) ? (106+1) : 106) {
                
                createEventInfoParams["ThingsToBring"] = textField.text as AnyObject
                
            } else if textField.tag == ((startEventBool == true && stopEventBool == true) ? (107+2) : (startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true) ? (107+1) : 107) {
                
                createEventInfoParams["ThingsThatPeopleWillGet"] = textField.text as AnyObject
                
            }
            
        } else {
            
            return string == "" ? true : false
        } // end el
        
        return true
        
    }
    
}

extension CreateEventViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK:- Table View Custom Functions
    internal func getTableViewCellDatePicker(tableView: UITableView, indexPath: IndexPath) -> TableViewCellDatePicker {
    
        let cell:TableViewCellDatePicker = tableView.dequeueReusableCell(withIdentifier: "TableViewCellDatePicker") as! TableViewCellDatePicker
        
        cell.delegate = self
        
        cell.selectionStyle = .none
        
        cell.datepickerSetMinimumDate(row: 100+indexPath.row, startDate: eventDict["EventStartTime"])

        cell.datePicker_Outlet.tag = 100+indexPath.row
        
        return cell
        
    }
    
    internal func getTableViewCellCreateEventTextField(tableView: UITableView, indexPath: IndexPath) -> TableViewCellCreateEventTextField {
        
        let cell:TableViewCellCreateEventTextField = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextField") as! TableViewCellCreateEventTextField
        
        cell.textField_EnterText.delegate = self
        cell.textField_EnterText.isUserInteractionEnabled = true
        cell.textField_EnterText.text = ""

    
        if indexPath.row < 4 {
        
            cell.textField_EnterText.placeholder = array_EnterEventDetails[indexPath.row]
            
        } else {
            
            if startEventBool == false && stopEventBool == false {
            
                cell.textField_EnterText.placeholder = array_EnterEventDetails[indexPath.row]
                
            } else if startEventBool == true && stopEventBool == false {
            
                cell.textField_EnterText.placeholder = array_EnterEventDetails[indexPath.row-1]
                
            } else if startEventBool == false && stopEventBool == true {
            
                if indexPath.row == 4 {
                
                    cell.textField_EnterText.placeholder = array_EnterEventDetails[indexPath.row]
                    
                } else {
                
                    cell.textField_EnterText.placeholder = array_EnterEventDetails[indexPath.row-1]

                }
                
            } else {
            
                if indexPath.row == 5 {
                
                    cell.textField_EnterText.placeholder = array_EnterEventDetails[indexPath.row-1]
                    
                } else {
                
                    cell.textField_EnterText.placeholder = array_EnterEventDetails[indexPath.row-2]
                    
                }
                
            }
        
        }
        
        
        if indexPath.row < 4 {
            
            cell.textField_EnterText.tag = indexPath.row+100
            
        } else {
            
            cell.textField_EnterText.tag = ((startEventBool == true && stopEventBool == true) ? (indexPath.row+102) : (startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true) ? (indexPath.row+101) : (indexPath.row+100))
            
        }
        

        if indexPath.row == 0 {
            
            cell.textField_EnterText.text = createEventInfoParams["EventTitle"] as? String ?? ""
            
        } else if indexPath.row == 1 {
            
            cell.textField_EnterText.text = createEventInfoParams["EventSubTitle"] as? String ?? ""
            
        } else if indexPath.row == 2 {
            
            // Location block
            cell.textField_EnterText.isUserInteractionEnabled = false
            
            if (createEventInfoParams["EventPlaceName"] as? String ?? "").count == 0 || (createEventInfoParams["EventPlaceAddress"] as? String ?? "").count == 0 {
            
                cell.textField_EnterText.text = ""
                
            } else {
            
                cell.textField_EnterText.text = (createEventInfoParams["EventPlaceName"] as? String ?? "") + ", " + (createEventInfoParams["EventPlaceAddress"] as? String ?? "")
            }
            
        } else if indexPath.row == 3 {
            
            cell.textField_EnterText.isUserInteractionEnabled = false
            cell.textField_EnterText.text = createEventInfoParams["EventStartTime"] as? String ?? ""
            
        } else if indexPath.row == 4 {
        
            // description Date block
            if startEventBool == false {
                cell.textField_EnterText.text = createEventInfoParams["EventStopTime"] as? String ?? ""
                cell.textField_EnterText.isUserInteractionEnabled = false
            }
            
        } else if indexPath.row == 5 {
            
            if startEventBool {
                cell.textField_EnterText.text = createEventInfoParams["EventStopTime"] as? String ?? ""
                cell.textField_EnterText.isUserInteractionEnabled = false
            }
            
        } else if indexPath.row == ((startEventBool == true && stopEventBool == true) ? (6+2) : (startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true) ? (6+1) : 6) {
            
            cell.textField_EnterText.text = createEventInfoParams["ThingsToBring"] as? String ?? ""
            
        } else if indexPath.row == ((startEventBool == true && stopEventBool == true) ? (7+2) : (startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true) ? (7+1) : 7)  {
            
            cell.textField_EnterText.text = createEventInfoParams["ThingsThatPeopleWillGet"] as? String ?? ""
            
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    internal func getTableViewDonationCollectionView(tableView: UITableView, indexPath: IndexPath) -> DonateTableViewCell {
        
        let cell:DonateTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DonateTableViewCell") as! DonateTableViewCell
        
        cell.delegate = self
        
        return cell
        
    }
    
    internal func getTableViewForHost(tableView: UITableView, indexPath: IndexPath) -> TableViewCellCreateEventTextField {
        
        let cell:TableViewCellCreateEventTextField = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextField") as! TableViewCellCreateEventTextField
        
        cell.textField_EnterText.placeholder = "Host Name"
        
        cell.textField_EnterText.isUserInteractionEnabled = false
        
        cell.textField_EnterText.text = ""
        
        if let selectedFriendList: [AFriendInfoModel] = createEventInfoParams["EventHostIds"] as? [AFriendInfoModel] {
            
            let ids = selectedFriendList.flatMap( { String($0.fullname ?? "") } )
            
            let joinIdsString = ids.joined(separator: ", ")
            cell.textField_EnterText.text = joinIdsString
            
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    internal func getTableViewForDonationLocation(tableView: UITableView, indexPath: IndexPath) -> TableViewCellCreateEventTextField {
        
        let cell:TableViewCellCreateEventTextField = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextField") as! TableViewCellCreateEventTextField
        
        cell.textField_EnterText.isUserInteractionEnabled = false
        
        cell.textField_EnterText.placeholder = "Add Location"
        
        if (createEventInfoParams["causeDonationPlaceName"] as? String ?? "").count == 0 || (createEventInfoParams["causeDonationPlaceAddress"] as? String ?? "").count == 0 {
            
            cell.textField_EnterText.text = ""
            
        } else {
            
            cell.textField_EnterText.text = (createEventInfoParams["causeDonationPlaceName"] as? String ?? "") + ", " + (createEventInfoParams["causeDonationPlaceAddress"] as? String ?? "")
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    
    internal func getTableViewForSwitch(tableView: UITableView, indexPath: IndexPath) -> TableViewCellSwitch {
        
        let cell:TableViewCellSwitch = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSwitch") as! TableViewCellSwitch
        
        cell.delegate = self
        
        cell.label_Text.text = "Make the event public"
        
        cell.switch_ButtonOutlet.setOn(createEventInfoParams["EventAvailability"] as? Bool == true ? false : true , animated:true)
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    
    // MARK:- Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if categoryEventID == 10 {
            
            return 6
            
        } else {
            
            return 4
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
        
            if startEventBool == true && stopEventBool == true {
            
                return self.array_EnterEventDetails.count+2
                
            } else if startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true {
            
                return self.array_EnterEventDetails.count+1
                
            } else {
                
                return self.array_EnterEventDetails.count
                
            }
            
        } else {
        
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
        
            let cell:TableViewCellDetailsOption = tableView.dequeueReusableCell(withIdentifier: "TableViewCellDetailsOption") as! TableViewCellDetailsOption
            
            cell.label_Text.text = "Upload Video/Picture or Choose Flyer"
            
            cell.selectionStyle = .none
            
            return cell

        } else if indexPath.section == 1 {
        
            if indexPath.row == ((startEventBool == true && stopEventBool == true) ? (5+2) : (startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true) ? (5+1) : 5) {
            
                let cell:TableViewCellCreateEventTextView = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextView") as! TableViewCellCreateEventTextView
                
                cell.textView_EnterText.delegate = self
                
                cell.textView_EnterText.tag = 100 + indexPath.row

                self.addToolBar(textView: cell.textView_EnterText)

                cell.textView_EnterText.text = ""
                
                if indexPath.row == ((startEventBool == true && stopEventBool == true) ? (5+2) : (startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true) ? (5+1) : 5) {
                
                    cell.textView_EnterText.text = createEventInfoParams["EventDescription"] as? String ?? ""

                }
                
                cell.selectionStyle = .none
                
                return cell
                
            } else {
            
                //TableViewCellDatePicker
                if startEventBool == true && stopEventBool == true {
                    
                    if indexPath.row == 4 || indexPath.row == 6 {
                        
                        return self.getTableViewCellDatePicker(tableView: tableView, indexPath: indexPath)
                        
                    }
                    
                } else if startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true {
                    
                    if startEventBool == true {
                    
                        if indexPath.row == 4 {
                            
                            return self.getTableViewCellDatePicker(tableView: tableView, indexPath: indexPath)
                            
                        }
                        
                    } else {
                    
                        if indexPath.row == 5 {
                            
                            return self.getTableViewCellDatePicker(tableView: tableView, indexPath: indexPath)

                        }
                    
                    }
                    
                }
                
                return self.getTableViewCellCreateEventTextField(tableView: tableView, indexPath: indexPath)
                
            }
            
        } else {
            
            if indexPath.section == 2 {
                
                if categoryEventID == 10 {
                    
                    return self.getTableViewDonationCollectionView(tableView: tableView, indexPath: indexPath)
                    
                } else {
                    
                  return self.getTableViewForHost(tableView:tableView, indexPath:indexPath)
                    
                }

            } else if indexPath.section == 3 {
                
                if categoryEventID == 10 {
                    
                    return self.getTableViewForDonationLocation(tableView:tableView, indexPath:indexPath)

                } else {
                    
                    return self.getTableViewForSwitch(tableView:tableView, indexPath:indexPath)

                }
                
            } else if indexPath.section == 4 {
                
                return self.getTableViewForHost(tableView:tableView, indexPath:indexPath)

            } else {
                
                return self.getTableViewForSwitch(tableView:tableView, indexPath:indexPath)
 
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
        
            self.performSegue(withIdentifier: "segueUploadEventProfile", sender: self)
            
        } else if indexPath.section == 1 {
        
            if indexPath.row == 2 {
            
               isCauseLocation = false

               self.getEventLocationFromLocationPicker()
            
            } else if indexPath.row == 3 {
                
                startEventBool = !startEventBool
                    
            } else if indexPath.row == (startEventBool == true ? (4+1) : 4) {
                
                stopEventBool  = !stopEventBool

            }
            
           tableView.reloadSections(IndexSet(integer: 1), with: .automatic)

            
        } else if indexPath.section == 2 && indexPath.row == 0 && categoryEventID != 10 {
            
            isPresentHost = true
            self.performSegue(withIdentifier: "seguehostname",  sender: self)
            
        } else if indexPath.section == 3 && categoryEventID == 10 {
            
            isCauseLocation = true
            
            self.getEventLocationFromLocationPicker()
            
        } else if indexPath.section == 4 && indexPath.row == 0 && categoryEventID == 10 {
            
            isPresentHost = true
            self.performSegue(withIdentifier: "seguehostname",  sender: self)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
        
            if startEventBool == true && stopEventBool == true {
                
                if indexPath.row == 4 || indexPath.row == 6  {
                    
                    return 250
                    
                } else {
                    
                    return indexPath.row == 7 ? 120 : 50
                    
                }
                
            } else if startEventBool == true && stopEventBool == false || startEventBool == false && stopEventBool == true {
                
                if startEventBool == true {
                
                    if indexPath.row == 4 {
                    
                        return 250
                    
                    } else {
                    
                        return indexPath.row == 6 ? 120 : 50

                    }
                    
                } else {
                    
                    if indexPath.row == 5 {
                        
                        return 250
                        
                    } else {
                        
                        return indexPath.row == 6 ? 120 : 50
                        
                    }
                    
                }
                
            } else {
                
                return indexPath.row == 5 ? 120 : 50
                
            }
            
        } else if indexPath.section == 2 {
            
            return categoryEventID == 10 ? 100 : 50
                
        } else {
            
            return 50

        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
        
            return 10.0
            
        } else {
        
            return 40.0

        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if categoryEventID == 10 {
            
            return section == 5 ? 20.0 : 0.1

        } else {
            return section == 3 ? 20.0 : 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if categoryEventID == 10 {
            
            switch section {
                
            case 1:
                return self.setHeaderView(title: "Cause Details")
            case 2:
                return self.setHeaderView(title: "Things to Donate")
            case 3:
                return self.setHeaderView(title: "Make donations at this location")
            case 4:
                return self.setHeaderView(title: "Host Details")
            case 5:
                return self.setHeaderView(title: "Availability")
                
            default:
                
                return self.clearBackgroundColor()
            }
            
        } else {
            
            if section == 0 {
                
              return self.clearBackgroundColor()

            } else if section == 1 {
                
                return self.setHeaderView(title: "Event Details")
                
            } else if section == 2 {
                
                return self.setHeaderView(title: "Host Details")
                
            } else if section == 3 {
                
                return self.setHeaderView(title: "Availability")
                
            } else {
                
                return self.clearBackgroundColor()
            }
        }
    }
        
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    // MARK:- Header View.
    internal func setHeaderView(title: String) -> UIView {
    
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
        
        label_Title.text = title
        
        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProSemiBold, size: 16)
        
        hearderView.addSubview(label_Title)
        
        return hearderView
        
    }
    
    //MARK:- Add Location picker.
    func getEventLocationFromLocationPicker() {
    
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
        
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place address \(place.formattedAddress ?? "")")
        print("Place attributions \(String(describing: place.coordinate.latitude))")
        print("Place attributions \(String(describing: place.coordinate.longitude))")
        
        if !isCauseLocation {
            
            createEventInfoParams["EventLatitute"] = place.coordinate.latitude as AnyObject
            createEventInfoParams["EventLongitute"] = place.coordinate.longitude as AnyObject
            createEventInfoParams["EventPlaceName"] = place.name as AnyObject
            createEventInfoParams["EventPlaceAddress"] = place.formattedAddress as AnyObject
            
        } else {
            
            createEventInfoParams["causeDonationLatitute"] = place.coordinate.latitude as AnyObject
            createEventInfoParams["causeDonationLongitute"] = place.coordinate.longitude as AnyObject
            createEventInfoParams["causeDonationPlaceName"] = place.name as AnyObject
            createEventInfoParams["causeDonationPlaceAddress"] = place.formattedAddress as AnyObject
            
        }
        
        self.tableView_Main.reloadSections(IndexSet(integer: isCauseLocation == false ? 1 : 3), with: .automatic)
        
    }
}


