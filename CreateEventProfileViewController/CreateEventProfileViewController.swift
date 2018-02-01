//
//  CreateEventProfileViewController.swift
//  App411
//
//  Created by osvinuser on 7/11/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaPlayer
import AVKit

protocol CreateEventProfileViewControllerDelegate {
    func sendBackImageAndVideoURL(url:Any?, type:Int, error: Error!)
}

class CreateEventProfileViewController: UIViewController, CameraCustomControllerDelegate, ShowAlert {

    @IBOutlet fileprivate var tableView_Main: UITableView!

    @IBOutlet var playVideoButton: UIButton!
    
    var imageFullSize = UIImage()
    var imageThumbnailSize = UIImage()
    var videoURL : URL!
    var delegate: CreateEventProfileViewControllerDelegate?

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        playVideoButton.isHidden = true
        
        tableView_Main.register(UINib(nibName: "TableViewCellSignUpProfilePic", bundle: nil), forCellReuseIdentifier: "TableViewCellSignUpProfilePic")
        tableView_Main.register(UINib(nibName: "TableViewCellDetailsOption", bundle: nil), forCellReuseIdentifier: "TableViewCellDetailsOption")
        
        self.setViewBackground()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    // MARK: - Camera Delegate Method
    func fetchImageAndVideoURL(url: Any?, type: Int, error: Error!) {
        
        if (error != nil) {
            print(error.localizedDescription)
            return
        }
        //send data to create event controller class
        self.delegate?.sendBackImageAndVideoURL(url: url, type: type, error: error)
        
        self.getImageAndThumbnailOfImage(image: url , type: type)
    }
    
    //MARK: convert local URL and Image into Thumbnail
    fileprivate func getImageAndThumbnailOfImage(image: Any?, type: Int) {
        
        let cell: TableViewCellSignUpProfilePic = tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewCellSignUpProfilePic

        var imageThumbnail : UIImage?
        
        if type == 0 {
            
            playVideoButton.isHidden = true

            imageThumbnail = (image as! UIImage).createImageThumbnailFromImage()
            imageThumbnailSize = imageThumbnail!
            imageFullSize = image as! UIImage

        } else {
            
            playVideoButton.isHidden = false
            
            imageThumbnail = (image as! URL).createThumbnailFromUrl()
            imageThumbnailSize = imageThumbnail!
            imageFullSize = imageThumbnail!
            videoURL = image as! URL
        }
        
        cell.imageView_Images.image = imageThumbnail
        
    }
    

    @IBAction func showVideo(_ sender: Any) {
        
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        
    }
    
    //MARK:- Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "segueOptionFlyer" {
            
            let destinationView: ChooseFlyerViewController = segue.destination as! ChooseFlyerViewController
            destinationView.delegate = self
        }
        
    }
    
}



extension CreateEventProfileViewController: UITableViewDelegate, UITableViewDataSource, TableViewCellSignUpProfilePicDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
        
            let cell:TableViewCellSignUpProfilePic = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSignUpProfilePic") as! TableViewCellSignUpProfilePic
            
            cell.selectionStyle = .none
            
            cell.delegate = self
            
            return cell
            
        } else {
        
            let cell:TableViewCellDetailsOption = tableView.dequeueReusableCell(withIdentifier: "TableViewCellDetailsOption") as! TableViewCellDetailsOption
            
            cell.label_Text.text = "Choose Flyer"
            
            cell.selectionStyle = .none
            
            return cell
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 || indexPath.row == 0 {
        
            self.performSegue(withIdentifier: "segueOptionFlyer", sender: self)
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 160 : 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.1 : 10.0
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

    
    //MARK:- Cell Delegates
    func uploadProfilePicClick(sender: UIButton) {
        
        // Create the AlertController and add Its action like button in Actionsheet
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Camera", style: .default)
        { _ in
            
            print("Take Photo")
            
            let customCamera = self.storyboard?.instantiateViewController(withIdentifier: "CameraCustomController") as! CameraCustomController
            
            customCamera.delegate = self
            
            self.present(customCamera, animated: true, completion: nil)
            
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Photos Library", style: .default)
        { _ in
            print("Choose Photo")
            self.openImagePickerViewController(sourceType: .photoLibrary, mediaTypes: [kUTTypeImage as String, kUTTypeMovie as String])
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType  == "public.image" {
                print("Image Selected")
                
                self.delegate?.sendBackImageAndVideoURL(url: info[UIImagePickerControllerOriginalImage] as! UIImage, type: 0, error: nil)
                self.getImageAndThumbnailOfImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage , type: 0)
                
            }
            
            if mediaType == "public.movie" {
                print("Video Selected")
                
                self.delegate?.sendBackImageAndVideoURL(url: info[UIImagePickerControllerMediaURL] as! URL, type: 1, error: nil)
                self.getImageAndThumbnailOfImage(image: info[UIImagePickerControllerMediaURL] as! URL , type: 1)
                
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}

extension CreateEventProfileViewController: ChooseFlyerViewControllerDelegate {

    func selectedImageFromList(image: UIImage) {
        
        print(image)
        self.delegate?.sendBackImageAndVideoURL(url: image, type: 0, error: nil)
        self.getImageAndThumbnailOfImage(image: image, type: 0)

    }
    
}
