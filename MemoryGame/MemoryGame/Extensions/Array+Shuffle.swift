//
//  Array+Shuffle.swift
//  MemoryGame
//
//  Created by Daniel Tsirulnikov on 19.3.2016.
//  Copyright © 2016 Daniel Tsirulnikov. All rights reserved.
//

import Foundation

extension Array {
  //Randomizes the order of the array elements
  mutating func shuffle() {
    for _ in 1...self.count {
      self.sort { (a, b) -> Bool in
        return arc4random() < arc4random()
      }
    }
  }
}
