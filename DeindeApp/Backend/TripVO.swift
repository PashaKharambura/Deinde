//
//  TripVO.swift
//  DeindeApp
//
//  Created by Andrey Krit on 7/22/17.
//  Copyright © 2017 Andrey Krit. All rights reserved.
//

import Foundation
import ObjectMapper


struct TripVO: Mappable {
    var title: String?
    var tripData: Date?
    var tripImage: URL?
    var tripBenefits: [String]
    
    
    
    
}
