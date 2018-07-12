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
    
    DispatchQueue.global().async {
      var image: UIImage? = nil
      
      defer {
        DispatchQueue.main.async {
          completion?(image)
        }
      }
      
      if let data = NSData(contentsOf: url as URL) {
        image = UIImage(data: data as Data)
      }
    }
  }
}
