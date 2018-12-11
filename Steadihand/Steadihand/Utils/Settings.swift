//
//  Settings.swift
//  Steadihand
//
//  Created by Danny Luong on 12/6/18.
//  Copyright © 2018 dnylng. All rights reserved.
//

import UIKit

class Settings {
    static let shared = Settings()
    
    var velFriction = Constants.VELOCITY_FRICTION
    var posFriction = Constants.POSITION_FRICTION
    var velAmplication = Constants.VELOCITY_AMPLIFICATION
    var lowPassFilter = Constants.LOW_PASS_FILTER_ALPHA
}
