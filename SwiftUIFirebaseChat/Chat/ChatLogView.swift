//
//  ChatLogView.swift
//  SwiftUIFirebaseChat
//
//  Created by Berat Yavuz on 22.04.2022.
//

import SwiftUI
import Firebase
class ChatLogViewModal:ObservableObject{
    @Published var chatText = ""
    @Published var errorMessage = ""
    let chatUser : ChatUser?
    init(chatUser:ChatUser?){
        self.chatUser = chatUser
    }
    func handleSend(){
        print(chatText)
        guard let fromId = FirebaseMenager.shared.auth.currentUser?.uid
        else{return}
        
        guard let toId = chatUser?.uid  else{return}
    
        let document = FirebaseMenager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
      
        let messageData = ["fromId":fromId , "toId":toId , "text":self.chatText,"timestap":Timestamp() ] as [String:Any]
        
        document.setData(messageData){error in
            if let error = error{
                self.errorMessage = "Failed to save message into firebase\(error)"
            }
            print("ddd")
            self.chatText = ""
        }
        let recipiantMessageDocument = FirebaseMenager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipiantMessageDocument.setData(messageData){error in
            if let error = error{
                self.errorMessage = "Failed to save message into firebase\(error)"
            }
        }
    }
}

struct ChatLogView:View{
    let chatUser:ChatUser?
    init(chatUser:ChatUser?){
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
        
    }
    @ObservedObject var vm : ChatLogViewModal
 
    var body: some View{
        ZStack{  messageView
            Text(vm.errorMessage)
        }
      
//        ZStack{
//
//           messageView
//            VStack{
//                Spacer()
//                chatBottomBar
//                    .background(Color.white)
//            }
//
//
//        }
 
        .navigationTitle("  \(chatUser?.email ?? "" )")
            .navigationBarTitleDisplayMode(.inline)
        
        
    }
    var chatBottomBar : some View{
        
        HStack{
            
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                          DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
                      }
                      .frame(height: 40)
            
            Button {
                vm.handleSend()
            } label: {
                Text("Send").foregroundColor(.white)
                    
            }
            .padding(.horizontal)
            .padding(.vertical,8)
            .background(Color.green)
            .cornerRadius(20)
        }
        .padding(.horizontal)
        .padding(.vertical,8)
        
        
    }
    private struct DescriptionPlaceholder: View {
        var body: some View {
            HStack {
                Text("Description")
                    .foregroundColor(Color(.gray))
                    .font(.system(size: 17))
                    .padding(.leading, 5)
                    .padding(.top, -4)
                Spacer()
            }
        }
    }
    var messageView : some View{
        VStack{
            
            if #available(iOS 15.0, *) {
                ScrollView{
                    ForEach(0..<10){num in
                        HStack{
                            
                            Spacer()
                            HStack{
                                Text("Fake Message").foregroundColor(.white)
                                
                            }
                            .frame(width: 190, height: 50)
                            .background(Color.blue)
                            .cornerRadius(20)
                            .padding(0)
                        }
                        .padding(.horizontal)
                        .padding(.top,8)
                         
                    }
                    
                    HStack{Spacer()}
                    
                }.background(Color(.init(gray: 0.95, alpha: 1)))
                    .safeAreaInset(edge: .bottom) {
                        chatBottomBar
                            .background(Color(.systemBackground).ignoresSafeArea())
                    }
            } else {
                // Fallback on earlier versions
            }
            
            
        }
    }
    
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ChatLogView(chatUser: .init(data: ["uid":  "kSeqZFeNS0eLIR8pnvA35kkDprn1","email":"waterfall@gmail.com"]))
            
        }
        
    }
}
