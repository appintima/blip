//
//  CustomAnnotationView.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 12/21/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Mapbox
//
// MGLAnnotationView subclass
class CustomAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()
        super.isEnabled = true
        // Force the annotation view to maintain a constant size when the map is tilted.
        scalesWithViewingDistance = false
        
    }

}
