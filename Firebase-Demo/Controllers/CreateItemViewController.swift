//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by David Lin on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateItemViewController: UIViewController {
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    
    private var category: Category
    
    private let dbService = DatabaseService()
    private let storageService = StorageService()
    
    private lazy var imagePickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self // conform to UIImagePickerControllerDelegate and UINavigationControllerDelegate
        return picker
    }()
    
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(showPhotoOption))
        return gesture
    }()
    
    private var selectedImage: UIImage? {
        didSet {
            itemImageView.image = selectedImage
        }
    }
    
    
    init?(coder: NSCoder, category: Category) {
        self.category = category
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = category.name
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func showPhotoOption() {
        let alertController = UIAlertController(title: "Choose Photo Option", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { alertAction in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
            
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { alertAction in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        alertController.addAction(photoLibrary)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    
    
    @IBAction func sellButtonPressed(_ sender: UIBarButtonItem) {
        guard let itemName = itemName.text,
            !itemName.isEmpty,
            let priceText = itemPrice.text,
            !priceText.isEmpty,
            let price = Double(priceText),
            let selectedImage = selectedImage else {
                showAlert(title: "Missing Fields", message: "All fields are required")
                return
        }
        
        guard let displayName = Auth.auth().currentUser?.displayName else {
            showAlert(title: "Incomplete Profile", message: "Please go to the profile to complete your settings")
            return
        }
        
        //resize image before uploading to storage
        let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: itemImageView.bounds)
        
        
        dbService.createItem(itemName: itemName, price: price, category: category, displayName: displayName) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "error creatingItem", message: "Sorry, something went wrong \(error.localizedDescription)")
                }
            case .success(let documentId):
                self?.uploadPhoto(photo: resizedImage, documentId: documentId)
            }
        }
    }
    
    private func uploadPhoto(photo: UIImage, documentId: String) {
        storageService.uploadPhoto(itemId: documentId, image: photo) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                self?.showAlert(title: "Error uploading photo", message: "\(error.localizedDescription)")
                }
            case .success(let url):
                self?.updateItemImageURL(url, documentId: documentId)
            }
        }
    }
    
    private func updateItemImageURL(_ url: URL, documentId: String) {
        Firestore.firestore().collection(DatabaseService.itemsCollection).document(documentId).updateData(["imageURL": url.absoluteString]) { [weak self] (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fail to update item", message: "\(error.localizedDescription)")
                }
            } else {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
                
        }
    }

}

extension CreateItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as?
            UIImage else {
                fatalError("could not attain original image")
        }
        selectedImage = image
        dismiss(animated: true)
    }
}
