//
//  UIImageExtension.swift
//  Image Uploader
//
//  Created by Chmola Lilia on 11/27/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo1MB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        let megaByte = 1000.0
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / megaByte
        
        while imageSizeKB > megaByte {
            guard let resizedImage = resizingImage.resized(withPercentage: 0.5),
                let imageData = resizedImage.pngData() else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / megaByte
        }
        return resizingImage
    }
}
