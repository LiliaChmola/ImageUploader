//
//  SelectedIndexPath.swift
//  Image Uploader
//
//  Created by Chmola Lilia on 12/1/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import Foundation

class SelectedIndexPath {
    enum Status {
        case uploaded
        case uploading
        case failure
        case none
    }
    
    var indexPath: IndexPath
    var status: Status
    init(indexPath: IndexPath, status: SelectedIndexPath.Status) {
        self.indexPath = indexPath
        self.status = status
    }
}
