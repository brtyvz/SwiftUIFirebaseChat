//
//  ChatUser.swift
//  SwiftUIFirebaseChat
//
//  Created by Berat Yavuz on 20.04.2022.
//

import Foundation
struct ChatUser : Identifiable{
    var id :String {uid}
    init(data:[String:Any]){
        self.uid =  data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profieImageUrl = data ["profileImageUrl"] as? String ?? ""
    }
    let uid,email,profieImageUrl : String
}
