//
//  ViewController.swift
//  Steadihand
//
//  Created by Danny Luong on 8/31/18.
//  Copyright © 2018 dnylng. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    
    var pdfView = PDFView()
    var pages = [UIImage]()
    
    let pageWidth = UIScreen.main.bounds.width
    let pageHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateArray()
        
        scrollView.delegate = self
        scrollView.frame = UIScreen.main.bounds
        scrollView.contentSize.width = pageWidth * CGFloat(pages.count)
    
        populateScrollView()
    }
 
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
    
}

extension PDFViewController: UIScrollViewDelegate {
    
}
