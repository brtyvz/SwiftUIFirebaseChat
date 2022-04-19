//
//  FirebaseMenager.swift
//  SwiftUIFirebaseChat
//
//  Created by Berat Yavuz on 19.04.2022.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseMenager:NSObject{
    let auth : Auth
    let storage : Storage
    let firestore : Firestore
    static let shared = FirebaseMenager()
   override init () {
        FirebaseApp.configure()
        self.auth = Auth.auth()
    self.storage = Storage.storage()
    self.firestore = Firestore.firestore()

        super.init()
    }
}
