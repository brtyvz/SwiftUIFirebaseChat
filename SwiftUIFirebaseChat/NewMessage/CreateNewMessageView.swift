//
//  CreateNewMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by Berat Yavuz on 21.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI
class createNewMessageView : ObservableObject{
    
    @Published var errorMessage = ""
    @Published var users = [ChatUser]()
    
    init(){
        fetchAllUser()
    }
    private func fetchAllUser(){
        FirebaseMenager.shared.firestore.collection("users")
            .getDocuments { documentSnapshot ,  error in
                if let error = error{
                    self.errorMessage = "error.\(error.localizedDescription)"
                    print("failed to fetch user")
                    return
                }
                documentSnapshot?.documents.forEach({ snapshot in
                 
                  let data = snapshot.data()
                    let user = ChatUser(data: data)
                    
                    if user.uid != FirebaseMenager.shared.auth.currentUser?.uid {
                        
                        self.users.append(.init(data: data))
                    }
                   
                })
                self.errorMessage = "Succesfuly fetch users"
                
            }
        
    }
}


struct CreateNewMessageView: View {
    let didSelectNewUser : (ChatUser) ->()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = createNewMessageView()
    var body: some View {
        NavigationView{
            ScrollView{
              
                ForEach(vm.users){ user in
                    let mail = user.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack(spacing:16){
                            WebImage(url: URL(string:user.profieImageUrl ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50.0)
                                .font(.system(size: 50))
                                    
                                        .overlay(RoundedRectangle(cornerRadius: 44)
                                            .stroke(Color(.label),lineWidth: 1)
                                            )
                            
                            Text(mail).foregroundColor(Color(.label))
                                .padding()
                            Spacer()
                        }.padding(.horizontal)
                     
                    };   Divider()
                    
                        .padding(.vertical,8)

             
                }

            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }

                }
            }
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
     //   CreateNewMessageView()
        MainMessage()
    }
}







