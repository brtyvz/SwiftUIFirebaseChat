//
//  ChatLogView.swift
//  SwiftUIFirebaseChat
//
//  Created by Berat Yavuz on 22.04.2022.
//

import SwiftUI
import Firebase

struct FirebaseConstants{
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
}


struct ChatMessage:Identifiable{
    var id :String{documentId}
    let fromId,toId,text:String
    let documentId :String
    init(documentId:String,data:[String:Any]){
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data [FirebaseConstants.toId] as? String  ?? ""
        self.text = data [FirebaseConstants.text] as? String  ?? ""
    }
}
class ChatLogViewModal:ObservableObject{
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    let chatUser : ChatUser?
    init(chatUser:ChatUser?){
        self.chatUser = chatUser
        fetchMessage()
    }
    private func fetchMessage () {
        guard let fromId = FirebaseMenager.shared.auth.currentUser?.uid else{return}
                
        guard let  toId = chatUser?.uid else {return}
        
        FirebaseMenager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .addSnapshotListener { querySnapshot, error in
                if let    error = error {
                    self.errorMessage = "failed to listen for message"
                    print(error)
                    return
                }
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                  
//                    let docId = change.documentID
                    
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                }
                })
            }
        
        
        
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
      
        let messageData = [FirebaseConstants.fromId:fromId , FirebaseConstants.toId:toId , FirebaseConstants.text:self.chatText,"timestap":Timestamp() ] as [String:Any]
        
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
                    ForEach(vm.chatMessages){message in
                        VStack{
                            if message.fromId == FirebaseMenager.shared.auth.currentUser?.uid {
                                HStack{
                                    
                                    Spacer()
                                    HStack{
                                        Text(message.text).foregroundColor(.white)
                                        
                                    }
                                    .frame(width: 190, height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                                    .padding(0)
                                }
                       
                            }
                            else{
                                HStack{
                                    
                                    Spacer()
                                    HStack{
                                        Text(message.text).foregroundColor(.black)
                                        
                                    }
                                    .frame(width: 190, height: 50)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .padding(0)
                                }
                       
                                
                            }
                            
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
