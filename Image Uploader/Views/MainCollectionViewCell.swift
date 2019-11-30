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
    
    func setDefaultStyle() {
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.activityIndicator.isHidden = true
        self.isUploadImageView.isHidden = true
    }
    
    func setUploadedStyle() {
        self.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.5450980392, blue: 0.5450980392, alpha: 1)
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.isUploadImageView.isHidden = false
    }
    
    func setUploadingStyle() {
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.activityIndicator.isHidden = false
        self.isUploadImageView.isHidden = true
        self.activityIndicator.startAnimating()
    }
}
