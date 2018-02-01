//
//  PlacesCardView.swift
//  ListDemo
//
//  Created by osvinuser on 10/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class PlacesCardView: UIView {
    
    @IBOutlet var imageBackgroundView: DesignableView!
    
    @IBOutlet var titleOfEventLabel: UILabel!
    
    @IBOutlet var eventImage: DesignableImageView!
    
    @IBOutlet var label_SubTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async {
            self.imageBackgroundView.layer.cornerRadius = (self.imageBackgroundView.frame.size.height)/2
            self.eventImage.layer.cornerRadius = (self.eventImage.frame.size.height)/2
            self.translatesAutoresizingMaskIntoConstraints = false
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
        }
    }
    
    func loadViewFromNib() {
        
        let view = UINib(nibName: "PlacesCardView", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view);
        self.layoutSubviews()
    }

}

