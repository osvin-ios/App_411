//
//  PlacesDetailViewController.swift
//  App411
//
//  Created by osvinuser on 02/11/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class PlacesDetailViewController: UIViewController, ShowAlert {
    
    //MARK: - IBOutlet
    @IBOutlet var tableView_Main: UITableView!
    var googleDict = SharedInstance.myDict()
    @IBOutlet var moreButton: UIButton!
    var isClaimed : Bool = false
    var refreshControl: UIRefreshControl!
    var mediaTypeDefine : Int = 0
    var claimLocationDict = SharedInstance.myDict()
    var isIntroVideo : Bool = false
    var placeDetailInfo : PlaceEventDetailModel!

    var avPlayer: AVPlayer!
    
    var visibleIP : IndexPath?
    
    var aboutToBecomeInvisibleCell = -1
    
    var avPlayerLayer: AVPlayerLayer!
    
    var paused: Bool = false
    
    var videoURLs = Array<URL>()

    //MARK: - View Start
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame = CGRect.zero
        frame.size.height = 1
        tableView_Main.tableHeaderView = UIView(frame: frame)
        
        self.title = "Place Detail"
        
        self.reloadAPI()

        print("Google Data From Particular Annotation", googleDict)
        tableView_Main.register(UINib(nibName: "LocationImageCell1", bundle: nil), forCellReuseIdentifier: "LocationImageCell1")
        tableView_Main.register(UINib(nibName: "LocationImageCell2", bundle: nil), forCellReuseIdentifier: "LocationImageCell2")
        tableView_Main.register(UINib(nibName: "EventPostVideoCell", bundle: nil), forCellReuseIdentifier: "EventPostVideoCell")

        let barButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Camera"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(moreButtonClicked))
        
        self.navigationItem.rightBarButtonItem = barButtonItem

    }
    
    func moreButtonClicked(_ button:UIBarButtonItem!){
        print("Done clicked")
        
        // Create the AlertController and add its actions like button in ActionSheet
        let actionSheetController = UIAlertController(title: nil, message: "Option to select", preferredStyle: .actionSheet)
        
        let createActionButton = UIAlertAction(title: "Create Post", style: .default) { action -> Void in
            print("Create Event")
            
            self.performSegue(withIdentifier: "createPostForPlaceSegue", sender: self)
            self.mediaTypeDefine = 0
        }
        actionSheetController.addAction(createActionButton)
        
        let reportActionButton = UIAlertAction(title: "Post For Intro Video", style: .default) { action -> Void in
            print("Report/Spam Event")
            
            self.performSegue(withIdentifier: "createPostForStory", sender: MediaPostType.IntroVideo)

        }
        actionSheetController.addAction(reportActionButton)
        
        let shareActionButton = UIAlertAction(title: "Post On Story", style: .default) { action -> Void in
            print("Report/Spam Event")
            
            self.performSegue(withIdentifier: "createPostForStory", sender: MediaPostType.Story)

        }
        actionSheetController.addAction(shareActionButton)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: - reloadAPI
    internal func reloadAPI() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.showClaimLocationServices()
            
        } else {
            // Refresh end.
            self.refreshControl.endRefreshing()
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
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
    
    
    //MARK: - claim Location Button
    func createGroupEvent(sender:UIButton!) {
        print("Button Clicked")
        
        self.performSegue(withIdentifier: "claimLocationSegue", sender: googleDict)
     
    }
    
    //MARK: - Click on More Button
    @IBAction func moreAction(_ sender: Any) {
        
        self.openActionSheet()
    }
    
    //MARK: - Click on More Action
    internal func openActionSheet() {
        
        // Create the AlertController and add its actions like button in ActionSheet
        let actionSheetController = UIAlertController(title: nil, message: "Option to select", preferredStyle: .actionSheet)
        
            let createActionButton = UIAlertAction(title: "Create Post", style: .default) { action -> Void in
                print("Create Event")
                
            self.performSegue(withIdentifier: "createPostForPlaceSegue", sender: self)
                
        }
        actionSheetController.addAction(createActionButton)
        
        let reportActionButton = UIAlertAction(title: "Report/Spam Place", style: .default) { action -> Void in
            print("Report/Spam Event")
            
            if Reachability.isConnectedToNetwork() == true {
                
                
            } else {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
            
        }
        actionSheetController.addAction(reportActionButton)
            
        let shareActionButton = UIAlertAction(title: "Share this Event", style: .default) { action -> Void in
            print("Report/Spam Event")
            
        }
        actionSheetController.addAction(shareActionButton)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "claimLocationSegue" {
            
            let destination = segue.destination as! ClaimLocationViewController
            destination.googleDictPlace = sender as! SharedInstance.myDict
            
        } else if segue.identifier == "createPostForPlaceSegue" {
            
            let destinationView = segue.destination as! CreatePostController
            destinationView.postUploadAtType = PostUploadType.googlePlaceId
            
        } else if segue.identifier == "createPostForStory" {
            
            let destinationView = segue.destination as! PostForStoryViewController
            destinationView.postUploadType = sender as! MediaPostType
//            destinationView.claimID = self.claimLocationDict["id"] as? Int ?? 0
        }
    }
    
    func playVideoOnTheCell(cell : EventPostVideoCell, indexPath : IndexPath){
        cell.startPlayback()
    }
    
    func stopPlayBack(cell : EventPostVideoCell, indexPath : IndexPath) {
        cell.stopPlayback()
    }

}

extension PlacesDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if isIntroVideo  {
            return 3
        } else {
            return 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isIntroVideo && indexPath.section == 0 {
            
            let cell:EventPostVideoCell = tableView.dequeueReusableCell(withIdentifier: "EventPostVideoCell") as! EventPostVideoCell
            
            let introVideo = self.placeDetailInfo.placeIntoVideo
            
            cell.videoPlayerItem = AVPlayerItem.init(url: URL(string: introVideo?.VideoURL ?? "" )!)
            cell.startPlayback()
            
            return cell
            
        } else if !isIntroVideo && indexPath.section == 0 || isIntroVideo && indexPath.section == 1 {
            
            let cell:LocationImageCell1 = tableView.dequeueReusableCell(withIdentifier: "LocationImageCell1") as! LocationImageCell1
            
            if let photoRefArray = googleDict["photos"] as? [Dictionary<String, AnyObject>] {
                
                let photoRef : String = photoRefArray[0]["photo_reference"] as! String
                
                let imageUrl = SharedInstance.googleImageURL(imageWidth: cell.frame.size.width) + photoRef
                cell.locationImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "ic_suggestion_image_dummy"))
                
            }
            
            cell.addressLabel.text = googleDict["name"] as? String ?? ""
            
            cell.selectionStyle = .none
            
            return cell
            
        } else {
            
            let cell:LocationImageCell2 = tableView.dequeueReusableCell(withIdentifier: "LocationImageCell2") as! LocationImageCell2
            cell.mapView.isUserInteractionEnabled = false
                // User Current Location.
            if let geometry = googleDict["geometry"] as? SharedInstance.myDict {
                
                let location = geometry["location"] as? SharedInstance.myDict ?? [:]
                
                let latitude = location["lat"] as? Double ?? 0.0
                
                let logitude = location["lng"] as? Double ?? 0.0
                
                let userCurrentLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(logitude))
                
                DispatchQueue.main.async {
                    // Set Map View Position.
                    
                    let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: userCurrentLocation.latitude, longitude: userCurrentLocation.longitude, zoom: 15.0)
                    cell.mapView.camera = camera
                    
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: logitude)
                    marker.appearAnimation = .pop
                    marker.icon = #imageLiteral(resourceName: "ic_marker_general")
                    marker.map = cell.mapView
                    
                }
                
            }
            
            cell.addressLabel.text = googleDict["vicinity"] as? String ?? ""
            cell.phoneLabel.text = googleDict["phoneNumber"] as? String ?? "NA"
            
            if let openingHours = googleDict["opening_hours"] as? SharedInstance.myDict {
                
                if let openNow = openingHours["open_now"] as? Int, openNow != 0 {
                    if let openHours = openingHours["weekday_text"] as? [AnyObject] {
                        
                        if openHours.count > 0 {
                            cell.timingsLabel.text = openHours[0] as? String ?? ""
                        } else {
                            cell.timingsLabel.text = "Open Now"
                        }
                    }
                } else {
                    cell.timingsLabel.text = "Timings are not Available"
                }
            } else {
                cell.timingsLabel.text = "Timings are not Available"
            }

            cell.selectionStyle = .none
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isIntroVideo && indexPath.section == 0 {
            
            let introVideo = self.placeDetailInfo.placeIntoVideo

            self.playVideoByUrl(videoUrl: introVideo?.VideoURL ?? "sdasd")
        }
    }
    
    // 7
    internal func playVideoByUrl(videoUrl:String) {
        
        let player = AVPlayer(url: URL(string: videoUrl)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("end = \(indexPath)")
        if let videoCell = cell as? EventPostVideoCell {
            videoCell.stopPlayback()
        }
        
        paused = true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        print("end = \(indexPath)")
        if let videoCell = cell as? EventPostVideoCell {
            videoCell.startPlayback()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isIntroVideo && indexPath.section == 0 {
         return 210
        } else if !isIntroVideo && indexPath.section == 0 || isIntroVideo && indexPath.section == 1{
            return 290
        } else {
            return 300
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if isClaimed {
            return 10.0
        } else {
            return section == 1 ? 80.0 : 10.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if isIntroVideo && section == 0 {
            return 0.0
        } else if !isIntroVideo && section == 0 || isIntroVideo && section == 1{
           return  0.0
        } else {
            return 30.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isIntroVideo && section == 0 {
            return UIView()
        } else if !isIntroVideo && section == 0 || isIntroVideo && section == 1{
             return UIView()
        } else {
           return self.setHeaderView(title: "ABOUT")
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 1 && !isClaimed {
            
            let hearderView: UIView = UIView()
            hearderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80)
            hearderView.backgroundColor = UIColor.clear

            let btn = UIButton(type: .custom) as UIButton
            btn.setTitle("Claim this Location", for: .normal)
            //E44235
            btn.backgroundColor = UIColor(rgb: 0xE44235)
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.frame = CGRect(x: 15, y: 30, width: hearderView.frame.size.width - 30, height: 40)
            btn.titleLabel?.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 17)!
            
            btn.addTarget(self, action: #selector(createGroupEvent), for: .touchUpInside)
            hearderView.addSubview(btn)
            
            return hearderView
            
        } else {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
        }
        
    }
    
    // MARK:- Header View.
    internal func setHeaderView(title: String) -> UIView {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 30))
        
        label_Title.text = title
        
        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProSemiBold, size: 18)
        
        hearderView.addSubview(label_Title)
        
        return hearderView
        
    }
    
    
    func playerItemDidReachEnd(notification: Notification) {
        
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        
        p.seek(to: kCMTimeZero)
        
    }
    
    
    func checkVisibilityOfCell(cell : EventPostVideoCell, indexPath : IndexPath) {
        
        let cellRect = self.tableView_Main.rectForRow(at: indexPath)
        
        let completelyVisible = self.tableView_Main.bounds.contains(cellRect)
        
        if completelyVisible {
            
            self.playVideoOnTheCell(cell: cell, indexPath: indexPath)
            
        } else {
            
            if aboutToBecomeInvisibleCell != indexPath.row {
                
                aboutToBecomeInvisibleCell = indexPath.row
                
                self.stopPlayBack(cell: cell, indexPath: indexPath)
                
            }
            
        }
        
    }
    
}
