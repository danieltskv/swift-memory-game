//
//  CustomizeCardsTableViewController.swift
//  MemoryGame
//
//  Created by Daniel Tsirulnikov on 17/04/16.
//  Copyright © 2016 Daniel Tsirulnikov. All rights reserved.
//

import UIKit

class CustomizeCardsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  // MARK: - Properties
  
  var cards: [UIImage] = MemoryGame.defaultCardImages
  
  var selectedIndexPath: IndexPath?
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  // MARK: - Methods
  
  private func didPressChangeCard(index: Int, sender: UIView?) {
    let alertController = UIAlertController(title: NSLocalizedString("Select card image source:", comment: "-"), message: nil, preferredStyle: .actionSheet)
    
    alertController.popoverPresentationController?.sourceView = sender
    
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      let PhotoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo Library", comment: "pl"), style: .default) { [weak self] (action) in
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self?.present(imagePicker, animated: true, completion: nil)
      }
      alertController.addAction(PhotoLibraryAction)
    }
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let CameraAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: "tp"), style: .default) { [weak self] (action) in
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        self?.present(imagePicker, animated: true, completion: nil)
      }
      alertController.addAction(CameraAction)
    }
    
    let URLAction = UIAlertAction(title: NSLocalizedString("Insert URL", comment: "url"), style: .default) { [weak self] (action) in
      self?.promptImageURL()
    }
    alertController.addAction(URLAction)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true) { }
  }
  
  private func promptImageURL() {
    let alertController = UIAlertController(title: NSLocalizedString("Enter Image URL:", comment: "title"), message: nil, preferredStyle: .alert)
    
    let enterUrlAction = UIAlertAction(title: NSLocalizedString("Load", comment: "load"), style: .default) { [weak self] (_) in
      let textField = alertController.textFields![0] as UITextField
      guard let url = NSURL(string: textField.text!) else { return }
      self?.loadImage(url: url)
    }
    enterUrlAction.isEnabled = false
    alertController.addAction(enterUrlAction)
    
    alertController.addTextField { (textField) in
      textField.placeholder = NSLocalizedString("Image URL", comment: "image url")
      textField.keyboardType = .URL
      
      NotificationCenter.default.addObserver(forName:NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: {
        (notification) in
        enterUrlAction.isEnabled = textField.text != ""
      })
    }
    
    let cancelAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "dismiss"), style: .cancel) { (action) in }
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true) { }
  }
  
  private func loadImage(url: NSURL) {
    UIImage.downloadImage(url: url) { [weak self] (image: UIImage?) -> Void in
      guard let image = image else { return }
      self?.changeCard(index: (self?.selectedIndexPath!.row)!, image: image)
    }
  }
  
  private func changeCard(index: Int, image: UIImage) {
    cards[index] = image
    MemoryGame.defaultCardImages[index] = image
    tableView.reloadRows(at: [NSIndexPath(row: index, section: 0) as IndexPath], with: .automatic)
  }
  
  // MARK: - UITableViewDataSource
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cards.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath as IndexPath)
    
    let textLabel: UILabel = cell.viewWithTag(1) as! UILabel
    let imageView: UIImageView = cell.viewWithTag(2) as! UIImageView
    
    // Configure the cell...
    let card = cards[indexPath.row]
    
    textLabel.text = String(format: "Card %d", indexPath.row+1)
    imageView.image = card
    
    return cell
  }
  
  // MARK: - UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    let imageView = tableView.cellForRow(at: indexPath)?.contentView.viewWithTag(2) as! UIImageView
    selectedIndexPath = indexPath
    didPressChangeCard(index: indexPath.row, sender: imageView)
  }
  
  // MARK: - UIImagePickerControllerDelegate
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    picker.dismiss(animated: true, completion: nil)
    
    guard let selectedIndexPath = selectedIndexPath else { return }
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      changeCard(index: selectedIndexPath.row, image: image)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}
