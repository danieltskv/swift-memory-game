//
//  UIImage+Downloader.swift
//  MemoryGame
//
//  Created by Daniel Tsirulnikov on 17/04/16.
//  Copyright © 2016 Daniel Tsirulnikov. All rights reserved.
//
//  Based on a method from:
//  https://github.com/PerrchicK/swift-app/blob/master/SomeApp/SomeApp/Classes/Utilities/PerrFuncs.swift
//

import UIKit.UIImage

extension UIImage {
    static func downloadImage(url: NSURL, completion: ((UIImage?) -> Void)?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            var image: UIImage? = nil
            
            defer {
                dispatch_async(dispatch_get_main_queue()) {
                    completion?(image)
                }
            }
            
            if let data = NSData(contentsOfURL: url) {
                image = UIImage(data: data)
            }
        }
    }
}