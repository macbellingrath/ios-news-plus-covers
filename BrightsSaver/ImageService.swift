//
//  ImageService.swift
//  BrightsSaver
//
//  Created by Mac Bellingrath on 4/1/19.
//  Copyright © 2019 Mac Bellingrath. All rights reserved.
//

#if TARGET_OS_IPHONE
import UIKit
#else
import AppKit
#endif
import Foundation

#if TARGET_OS_IPHONE
typealias Image = UIImage
#else
typealias Image = NSImage
#endif

class ImageService: NSObject {
    private let queue = DispatchQueue(label: "com.brights.imageservice")
    func getImage(url: URL, completion: @escaping (Result<Image, Error>) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, resp, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let image = Image(data: data) {
                completion(.success(image))
            } else {
                fatalError()
            }
        }).resume()
    }
}
