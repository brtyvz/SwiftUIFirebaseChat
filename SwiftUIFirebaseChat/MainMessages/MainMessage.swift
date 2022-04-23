//
//  MainMessage.swift
//  SwiftUIFirebaseChat
//
//  Created by Berat Yavuz on 17.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI

class MainMessagesViewModel : ObservableObject{
    @Published var errorMessage = ""
    @Published var chatUser : ChatUser?
    
    init(){
        DispatchQueue.main.async {
            self.isUserCurrentlyLogOut = FirebaseMenager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
    }
    
    
    func fetchCurrentUser (){
      guard let uid = FirebaseMenager.shared.auth.currentUser?.uid
      else{
          self.errorMessage = "ERROR"
            return}
     
      FirebaseMenager.shared.firestore.collection("users")
          .document(uid).getDocument { snapshot, error in
              if let error = error{
                  self.errorMessage = "error \(error.localizedDescription)"
              }
              guard let data = snapshot?.data()
              else{
                  self.errorMessage = "efefef"
                  return}
              _ = data["uid"] as? String ?? ""
              _ = data["email"] as? String ?? ""
              _ = data["profileImageUrl"] as? String ?? ""
              
              self.chatUser = ChatUser(data: data)
              
          }
      
    }
    @Published var isUserCurrentlyLogOut = false
    func handleLogOut(){
        isUserCurrentlyLogOut.toggle()
      try?  FirebaseMenager.shared.auth.signOut()
    }
    
    
}

struct MainMessage: View {
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatView = false
    @ObservedObject private var vm = MainMessagesViewModel()
    
    private var customNavBar : some View{
        
        HStack(spacing:16){
           
            WebImage(url: URL(string:vm.chatUser?.profieImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50.0)
                .font(.system(size: 50))
                    
                        .overlay(RoundedRectangle(cornerRadius: 44)
                            .stroke(Color(.label),lineWidth: 1)
                            )

            VStack(alignment: .leading , spacing: 4){
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                
                HStack{
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                }
            }
            Spacer()
            Button {
                self.shouldShowLogOutOptions.toggle()
              
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 22,weight: .bold))
                    .foregroundColor(Color(.label))
            }

           
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do"), buttons: [ .destructive(Text("Sign Out"),action: {
                print("handle to sign out")
                vm.handleLogOut()
                
            }),
                .cancel()
                                                                                             ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLogOut,onDismiss: nil) {
            LoginView(didComplateLoginProcess: {self.vm.isUserCurrentlyLogOut = false
                vm.fetchCurrentUser()
                
            })
           
        }
    }
    var body: some View {
        NavigationView{
            VStack{
              
              customNavBar
                messageView
                NavigationLink("", isActive: $shouldNavigateToChatView) {
                    ChatLogView(chatUser: self.chatUser)
                }
                
            }.overlay(
              newMessageButton
              ,alignment: .bottom
            )
            .navigationBarHidden(true)
    }
    }
    private var messageView:some View{
        ScrollView{
            ForEach (0...10, id: \.self ){ num in
                NavigationLink {
                    ChatLogView(chatUser: self.chatUser)
                } label: {
                    HStack(spacing:16){
                    Image(systemName: "person.fill").font(.system(size: 32))
                            .padding(6)
                            .overlay(RoundedRectangle(cornerRadius: 34)
                                .stroke(Color(.label),lineWidth: 1)
                            ).foregroundColor(Color(.label))
                    VStack(alignment: .leading){
                        Text("username").font(.system(size: 16,weight: .bold)).foregroundColor(Color(.label))
                        Text("message to user").font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                        Text("22d").font(.system(size: 14,weight: .semibold)).foregroundColor(Color(.label))
                }
                }

                    VStack{
              
                    Divider()
                            .padding(.horizontal,8)
            }.padding(.horizontal)
            }.padding(.bottom,50)
        }
    }
    @State var shouldShowNewMessageScreen = false
        private var newMessageButton : some View{
            
            Button{
                shouldShowNewMessageScreen.toggle()
            }label: {
                HStack{
                    Spacer()
                    Text("+ New Message")
                        .font(.system(size: 16,weight: .bold))
                    Spacer()
                }
                .foregroundColor(Color.white)
                .padding(.vertical)
                    .background(Color.blue)
                    .cornerRadius(32)
                    .padding(.horizontal)
                    .shadow(radius: 15)
            }
            .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
                CreateNewMessageView(didSelectNewUser: {
                    user in
                    print(user.email)
                    
                    self.shouldNavigateToChatView.toggle()
                    self.chatUser = user
                })
            }
            
        }
    @State var chatUser : ChatUser?
}










struct MainMessage_Previews: PreviewProvider {
    static var previews: some View {
        MainMessage()
            .preferredColorScheme(.dark)
        
        
        MainMessage()
    }
}



