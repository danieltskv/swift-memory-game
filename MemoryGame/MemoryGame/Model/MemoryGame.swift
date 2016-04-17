//
//  MemoryGameController.swift
//  MemoryGame
//
//  Created by Daniel Tsirulnikov on 19.3.2016.
//  Copyright © 2016 Daniel Tsirulnikov. All rights reserved.
//

import Foundation
import UIKit.UIImage

// MARK: - MemoryGameDelegate

protocol MemoryGameDelegate {
    func memoryGameDidStart(game: MemoryGame)
    func memoryGame(game: MemoryGame, showCards cards: [Card])
    func memoryGame(game: MemoryGame, hideCards cards: [Card])
    func memoryGameDidEnd(game: MemoryGame, elapsedTime: NSTimeInterval)
}

// MARK: - MemoryGame

class MemoryGame {
    
    // MARK: - Properties

    static var defaultCardImages:[UIImage] = [
        UIImage(named: "brand1")!,
        UIImage(named: "brand2")!,
        UIImage(named: "brand3")!,
        UIImage(named: "brand4")!,
        UIImage(named: "brand5")!,
        UIImage(named: "brand6")!
    ];

    var cards:[Card] = [Card]()
    var delegate: MemoryGameDelegate?
    var isPlaying: Bool = false

    private var cardsShown:[Card] = [Card]()
    private var startTime:NSDate?

    var numberOfCards: Int {
        get {
            return cards.count
        }
    }
    
    var elapsedTime : NSTimeInterval {
        get {
            guard startTime != nil else {
                return -1
            }
            return NSDate().timeIntervalSinceDate(startTime!)
        }
    }
    
    // MARK: - Methods

    func newGame(cardsData:[UIImage]) {
        cards = randomCards(cardsData)
        startTime = NSDate.init()
        isPlaying = true
        delegate?.memoryGameDidStart(self)
    }

    func stopGame() {
        isPlaying = false
        cards.removeAll()
        cardsShown.removeAll()
        startTime = nil
    }
    
    func didSelectCard(card: Card?) {
        guard let card = card else { return }
        
        delegate?.memoryGame(self, showCards: [card])

        if unpairedCardShown() {
            let unpaired = unpairedCard()!
            if card.equals(unpaired) {
                cardsShown.append(card)
            } else {
                let unpairedCard = cardsShown.removeLast()
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.delegate?.memoryGame(self, hideCards:[card, unpairedCard])
                }
            }
        } else {
            cardsShown.append(card)
        }
        
        if cardsShown.count == cards.count {
            finishGame()
        }
    }
    
    func cardAtIndex(index: Int) -> Card? {
        if cards.count > index {
            return cards[index]
        } else {
            return nil
        }
    }
    
    func indexForCard(card: Card) -> Int? {
        for index in 0...cards.count-1 {
            if card === cards[index] {
                return index
            }
        }
        return nil
    }
    
    private func finishGame() {
        isPlaying = false
        delegate?.memoryGameDidEnd(self, elapsedTime: elapsedTime)
    }

    private func unpairedCardShown() -> Bool {
        return cardsShown.count % 2 != 0
    }
    
    private func unpairedCard() -> Card? {
        let unpairedCard = cardsShown.last
        return unpairedCard
    }
    
    private func randomCards(cardsData:[UIImage]) -> [Card] {
        var cards = [Card]()
        for i in 0...cardsData.count-1 {
            let card = Card.init(image: cardsData[i])
            cards.appendContentsOf([card, Card.init(card: card)])
        }
        cards.shuffle()
        return cards
    }
    
}