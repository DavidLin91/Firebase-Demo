//
//  DatabaseServices.swift
//  Firebase-Demo
//
//  Created by David Lin on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseService {
    
    static let itemsCollection = "items" // a collection
    static let usersCollection = "users"
    static let commentsColleciton = "comments" // sub-collection on an item document
    
    // review - firebase works like this
    // top level
    // collection -> document -> collection -> document -> ...
    
    // let's get a rrference to the Firebase Firestore database
    private let db = Firestore.firestore()
    
    public func createItem(itemName: String, price: Double, category: Category, displayName: String, completion: @escaping (Result<String, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        // generate a document id for the "items" collection
        // db references overall database
        // if items collection "item" is not yet created, this will automatically create the collection
        let documentRef = db.collection(DatabaseService.itemsCollection).document()
        
        // create a document in our "items" collection
        db.collection(DatabaseService.itemsCollection).document(documentRef.documentID).setData(["itemName": itemName, "price": price, "itemID":documentRef.documentID , "listedDate": Timestamp(date: Date ()), "sellerName": displayName, "sellerId": user.uid, "categoryName": category.name]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(documentRef.documentID))
            }
        }
        
    }
    
    
    public func createDatabaseUser(authDataResult: AuthDataResult, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let email = authDataResult.user.email else { return }
        db.collection(DatabaseService.usersCollection).document(authDataResult.user.uid).setData(["email": email,
                                                                                                  "createdDate": Timestamp(date: Date()),
                                                                                                  "userId": authDataResult.user.uid]) { (error) in
                                                                                                    if let error = error {
                                                                                                        completion(.failure(error))
                                                                                                    } else {
                                                                                                        completion(.success(true))
                                                                                                    }
        }
    }
    
    
    func updateDatabaseUser(displayName: String, photoURL: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        
        db.collection(DatabaseService.usersCollection).document(user.uid).updateData(["photoURL" : photoURL, "displayName": displayName]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }

    }
    
    
    
    public func delete(item: Item, completion:  @escaping (Result <Bool, Error>) -> ()) {
        db.collection(DatabaseService.itemsCollection).document(item.itemId).delete { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    
}
