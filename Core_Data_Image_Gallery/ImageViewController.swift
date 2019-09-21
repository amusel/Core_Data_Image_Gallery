//
//  ImageViewController.swift
//  Image_Gallery
//
//  Created by Artem Musel on 9/10/19.
//  Copyright © 2019 Artem Musel. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageURL: URL?
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activitySpinner.startAnimating()
        
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.activitySpinner.stopAnimating()
                        self?.imageView.image = UIImage(data: imageData)
                        self?.imageView.sizeToFit()
                        
                        
                        // The size of the image
                        let imageSize = self?.imageView?.image?.size ?? CGSize.zero
                        
                        // Size of the display
                        let displaySize = self?.scrollView.bounds.size ?? CGSize.zero
                        
                        // Scrollview content-size must fit the image
                        self?.scrollView.contentSize = imageSize
                        
                        // A scale that will fit the whole image on screen
                        let zoomScaleThatFitsWholeImage = min(displaySize.width/imageSize.width,
                                                              displaySize.height/imageSize.height)
                        self?.scrollView.minimumZoomScale = zoomScaleThatFitsWholeImage
                        self?.scrollView.maximumZoomScale = 2
                        self?.scrollView.zoomScale = zoomScaleThatFitsWholeImage
                        
                        
                        if let size = self?.imageView.frame.size {
                            self?.scrollView.contentSize = size
                            self?.scrollViewWidth.constant = size.width
                            self?.scrollViewHeight.constant = size.height
                        }
                    }
                    
                }
            }
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.addSubview(imageView)
            scrollView.delegate = self
        }
    }
    
    // MARK: UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }
}
