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
    
    var selectedIndexPath: NSIndexPath?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Methods

    private func didPressChangeCard(index: Int) {
        let alertController = UIAlertController(title: NSLocalizedString("Select card image source:", comment: "-"), message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let PhotoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo Library", comment: "pl"), style: .Default) { [weak self] (action) in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                self?.presentViewController(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(PhotoLibraryAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let CameraAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: "tp"), style: .Default) { [weak self] (action) in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera
                self?.presentViewController(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(CameraAction)
        }
        
        let URLAction = UIAlertAction(title: NSLocalizedString("Insert URL", comment: "url"), style: .Default) { [weak self] (action) in
            self?.promptImageURL()
        }
        alertController.addAction(URLAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    private func promptImageURL() {
        let alertController = UIAlertController(title: NSLocalizedString("Enter Image URL:", comment: "title"), message: nil, preferredStyle: .Alert)
        
        let enterUrlAction = UIAlertAction(title: NSLocalizedString("Load", comment: "load"), style: .Default) { [weak self] (_) in
            let textField = alertController.textFields![0] as UITextField
            guard let url = NSURL(string: textField.text!) else { return }
            self?.loadImage(url)
        }
        enterUrlAction.enabled = false
        alertController.addAction(enterUrlAction)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = NSLocalizedString("Image URL", comment: "image url")
            textField.keyboardType = .URL
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification,
                object: textField,
                queue: NSOperationQueue.mainQueue()) { (notification) in
                    enterUrlAction.enabled = textField.text != ""
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "dismiss"), style: .Cancel) { (action) in }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    private func loadImage(url: NSURL) {
        UIImage.downloadImage(url) { [weak self] (image: UIImage?) -> Void in
            guard let image = image else { return }
            self?.changeCard((self?.selectedIndexPath!.row)!, image: image)
        }
    }
    
    private func changeCard(index: Int, image: UIImage) {
        cards[index] = image
        MemoryGame.defaultCardImages[index] = image
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cardCell", forIndexPath: indexPath)
        
        let textLabel: UILabel = cell.viewWithTag(1) as! UILabel
        let imageView: UIImageView = cell.viewWithTag(2) as! UIImageView

        // Configure the cell...
        let card = cards[indexPath.row]

        textLabel.text = String(format: "Card %d", indexPath.row+1)
        imageView.image = card
        
        return cell
    }
    
    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedIndexPath = indexPath
        didPressChangeCard(indexPath.row)
    }
    
    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)

        guard let selectedIndexPath = selectedIndexPath else { return }
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            changeCard(selectedIndexPath.row, image: image)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }


}
