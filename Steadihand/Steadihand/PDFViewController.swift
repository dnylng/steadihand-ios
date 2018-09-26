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
    var acceleration = [Double](repeating: 0.0, count: 3)
    var velocity = [Double](repeating: 0.0, count: 3)
    var position = [Double](repeating: 0.0, count: 3)
    
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
        if self.motionManager.isDeviceMotionAvailable, let queue = OperationQueue.current {
            motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: queue) { (data, error) in
                if error != nil {
                    NSLog("DEVICE MOTION ERROR: \(error?.localizedDescription ?? "Unable to read Device Motion updates")")
                    return
                }
                
                if let x = data?.userAcceleration.x, let y = data?.userAcceleration.y, let z = data?.userAcceleration.z {
                    if self.printUpdates { print("DEVICE MOTION UPDATES: x: \(x), y: \(y), and z: \(z)") }
                }
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
            imageView.contentMode = .scaleAspectFit
            imageView.image = page
            let xPos = pageWidth * CGFloat(index)
            imageView.frame = CGRect(x: xPos, y: 0, width: pageWidth, height: pageHeight)
            
            scrollView.addSubview(imageView)
        }
    }
    
    func translateView(x: CGFloat, y: CGFloat, z: CGFloat) {
        scrollView.frame.origin.x -= x
        scrollView.frame.origin.y += y
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
        
        scrollView.frame.origin.x = 0
        scrollView.frame.origin.y = 0
        
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
