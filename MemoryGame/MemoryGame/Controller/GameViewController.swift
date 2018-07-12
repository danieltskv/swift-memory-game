//
//  GameViewController.swift
//  MemoryGame
//
//  Created by Daniel Tsirulnikov on 19.3.2016.
//  Copyright © 2016 Daniel Tsirulnikov. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MemoryGameDelegate {
  
  // MARK: Properties
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var playButton: UIButton!
  
  let gameController = MemoryGame()
  var timer:Timer?
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    gameController.delegate = self
    resetGame()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    if gameController.isPlaying {
      resetGame()
    }
  }
  
  // MARK: - Methods
  
  func resetGame() {
    gameController.stopGame()
    if timer?.isValid == true {
      timer?.invalidate()
      timer = nil
    }
    collectionView.isUserInteractionEnabled = false
    collectionView.reloadData()
    timerLabel.text = String(format: "%@: ---", NSLocalizedString("TIME", comment: "time"))
    playButton.setTitle(NSLocalizedString("Play", comment: "play"), for: .normal)
  }
  
  @IBAction func didPressPlayButton(_ sender: UIButton) {
    if gameController.isPlaying {
      resetGame()
      playButton.setTitle(NSLocalizedString("Play", comment: "play"), for: .normal)
    } else {
      setupNewGame()
      playButton.setTitle(NSLocalizedString("Stop", comment: "stop"), for: .normal)
    }
  }
  
  func setupNewGame() {
    let cardsData:[UIImage] = MemoryGame.defaultCardImages
    gameController.newGame(cardsData: cardsData)
  }
  
  @objc func gameTimerAction() {
    timerLabel.text = String(format: "%@: %.0fs", NSLocalizedString("TIME", comment: "time"), gameController.elapsedTime)
  }
  
  func savePlayerScore(name: String, score: TimeInterval) {
    Highscores.sharedInstance.saveHighscore(name: name, score: score)
  }
  
  // MARK: - UICollectionViewDataSource
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return gameController.numberOfCards > 0 ? gameController.numberOfCards : 12
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath as IndexPath) as! CardCVC
    cell.showCard(show: false, animted: false)
    
    guard let card = gameController.cardAtIndex(index: indexPath.item) else { return cell }
    cell.card = card
    
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! CardCVC
    
    if cell.shown { return }
    gameController.didSelectCard(card: cell.card)
    
    collectionView.deselectItem(at: indexPath as IndexPath, animated:true)
  }
  
  // MARK: - UICollectionViewDataSource
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //let numberOfColumns:Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
    
    let itemWidth: CGFloat = collectionView.frame.width / 3.0 - 15.0 //numberOfColumns as CGFloat - 10 //- (minimumInteritemSpacing * numberOfColumns))
    
    return CGSize(width: itemWidth, height: itemWidth)
  }
  
  // MARK: - MemoryGameDelegate
  
  func memoryGameDidStart(game: MemoryGame) {
    collectionView.reloadData()
    collectionView.isUserInteractionEnabled = true
    
    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(gameTimerAction), userInfo: nil, repeats: true)
  }
  
  func memoryGame(game: MemoryGame, showCards cards: [Card]) {
    for card in cards {
      guard let index = gameController.indexForCard(card: card) else { continue }
      let cell = collectionView.cellForItem(at: NSIndexPath(item: index, section:0) as IndexPath) as! CardCVC
      cell.showCard(show: true, animted: true)
    }
  }
  
  func memoryGame(game: MemoryGame, hideCards cards: [Card]) {
    for card in cards {
      guard let index = gameController.indexForCard(card: card) else { continue }
      let cell = collectionView.cellForItem(at: NSIndexPath(item: index, section:0) as IndexPath) as! CardCVC
      cell.showCard(show: false, animted: true)
    }
  }
  
  
  func memoryGameDidEnd(game: MemoryGame, elapsedTime: TimeInterval) {
    timer?.invalidate()
    
    let elapsedTime = gameController.elapsedTime
    
    let alertController = UIAlertController(
      title: NSLocalizedString("Hurrah!", comment: "title"),
      message: String(format: "%@ %.0f seconds", NSLocalizedString("You finished the game in", comment: "message"), elapsedTime),
      preferredStyle: .alert)
    
    let saveScoreAction = UIAlertAction(title: NSLocalizedString("Save Score", comment: "save score"), style: .default) { [weak self] (_) in
      let nameTextField = alertController.textFields![0] as UITextField
      guard let name = nameTextField.text else { return }
      self?.savePlayerScore(name: name, score: elapsedTime)
      self?.resetGame()
    }
    
    saveScoreAction.isEnabled = false
    alertController.addAction(saveScoreAction)
    
    alertController.addTextField { (textField) in
      textField.placeholder = NSLocalizedString("Your name", comment: "your name")
      
      NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange,
                                             object: textField,
                                             queue: OperationQueue.main) { (notification) in
                                              saveScoreAction.isEnabled = textField.text != ""
      }
    }
    
    let cancelAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "dismiss"), style: .cancel) { [weak self] (action) in
      self?.resetGame()
    }
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true) { }
  }
}

