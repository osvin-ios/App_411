//
//  PlacesShowByMapViewController.swift
//  ListDemo
//
//  Created by osvinuser on 10/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import GoogleMaps



class PlacesShowByMapViewController: UIViewController {

    @IBOutlet var mapView: GMSMapView!

    var gmsMarkerInfoWindow = PlacesMarkerInfoWindow()

    fileprivate var array_GMSMarker = [GMSMarker]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setMapViewLayout()
        
        self.showRadiusCircle()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(reloadEventList), name: NSNotification.Name(rawValue: "showNearByPlacesNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchDataAccordingToUserSelectedCategoriesAndRadius), name: NSNotification.Name(rawValue: "fetchDataAccordingToUserSelectedCategoriesAndRadius"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    func convertMilesIntoMeters(miles: Float) -> Float {
        
        return 1609.344 * miles;
    }
    
    
    func setMapZoomToRadius(lat:Double, lng:Double, mile:Double) {

        let center = CLLocationCoordinate2DMake(lat, lng)
        let radius: Double = (mile ) * 621.371

        let region = MKCoordinateRegionMakeWithDistance(center, radius * 2.0, radius * 2.0)

        let northEast = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta, region.center.longitude - region.span.longitudeDelta)
        let  southWest = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta, region.center.longitude + region.span.longitudeDelta)

        print("\(region.center.longitude)  \(region.span.longitudeDelta)")
        let bounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)

        let camera =  self.mapView.camera(for: bounds, insets: .zero)
        self.mapView.camera = camera!

    }
    
    
    func showRadiusCircle() {
        
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
        
        let userCurrentLocation: CLLocationCoordinate2D = Singleton.sharedInstance.userCurrentLocation

        self.setMapZoomToRadius(lat: userCurrentLocation.latitude, lng: userCurrentLocation.longitude, mile: Double(sliderValue))

        let rediusCircle = GMSCircle(position: userCurrentLocation, radius: CLLocationDistance(self.convertMilesIntoMeters(miles: sliderValue)))
        rediusCircle.fillColor = UIColor(rgb: 0x1464F4, a:0.15)
        rediusCircle.strokeColor = UIColor.clear
        rediusCircle.strokeWidth = 2.0;
        rediusCircle.map = self.mapView;
        
    }
    
    // MARK: - set Map View Layout
    
    internal func setMapViewLayout() {
        
        // User Current Location.
        let userCurrentLocation: CLLocationCoordinate2D = Singleton.sharedInstance.userCurrentLocation
        print(userCurrentLocation)
        
        DispatchQueue.main.async {
            // Set Map View Position.

            self.mapView.isMyLocationEnabled = true
           // self.mapView.camera = camera
            self.mapView.delegate = self
        }
        
      //  self.reloadEventList()
    }
    
    // MARK: - realod
    
    internal func reloadEventList() {
        
        if Singleton.sharedInstance.array_PlacesList.count > 0 {
            
            for dict in Singleton.sharedInstance.array_PlacesList {
                
                if let gmsMarker: GMSMarker = self.addEventMarkers(dict: dict) {
                    self.array_GMSMarker.append(gmsMarker)
                }
                
            }
            
        }
        
    }
    
    
    func fetchDataAccordingToUserSelectedCategoriesAndRadius() {
        
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

        let paramType = "types"
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(self.convertMilesIntoMeters(miles: sliderValue))&\(paramType)=\(searchTypeCategory)&key=AIzaSyCaSjiwkdmPQrKdhRCSWWJXFAq9gbFPuik"
        
        print("get wallet balance url string is \(urlString)")
        
        
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            DispatchQueue.main.async(execute: {
                
                if (error != nil) {
                    
                    print(error?.localizedDescription ?? "error details not found")
                    print(error ?? "error not found")
                    
                } else {
                    
                    if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode  {
                        
                        if response.statusCode == 201 || response.statusCode == 200 {
                            
                            // Check Data
                            if let data = data {
                                
                                // Json Response
                                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject>  {
                                    
                                    Singleton.sharedInstance.array_PlacesList.removeAll()
                                    
                                    
                                    if let results = jsonResponse?["results"] as? [Dictionary<String, AnyObject>]  {
                                        print(results)
                                        
                                        Singleton.sharedInstance.array_PlacesList = results
                                        
                                        self.mapView.clear()
                                        
                                        if Singleton.sharedInstance.array_PlacesList.count > 0 {
                                            
                                            for dict in Singleton.sharedInstance.array_PlacesList {
                                                
                                                if let gmsMarker: GMSMarker = self.addEventMarkers(dict: dict) {
                                                    self.array_GMSMarker.append(gmsMarker)
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                        self.showRadiusCircle()
                                    }
                                    
                                } else {
                                    print("nothing found")
                                }
                                
                            } else {
                                print("nothing found bbb")

                            }
                            
                        } else {
                            print("nothing found vvvv")

                        }
                        
                    } else {
                        print("nothing found mmm")

                    }
                    
                }
                
            })
            
        })
        
        dataTask.resume()
        
    }
    
    // MARK:- Add Event Marker
    func addEventMarkers(dict: Dictionary<String, AnyObject>) -> GMSMarker?  {
        
        guard let geometry = dict["geometry"] as? Dictionary<String, AnyObject>  else {
            return nil
        }
        
        guard let location = geometry["location"] as? Dictionary<String, AnyObject>  else {
            return nil
        }
        
        guard let latitude = location["lat"] as? Double else {
            return nil
        }
        
        guard let logitude = location["lng"] as? Double else {
            return nil
        }
        
        // GMSMarker
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: logitude)
        marker.appearAnimation = .pop
        marker.icon = #imageLiteral(resourceName: "ic_marker_general")
        marker.userData = dict
        marker.map = mapView
        
        return marker
        
    }
    
    
    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

     //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
         let destination = segue.destination as! PlacesDetailViewController
         self.navigationController?.view.backgroundColor = UIColor.white
         destination.googleDict = sender as! Dictionary<String, AnyObject>
        
    }
 

}

extension PlacesShowByMapViewController : GMSMapViewDelegate {
    
    
    //MARK:- Google Map View Delegates.
    
    func mapViewDidStartTileRendering(_ mapView: GMSMapView) {
        
    }
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        print(marker.userData ?? "Data!!!!!...")
        
        if let dict = marker.userData as? Dictionary<String, AnyObject>  {
        
//            guard let geometry = dict["geometry"] as? Dictionary<String, AnyObject>  else {
//                return
//            }
//
//            guard let location = geometry["location"] as? Dictionary<String, AnyObject>  else {
//                return
//            }
//
//            guard let latitude = location["lat"] as? Double else {
//                return
//            }
//
//            guard let logitude = location["lng"] as? Double else {
//                return
//            }
            
            self.performSegue(withIdentifier: "seguePlaceDetail", sender: dict)
//            let directionStr = "http://maps.google.com/maps?daddr=" + "\(latitude)" + "," + "\(logitude)"
//            Methods.sharedInstance.openURL(url: URL(string: directionStr)!)
            
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return gmsMarkerInfoWindow
    }
    
    // reset custom infowindow whenever marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        gmsMarkerInfoWindow.removeFromSuperview()
        
        if let dict = marker.userData as? Dictionary<String, AnyObject> {
            
            gmsMarkerInfoWindow = PlacesMarkerInfoWindow()
            
            if let photoRefArray = dict["photos"] as? [Dictionary<String, AnyObject>] {
                
                let photoRef : String = photoRefArray[0]["photo_reference"] as! String
                
                let imageUrl = SharedInstance.googleImageURL(imageWidth: 100) + photoRef
                gmsMarkerInfoWindow.imageView_EventImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "ic_no_image"))
                
            }
            
            if let name = dict["name"] as? String {
                gmsMarkerInfoWindow.label_EventName.text = name
            }
            
            if let address = dict["vicinity"] as? String {
                gmsMarkerInfoWindow.label_EventTime.text = address
            }
            
            gmsMarkerInfoWindow.frame = CGRect(x: 0, y: 0, width: 250, height: 240)
            
            gmsMarkerInfoWindow.center = mapView.projection.point(for: marker.position)
            gmsMarkerInfoWindow.center.y = gmsMarkerInfoWindow.center.y - sizeForOffset(view: gmsMarkerInfoWindow)
            self.mapView.addSubview(gmsMarkerInfoWindow)
            
        }
    
        return false
        
    }
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        gmsMarkerInfoWindow.removeFromSuperview()
    }
    
    // MARK: Needed to create the custom info window (this is optional)
    func sizeForOffset(view: UIView) -> CGFloat {
        return  180.0
    }
    
    // let the custom infowindow follows the camera
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        if (mapView.selectedMarker != nil) {
            
            let location = mapView.selectedMarker?.position
            
            gmsMarkerInfoWindow.center = mapView.projection.point(for: location!)
            gmsMarkerInfoWindow.center.y = gmsMarkerInfoWindow.center.y - sizeForOffset(view: gmsMarkerInfoWindow)
            
        }
    }
}


