//
//  SelectedIndexPath.swift
//  Image Uploader
//
//  Created by Chmola Lilia on 12/1/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import Foundation

class SelectedIndexPath {
    var indexPath: IndexPath
    var isUploaded: Bool
    
    init(indexPath: IndexPath, isUploaded: Bool) {
        self.indexPath = indexPath
        self.isUploaded = isUploaded
    }
}
