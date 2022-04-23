//
//  ChatLogView.swift
//  SwiftUIFirebaseChat
//
//  Created by Berat Yavuz on 22.04.2022.
//

import SwiftUI

struct ChatLogView:View{
    let chatUser:ChatUser?
    
    var body: some View{
        
        ScrollView{
            ForEach(0..<10){num in
                Text("deneme")
            }
            
            
            
        }.navigationTitle(" mail \(chatUser?.email ?? "" )")
            .navigationBarTitleDisplayMode(.inline)
        
        
    }
    
    
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView(chatUser: nil)
    }
}
