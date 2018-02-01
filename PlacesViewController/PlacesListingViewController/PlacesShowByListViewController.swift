//
//  PlacesShowByListViewController.swift
//  ListDemo
//
//  Created by osvinuser on 10/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class PlacesShowByListViewController: UIViewController {
    
    @IBOutlet var collectionView_Main: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // collectionView_Main.register(UINib(nibName: "FeaturedPageGoogleCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FeaturedPageGoogleCollectionViewCell")
        
        //self.setViewBackground()

    }
    
    
    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
 
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let destination = segue.destination as! PlacesDetailViewController
        self.navigationController?.view.backgroundColor = UIColor.white
        destination.googleDict = sender as! Dictionary<String, AnyObject>
     }

    
}

//extension PlacesShowByListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return Singleton.sharedInstance.array_PlacesList.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell: FeaturedPageGoogleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedPageGoogleCollectionViewCell", for: indexPath) as! FeaturedPageGoogleCollectionViewCell
//
//        // Configure the cell
//        cell.layoutIfNeeded()
//
//       // cell.backgroundColor = UIColor.black
//
//        return cell
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//
//        if let cellCustom = cell as? FeaturedPageGoogleCollectionViewCell {
//
//            let dict = Singleton.sharedInstance.array_PlacesList[indexPath.item]
//
//            if let image = dict["icon"] as? String {
//                cellCustom.avatarImage.sd_setImage(with: URL(string: image), placeholderImage: nil)
//            }
//
//            if let photoRefArray = dict["photos"] as? [Dictionary<String, AnyObject>] {
//
//                let photoRef : String = photoRefArray[0]["photo_reference"] as! String
//                let imageUrl = SharedInstance.googleImageURL(imageWidth: cellCustom.avatarImage.frame.size.width) + photoRef
//
//                cellCustom.avatarImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "ic_dummy_image"))
//
//            }
//
//            cellCustom.titleLabel?.text = dict["name"] as? String
//            cellCustom.descriptionLabel?.text = dict["vicinity"] as? String
//
//            let typesArray = dict["types"] as? [String] ?? []
//
//            if typesArray.count > 0 {
//                let searchTypeCategory = typesArray.joined(separator: " & ")
//                cellCustom.typeLabel?.text = searchTypeCategory
//            } else {
//                cellCustom.typeLabel?.text = "NA"
//            }
//
//            let array_CategoryList = Singleton.sharedInstance.categoryListInfo
//
//            if array_CategoryList.count > 0 {
//
//                let randomNumber = self.generateRandomNumber(min: 0, max: array_CategoryList.count)
//                let categoryDict = array_CategoryList[randomNumber]
//                cellCustom.googleBackgroundView.backgroundColor = UIColor(hex: categoryDict.color_code ?? "").withAlphaComponent(0.1)
//            }
//        }
//
//    }
//
//    func generateRandomNumber(min: Int, max: Int) -> Int {
//        let randomNum = Int(arc4random_uniform(UInt32(max) - UInt32(min)) + UInt32(min))
//        return randomNum
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let dict = Singleton.sharedInstance.array_PlacesList[indexPath.item]
//
//        self.navigationController?.view.backgroundColor = UIColor.white
//        self.performSegue(withIdentifier: "seguePlaceDetail", sender: dict)
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return CGSize(width: collectionView_Main.frame.size.width, height: 100)
//    }
//
//}

