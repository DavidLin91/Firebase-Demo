//
//  StorageService.swift
//  Firebase-Demo
//
//  Created by David Lin on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageService {
    
    // in our app, we will be uploading a photo to storage in two places (ProfileViewController and CreateItemViewComtroller)
    
    // we will be creating two different buckets of folders 1. UserProfilePhotos 2.ItemsPhotos/
    
    // lets create a reference to the Firebase Storage
    private let storageRef = Storage.storage().reference()
    
    //default parameters in Swift ex: userId: String? = nil
    public func uploadPhoto(userId: String? = nil, itemId: String? = nil, image: UIImage, completion: @escaping (Result<URL, Error>) -> ()) {
        
        //1. Convert UIImage to Data because this is the objet wea re posting to Firebase
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // we need to establish which bucket or colletion of folder we will be saving the photo to
        var photoReference: StorageReference!
        
        if let userId = userId { //coming from ProfileViewController
            photoReference = storageRef.child("UserProfilePhotos/\(userId).jpeg")
            
        } else if let itemId = itemId { // coming from ItemViewController
            photoReference = storageRef.child("ItemsPhotos/\(itemId).jpeg")
        }
        
        // configure metadata for the object being uploaded
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = photoReference.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else if let _ = metadata {
                photoReference.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    }
                    
                }
            }
        }
    }
}
