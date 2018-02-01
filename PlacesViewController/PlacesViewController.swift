//
//  PlacesViewController.swift
//  App411
//
//  Created by osvinuser on 9/19/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit


class PlacesViewController: UIViewController, ShowAlert {

    // Outlet.
    @IBOutlet var searchBar_Main: UISearchBar!
    
    @IBOutlet var tableView_Main: UITableView!
    @IBOutlet var collectionView_Main: UICollectionView!
    @IBOutlet var button_UpDown: UIButton!
    
    
    var array_PlaceCategories = ["Food", "Drinks", "Shopping", "Travel", "Services", "Entertainment", "Health", "Transportation"]
    var array_PlaceCategoriesImages = [#imageLiteral(resourceName: "Food"), #imageLiteral(resourceName: "Drinks"), #imageLiteral(resourceName:"Shopping"), #imageLiteral(resourceName:"Travel"), #imageLiteral(resourceName:"Services"), #imageLiteral(resourceName:"Entertainment"), #imageLiteral(resourceName: "Health"), #imageLiteral(resourceName: "Transportation")] as [UIImage]
    
    
    var array_Json = [Dictionary<String, AnyObject>]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture))
        view.addGestureRecognizer(gesture)
        
        
        self.placesWebService(searchType: "food")

    }

    // MARK: - Up down Button Action
    
    @IBAction func button_UpDown(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            sender.setImage(#imageLiteral(resourceName: "DropDown"), for: .normal)

            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
            })
            
        } else {

            sender.setImage(#imageLiteral(resourceName: "DropUp"), for: .normal)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                self.view.endEditing(true)
            })
            
        }
        
    }
    
    
    
    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    let fullView: CGFloat = 0
    
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - (120 + UIApplication.shared.statusBarFrame.height)
    }
    
    func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        
        // print(y)
        // print(velocity.y)
        // print((self.partialView-64)/2)
        
        if y + translation.y >= fullView && y + translation.y <= partialView  {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }

        if recognizer.state == .ended {
            
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                
                if  velocity.y >= ((self.partialView-64)/2) ||  y >= ((self.partialView-64)/2) {
                    
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                    self.button_UpDown.setImage(#imageLiteral(resourceName: "DropUp"), for: .normal)
                    self.button_UpDown.isSelected = false
                    self.view.endEditing(true)

                } else {
                    
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                    self.button_UpDown.setImage(#imageLiteral(resourceName: "DropDown"), for: .normal)
                    self.button_UpDown.isSelected = true
                }
                
            }, completion: nil)
            
        }
        
    }
    
    
    func convertMilesIntoMeters(miles: Float) -> Float {
        
        return 1609.344 * miles;
    }
    
    func placesWebService(searchType: String) {
        
        let arraySelectedCategory = Singleton.sharedInstance.filterSelectedListInfo.flatMap({$0.event_name})
        
        print(arraySelectedCategory)
        let arrayContains = arraySelectedCategory.flatMap {$0.replacingOccurrences(of: " ", with: "%20") }

        let searchTypeCategory = arrayContains.joined(separator: "%7C")
        
        let getLocation = UserDefaults.standard.bool(forKey: "isuserlocationget")
        
        // Save Data in local.
        let latitude = UserDefaults.standard.value(forKey: "usercurrentlatitude") as? Float ?? 0.0
        let longitude = UserDefaults.standard.value(forKey: "usercurrentlongitude") as? Float ?? 0.0
        print("Latitude: - \(latitude) Logitude:- \(longitude)")
        
        if !getLocation {
            return
        }
        
        var sliderValue = Float()
        if let filterDistance = Singleton.sharedInstance.filterDistance {
            
            if let filterValue = Float(filterDistance) {
                sliderValue = filterValue
            } else {
                sliderValue = 10.0
            }
            
        } else {
            sliderValue = 10.0
        }
        
        Methods.sharedInstance.showLoader(object: self.view)
        
        let paramType = searchTypeCategory.characters.count > 0 ? "types" : "type"
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(self.convertMilesIntoMeters(miles: sliderValue))&\(paramType)=\(searchTypeCategory.characters.count > 0 ? searchTypeCategory : searchType)&key=AIzaSyCaSjiwkdmPQrKdhRCSWWJXFAq9gbFPuik"
        
        print("get wallet balance url string is \(urlString)")
        
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            Methods.sharedInstance.hideLoader(object: self.view)

            DispatchQueue.main.async(execute: {
                
                // print(data ?? "No Data found")
                // print(response ?? "No Data found")
                // print(error?.localizedDescription ?? "No Data found")

                if (error != nil) {
                    
                    print(error?.localizedDescription ?? "error details not found")
                    print(error ?? "error not found")
                    
                    // completion(false, "", AKErrorHandler.CommonErrorMessages.UNKNOWN_ERROR_FROM_SERVER)
                    
                } else {
                    
                    if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode  {
                        
                        if response.statusCode == 201 || response.statusCode == 200 {
                            
                            // Check Data
                            if let data = data {
                                
                                // Json Response
                                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject>  {
                                    
                                    self.array_Json.removeAll()
                                    
                                    
                                    if let results = jsonResponse?["results"] as? [Dictionary<String, AnyObject>]  {
                                        print(results)

                                        self.array_Json = results
                                        
                                        Singleton.sharedInstance.array_PlacesList = self.array_Json
                                        
                                        if self.array_Json.count > 0 {
                                            NotificationCenter.default.post(name: NSNotification.Name("showNearByPlacesNotification") , object: self, userInfo: ["results": results])
                                        } else {
                                            
                                            self.showAlert("No results found for this category.")
                                        }
                                        
                                    }
                                    
                                    // print(jsonResponse ?? "Data not found.")
                                    // completion(true, jsonResponse, "")
                                    
                                    DispatchQueue.main.async {
                                        self.tableView_Main.reloadData()
                                    }
                                    
                                } else {
                                    
                                    print(AKErrorHandler.CommonErrorMessages.INTERNAL_SERVER_ERROR)
                                    
                                }
                                
                            } else {
                                
                                print(AKErrorHandler.CommonErrorMessages.UNKNOWN_ERROR_FROM_SERVER)
                                
                            }
                            
                        } else {
                            
                            print(AKErrorHandler.CommonErrorMessages.UNKNOWN_ERROR_FROM_SERVER)
                            
                        }
                        
                    } else {
                        
                        print(AKErrorHandler.CommonErrorMessages.UNKNOWN_ERROR_FROM_SERVER)
                        
                    }
                    
                }
                
            })
            
        })
        
        dataTask.resume()
        
    }
    
    
    
    func getNearByPlacesWithText(searchText: String) {
        
        let getLocation = UserDefaults.standard.bool(forKey: "isuserlocationget")
        
        // Save Data in local.
        let latitude = UserDefaults.standard.value(forKey: "usercurrentlatitude") as? Float ?? 0.0
        let longitude = UserDefaults.standard.value(forKey: "usercurrentlongitude") as? Float ?? 0.0
        print("Latitude: - \(latitude) Logitude:- \(longitude)")
        
        if !getLocation {
            return
        }
        
        
        
        //&type=restaurant&name=panera&
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=1000&name=\(searchText)&key=AIzaSyCaSjiwkdmPQrKdhRCSWWJXFAq9gbFPuik"

        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            DispatchQueue.main.async(execute: {
                

                if (error != nil) {
                    
                    print(error?.localizedDescription ?? "error details not found")
                    print(error ?? "error not found")
                    // completion(false, "", AKErrorHandler.CommonErrorMessages.UNKNOWN_ERROR_FROM_SERVER)
                    
                } else {
                    
                    if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode  {
                        
                        if response.statusCode == 201 || response.statusCode == 200 {
                            
                            // Check Data
                            if let data = data {
                                
                                // Json Response
                                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject>  {
                                    
                                    self.array_Json.removeAll()
                                    
                                    if let results = jsonResponse?["results"] as? [Dictionary<String, AnyObject>]  {
                                        self.array_Json = results
                                    }
                                    
                                    Singleton.sharedInstance.array_PlacesList = self.array_Json

                                    NotificationCenter.default.post(name: NSNotification.Name("showNearByPlacesNotification") , object: self, userInfo: nil)

                                    print(self.array_Json)
                                        
                                    DispatchQueue.main.async {
                                        self.tableView_Main.reloadData()
                                    }
                                    
                                } else {
                                    
                                    print(AKErrorHandler.CommonErrorMessages.INTERNAL_SERVER_ERROR)
                                    
                                }
                                
                            } else {
                                
                                print(AKErrorHandler.CommonErrorMessages.UNKNOWN_ERROR_FROM_SERVER)
                                
                            }
                            
                        } else {
                            
                            print(AKErrorHandler.CommonErrorMessages.UNKNOWN_ERROR_FROM_SERVER)
                            
                        }
                        
                    } else {
                        
                        print(AKErrorHandler.CommonErrorMessages.UNKNOWN_ERROR_FROM_SERVER)
                        
                    }
                    
                }
                
            })
            
        })
        
        dataTask.resume()

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


extension PlacesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection setion: Int) -> Int {
        return self.array_Json.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: TableViewPlacesCell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier") as! TableViewPlacesCell
        
        let dict_Obj = self.array_Json[indexPath.row]
        
        if let photoRefArray = dict_Obj["photos"] as? [Dictionary<String, AnyObject>] {
            
            let photoRef : String = photoRefArray[0]["photo_reference"] as! String
            let imageUrl = SharedInstance.googleImageURL(imageWidth: cell.imageView_icon.frame.size.width) + photoRef
            
            cell.imageView_icon.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "ic_dummy_image"))
            
        }
        
        if let name = dict_Obj["name"] as? String {
            cell.label_Title.text = name
        }
        
        if let address = dict_Obj["vicinity"] as? String {
            cell.label_SubTitle.text = address
        }
        
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var array_SingleDict: [Dictionary<String, AnyObject>] = []
        array_SingleDict.append(self.array_Json[indexPath.row])
        
        NotificationCenter.default.post(name: NSNotification.Name("showNearByPlacesNotification") , object: self, userInfo: ["results": array_SingleDict])
        tableView.deselectRow(at: indexPath, animated:true)
        
        button_UpDown.setImage(#imageLiteral(resourceName: "DropUp"), for: .normal)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
            self.view.endEditing(true)
        })
        
    }
    
    
}

extension PlacesViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array_PlaceCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewPlacesCategoryCell", for: indexPath) as! CollectionViewPlacesCategoryCell
        
        cell.label_Title.text = array_PlaceCategories[indexPath.item]
        
        cell.imageView_image.image = array_PlaceCategoriesImages[indexPath.item]

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding : CGFloat = 0.0
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/4.2, height: collectionView.frame.size.height/2)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Tap on image view.")
        
        if indexPath.item == 0 {
        
            self.placesWebService(searchType: "food")
            
        } else if indexPath.item == 1 {
        
            self.placesWebService(searchType: "bar")

        } else if indexPath.item == 2 {
        
            self.placesWebService(searchType: "shopping_mall")

        } else if indexPath.item == 3 {
        
            self.placesWebService(searchType: "travel_agency")

        } else if indexPath.item == 4 {
        
            self.placesWebService(searchType: "spa")

        } else if indexPath.item == 5 {
        
            self.placesWebService(searchType: "movie_theater")

        } else if indexPath.item == 6 {
        
            self.placesWebService(searchType: "health")

        } else {
        
            self.placesWebService(searchType: "bus_station")

        }
        
    }
    
}


extension PlacesViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // called when text starts editing
        
        if self.view.frame.origin.y > self.fullView {
        
            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                self.button_UpDown.setImage(#imageLiteral(resourceName: "DropDown"), for: .normal)
                self.button_UpDown.isSelected = true
            })
            
        }
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        self.getNearByPlacesWithText(searchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
