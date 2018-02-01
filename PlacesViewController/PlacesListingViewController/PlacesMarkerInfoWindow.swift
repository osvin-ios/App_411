//
//  PlacesMarkerInfoWindow.swift
//  App411
//
//  Created by osvinuser on 10/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class PlacesMarkerInfoWindow: UIView {
    
    // Outlet
    @IBOutlet var imageView_EventImage: DesignableImageView!
    
    @IBOutlet var label_EventName: UILabel!
    
    @IBOutlet var label_EventTime: UILabel!

    var eventInfoModel : ACreateEventInfoModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        
        let view = UINib(nibName: "PlacesMarkerInfoWindow", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        
        view.frame = bounds
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view);
        
    }

    
}

