//
//  PHAssetExtension.swift
//  Image Uploader
//
//  Created by Chmola Lilia on 11/27/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import UIKit
import Photos

extension PHAsset {
    var thumbnailImage : UIImage {
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
            thumbnail = image!
        })
        return thumbnail
    }
    
    var originalImage: UIImage {
        var image: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: self, options: options) { data, _, _, _ in
            
            if let data = data {
                image = UIImage(data: data)
            }
        }
        return image!
    }
}
