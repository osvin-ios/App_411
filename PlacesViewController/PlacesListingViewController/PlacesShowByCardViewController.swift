//
//  PlacesShowByCardViewController.swift
//  ListDemo
//
//  Created by osvinuser on 10/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class PlacesShowByCardViewController: UIViewController {
    
    @IBOutlet var kolodaView: KolodaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.reloadEventList()
        self.setCardViewProperties()
        
    }
    
    
    func reloadEventList() {
        self.kolodaView.dataSource = self
        self.kolodaView.delegate = self
    }
    
    func setCardViewProperties() {
        
        kolodaView.layer.masksToBounds = false
        kolodaView.layer.shadowColor = UIColor.darkGray.cgColor
        kolodaView.layer.shadowOpacity = 0.5
        kolodaView.layer.shadowOffset = CGSize(width: 0, height: 0)
        kolodaView.layer.shadowRadius = 2
        
    }
    
    
    // MARK: - IBActions
    
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(.left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(.right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
    
    
    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destination as! PlacesDetailViewController
        self.navigationController?.view.backgroundColor = UIColor.white
        destination.googleDict = sender as! Dictionary<String, AnyObject>
    }
    
}

extension PlacesShowByCardViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        //        let position = kolodaView.currentCardIndex
        //        kolodaView.insertCardAtIndexRange(position..<position + 4, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
        let dict = Singleton.sharedInstance.array_PlacesList[index]
        
        self.navigationController?.view.backgroundColor = UIColor.white
        self.performSegue(withIdentifier: "seguePlaceDetail", sender: dict)
        
    }
    
    func koloda(clickOnfavouriteButton favouritButton: UIButton) {
        
        
    }
    
}

extension PlacesShowByCardViewController: KolodaViewDataSource {
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return Singleton.sharedInstance.array_PlacesList.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let customCardView: PlacesCardView = PlacesCardView(frame: CGRect(x: 0, y: 0, width: kolodaView.frame.size.width, height: kolodaView.frame.size.height))
        
        // Configure the cell
        customCardView.layoutIfNeeded()
        
        customCardView.eventImage.layer.cornerRadius = (customCardView.eventImage.frame.size.height)/2
        customCardView.imageBackgroundView.layer.cornerRadius = (customCardView.imageBackgroundView.frame.size.height)/2
        let dict = Singleton.sharedInstance.array_PlacesList[index]
        
        if let photoRefArray = dict["photos"] as? [Dictionary<String, AnyObject>] {
            
            let photoRef : String = photoRefArray[0]["photo_reference"] as! String
            let imageUrl = SharedInstance.googleImageURL(imageWidth: customCardView.eventImage.frame.size.width) + photoRef
            
            customCardView.eventImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "ic_dummy_image"))
            
        }
        
        if let name = dict["name"] as? String {
            customCardView.titleOfEventLabel.text = name
        }
        
        if let address = dict["vicinity"] as? String {
            customCardView.label_SubTitle.text = address
        }
        
        customCardView.layoutSubviews()

        return customCardView
        
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
}

