//
//  NetworkManager.swift
//  Image Uploader
//
//  Created by Chmola Lilia on 11/27/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    
    func post(image: UIImage, _ username: String, success: @escaping (String) -> Void, failure: @escaping () -> Void) {
        
        let imageData = image.pngData()
        let base64Image = imageData?.base64EncodedString(options: .lineLength64Characters)
        let url = "https://api.imgur.com/3/upload"
        let parameters = [
            "image": base64Image
        ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let imageData = image.pngData() {
                multipartFormData.append(imageData, withName: username, fileName: "\(username).png", mimeType: "image/png")
            }
            
            for (key, value) in parameters {
                multipartFormData.append((value?.data(using: .utf8))!, withName: key)
            }}, to: url, method: .post, headers: ["Authorization": "Client-ID " + "448858eea9eb78d"],
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.response { response in
                            let json = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String:Any]
                            let imageDic = json?["data"] as? [String:Any]
                            if let imageString = imageDic?["link"] as? String {
                                success(imageString)
                            } else {
                                failure()
                            }
                        }
                    case .failure(let encodingError):
                        print("error:\(encodingError)")
                        failure()
                    }
        })
    }
}
