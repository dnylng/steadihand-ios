//
//  SettingsViewController.swift
//  Steadihand
//
//  Created by Danny Luong on 12/6/18.
//  Copyright © 2018 dnylng. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var velocityFrictionSlider: UISlider!
    @IBOutlet weak var positionFrictionSlider: UISlider!
    @IBOutlet weak var lowPassFilterSlider: UISlider!
    @IBOutlet weak var velocityAmplicationSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        velocityFrictionSlider.minimumValue = 0.0
        velocityFrictionSlider.maximumValue = 1.0
        velocityFrictionSlider.value = Float(Settings.shared.velFriction)
        
        positionFrictionSlider.minimumValue = 0.0
        positionFrictionSlider.maximumValue = 1.0
        positionFrictionSlider.value = Float(Settings.shared.posFriction)
        
        lowPassFilterSlider.minimumValue = 0.0
        lowPassFilterSlider.maximumValue = 1.0
        lowPassFilterSlider.value = Float(Settings.shared.lowPassFilter)
        
        velocityAmplicationSlider.minimumValue = 8000.0
        velocityAmplicationSlider.maximumValue = 25000.0
        velocityAmplicationSlider.value = Float(Settings.shared.velAmplication)
    }
    
    @IBAction func handleVelocityFriction(_ sender: Any) {
        Settings.shared.velFriction = Double(velocityFrictionSlider.value)
    }
    
    @IBAction func handlePositionFriction(_ sender: Any) {
        Settings.shared.posFriction = Double(positionFrictionSlider.value)
    }
    
    @IBAction func handleLowPassFilter(_ sender: Any) {
        Settings.shared.lowPassFilter = Double(lowPassFilterSlider.value)
    }
    
    @IBAction func handleVelocityAmplification(_ sender: Any) {
        Settings.shared.velAmplication = Double(velocityAmplicationSlider.value)
    }
    
    @IBAction func handleDefaults(_ sender: Any) {
        Settings.shared.velFriction = Constants.VELOCITY_FRICTION
        velocityFrictionSlider.value = Float(Constants.VELOCITY_FRICTION)
        
        Settings.shared.posFriction = Constants.POSITION_FRICTION
        positionFrictionSlider.value = Float(Constants.POSITION_FRICTION)
        
        Settings.shared.lowPassFilter = Constants.LOW_PASS_FILTER_ALPHA
        lowPassFilterSlider.value = Float(Constants.LOW_PASS_FILTER_ALPHA)
        
        Settings.shared.velAmplication = Constants.VELOCITY_AMPLIFICATION
        velocityAmplicationSlider.value = Float(Constants.VELOCITY_AMPLIFICATION)
    }
}
