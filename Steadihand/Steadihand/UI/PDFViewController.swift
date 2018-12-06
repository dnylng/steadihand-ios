//
//  ViewController.swift
//  Steadihand
//
//  Created by Danny Luong on 8/31/18.
//  Copyright © 2018 dnylng. All rights reserved.
//

import UIKit
import PDFKit
import CoreMotion

class PDFViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
    var pdfView = PDFView()
    var pages = [UIImage]()
    var motionManager = CMMotionManager()
    
    let pageWidth = UIScreen.main.bounds.width
    let pageHeight = UIScreen.main.bounds.height
    
    var printUpdates = false
    
    
    // Acceleration calc variables
    var time = 0.0
    var acceleration = [Double](repeating: 0.0, count: 2)
    var velocity = [Double](repeating: 0.0, count: 2)
    var position = [Double](repeating: 0.0, count: 2)
    
    // MARK:- UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateArray()
        
        scrollView.delegate = self
        scrollView.frame = UIScreen.main.bounds
        scrollView.contentSize.width = pageWidth * CGFloat(pages.count)
        
        populateScrollView()
        positionResetTapGesture()
        printUpdatesTapGesture()
        
        startDeviceMotionUpdates()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        motionManager.stopAccelerometerUpdates()
        super.viewDidDisappear(animated)
    }
    
    // MARK:- Accelerometer updates
    
    func startDeviceMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
                guard let data = data, error == nil else {
                    NSLog("DEVICE MOTION ERROR: \(error?.localizedDescription ?? "Unable to read Device Motion updates")")
                    return
                }
                
                let x = Utils.nearestHundreth(Constants.GRAVITY * data.userAcceleration.x), y = Utils.nearestHundreth(Constants.GRAVITY * data.userAcceleration.y)
                let tempAcc = Utils.filteredAcceleration(acceleration: self.acceleration, x: x, y: y)
                
                self.acceleration = Utils.lowPassFilter(input: tempAcc, output: self.acceleration, alpha: Constants.LOW_PASS_FILTER_ALPHA)
                
                let timestamp = data.timestamp.magnitude
                
                if self.time == 0.0 {
                    self.velocity = self.velocity.map { _ in 0.0 }
                    self.position = self.position.map { _ in 0.0 }
                    self.acceleration = Utils.filteredAcceleration(acceleration: self.acceleration, x: x, y: y)
                    
                } else {
                    let dt = timestamp - self.time
                    
                    for i in 0...1 {
                        self.velocity[i] += self.acceleration[i] * dt - Constants.VELOCITY_FRICTION * self.velocity[i]
                        self.velocity[i] = Utils.fixNanOrInfinite(value: self.velocity[i])
                        
                        self.position[i] += self.velocity[i] * Constants.VELOCITY_AMPLIFICATION * dt - self.position[i] * Constants.POSITION_FRICTION
                        self.position[i] = Utils.rangeValue(value: self.position[i], min: -Constants.MAX_POS_SHIFT, max: Constants.MAX_POS_SHIFT)
                    }
                }
                
                self.time = timestamp
                let test1 = CGFloat(self.position[0])
                let test2 = CGFloat(-self.position[1])
                self.translateViewX(x: test1)
                self.translateViewY(y: test2)
                
                if self.printUpdates { print("ACCELERATION: x: \(x) and y: \(y)"); print("POSITION: x: \(self.position[0]) and y: \(self.position[1])") }
            }
        }
    }
    
    // MARK:- Helper methods
    
    func populateArray() {
        if let path = Bundle.main.path(forResource: "scottpilgrim", ofType: "pdf") {
            guard let pdfDocument = PDFDocument(url: URL(fileURLWithPath: path)) else { return }
            
            for i in 0...pdfDocument.pageCount {
                guard let page = pdfDocument.page(at: i) else { return }
                pages.append(page.thumbnail(of: UIScreen.main.bounds.size, for: .artBox))
            }
        } else {
            self.view.backgroundColor = UIColor.red
            NSLog("Could not find the PDF file.")
        }
    }
    
    func populateScrollView() {
        for (index, page) in pages.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleToFill
            imageView.image = page
            let xPos = pageWidth * CGFloat(index)
            imageView.frame = CGRect(x: xPos, y: 0, width: pageWidth, height: pageHeight)
            
            scrollView.addSubview(imageView)
        }
    }
    
    func translateViewX(x: CGFloat) {
        scrollView.transform.tx = x
    }
    
    func translateViewY(y: CGFloat) {
        scrollView.transform.ty = y
    }
    
    // MARK:- UITapGestures
    
    func positionResetTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePositionReset(_:)))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    @objc func handlePositionReset(_ recognizer: UITapGestureRecognizer) {
        position = position.map { _ in 0.0 }
        velocity = velocity.map { _ in 0.0 }
        acceleration = acceleration.map { _ in 0.0 }
        time = 0
        
        scrollView.transform.tx = 0
        scrollView.transform.ty = 0
        
        print("Double tapped! Reset scroll view to the origin.")
    }
    
    func printUpdatesTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePrintUpdates(_:)))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 5
        view.addGestureRecognizer(tap)
    }
    
    @objc func handlePrintUpdates(_ recognizer: UITapGestureRecognizer) {
        self.printUpdates = !self.printUpdates
    }
    
}
