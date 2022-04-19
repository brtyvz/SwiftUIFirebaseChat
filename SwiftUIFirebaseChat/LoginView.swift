//
//  ContentView.swift
//  SwiftUIFirebaseChat
//
//  Created by Berat Yavuz on 13.04.2022.
//

import SwiftUI
import Firebase
import FirebaseFirestore






struct LoginView: View {
    @State var isLoginMode = true
    @State var email = ""
    @State var password = ""
    @State var shouldShowImagePicker = false
    var body: some View {
        NavigationView{
            ScrollView{
                Picker(selection: $isLoginMode, label: Text("deneme"), content: {
                    Text("Login").tag(true)
                    Text("Register").tag(false)
                }).pickerStyle(SegmentedPickerStyle()).padding()
                if (!isLoginMode){
                    
                    Button(action: {
                        self.shouldShowImagePicker.toggle()
                        
                    }, label: {
                        VStack{
                        if let image = image
                        {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 128, height: 128, alignment: .center)
                                .cornerRadius(64.0)
                        }
                        else{
                            Image(systemName: "person.fill").font(.system(size:64 )).padding()
                        }
                        }
                    })
                    
                }
                Group{
                    
                    TextField("Email", text: $email).keyboardType(.emailAddress).autocapitalization(.none)
                    SecureField("Password",text: $password)
                    
                }.padding(12).background(Color.white).frame(width: 350, height: 50, alignment: .center).cornerRadius(15.0)
               
             
                
                Button(action: {handleAction()}, label: {
                    HStack{
                        Text(isLoginMode ? "Login" :"Register" ).frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.05, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).background(Color.blue).foregroundColor(.white).cornerRadius(20.0)
                    }
                }).padding()
                
                Text(loginErrorHandle).foregroundColor(.red)
                
            }.navigationTitle(isLoginMode ? "Login" : "Register" )
            .background(Color(.init(white: 0, alpha: 0.08)).ignoresSafeArea())
 
        }
        
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, content: {
            ImagePicker(image: $image)
        })
        
    }
    @State var image:UIImage?
    private func handleAction(){
        if isLoginMode{
           loginAccount()
        }
        else{createAccount()}
    }
    
    //LoginAccount
    private func loginAccount(){
        FirebaseMenager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Loggin Successful")
        }
        
    }
    
    
    //Register Func
    @State var loginErrorHandle = ""
    private func createAccount(){
        FirebaseMenager.shared.auth.createUser(withEmail: self.email, password: self.password) { Result, error in
            if let error = error{
                self.loginErrorHandle = "Failed to create user: \(error.localizedDescription)"
                return
            }
            self.loginErrorHandle = "Succesfuly created user"
            self.persistImageToStorage()
        }
        
        
    }
    private func persistImageToStorage(){
        guard let uid = FirebaseMenager.shared.auth.currentUser?.uid
        else{return}
        
        let ref = FirebaseMenager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5)else{return}
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error{self.loginErrorHandle = "Failed to upload image\(error.localizedDescription)"
    return
            }
            
            ref.downloadURL { url, error in
                if let  error = error{self.loginErrorHandle = "Failed to retrieve image\(error.localizedDescription)"
                    return
                }
                self.loginErrorHandle = "Succesfuly  retrieve image\(url?.absoluteString ?? "")"
           
                guard let url = url else {return}; self.storeUserInformation(imageProfileUrl: url)
               
                
            }
        }
       
        
    }
    private func storeUserInformation(imageProfileUrl:URL){
        guard let uid = FirebaseMenager.shared.auth.currentUser?.uid
        else{return}
        let userData = ["email":self.email,"uid":uid,"profileImageUrl":imageProfileUrl.absoluteString]
        FirebaseMenager.shared.firestore.collection("users")
            .document(uid).setData(userData){ err in
                if let err = err{
                    self.loginErrorHandle = "Failed to upload userData to firebase"
                    print(err)
                    return
                }
                
                print("succes")
            }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
