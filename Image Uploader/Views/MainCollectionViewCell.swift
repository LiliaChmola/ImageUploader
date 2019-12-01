//
//  MainCollectionViewCell.swift
//  Image Uploader
//
//  Created by Chmola Lilia on 11/26/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var isUploadImageView: UIImageView!
    
    var isUploaded: Bool {
        return !isUploadImageView.isHidden
    }
    
    func setDefaultStyle() {
        self.activityIndicator.isHidden = true
        self.isUploadImageView.isHidden = true
    }
    
    func setUploadedStyle() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.isUploadImageView.isHidden = false
    }
    
    func setUploadingStyle() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        self.isUploadImageView.isHidden = true
    }
}
