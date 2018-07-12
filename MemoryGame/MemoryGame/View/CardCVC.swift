//
//  CardView.swift
//  MemoryGame
//
//  Created by Daniel Tsirulnikov on 19.3.2016.
//  Copyright © 2016 Daniel Tsirulnikov. All rights reserved.
//

import UIKit.UICollectionViewCell

class CardCVC: UICollectionViewCell {
  
  // MARK: - Properties
  
  @IBOutlet weak var frontImageView: UIImageView!
  @IBOutlet weak var backImageView: UIImageView!
  
  var card:Card? {
    didSet {
      guard let card = card else { return }
      frontImageView.image = card.image
    }
  }
  
  private(set) var shown: Bool = false
  
  // MARK: - Methods
  
  func showCard(show: Bool, animted: Bool) {
    frontImageView.isHidden = false
    backImageView.isHidden = false
    shown = show
    
    if animted {
      if show {
        UIView.transition(from: backImageView,
                          to: frontImageView,
                          duration: 0.5,
                          options: [.transitionFlipFromRight, .showHideTransitionViews],
                          completion: { (finished: Bool) -> () in
        })
      } else {
        UIView.transition(from: frontImageView,
                          to: backImageView,
                          duration: 0.5,
                          options: [.transitionFlipFromRight, .showHideTransitionViews],
                          completion:  { (finished: Bool) -> () in
        })
      }
    } else {
      if show {
        bringSubview(toFront: frontImageView)
        backImageView.isHidden = true
      } else {
        bringSubview(toFront: backImageView)
        frontImageView.isHidden = true
      }
    }
  }
  
  
}
