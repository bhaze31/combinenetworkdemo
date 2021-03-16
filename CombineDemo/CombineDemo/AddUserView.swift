//
//  AddUserView.swift
//  CombineDemo
//
//  Created by Brian Hasenstab on 3/15/21.
//

import SwiftUI

struct AddUserView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var state: AppState

    @State var name: String = ""
    @State var email: String = ""
    @State var bio: String = ""

    
    var body: some View {
        VStack {
            HStack {
                Text("Create User")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                if state.userViewModel.attemptingToAddUser {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    Button(action: createUser) {
                        Text("Add")
                    }
                    .padding()
                }
            }
            Form {
                Section(header: Text("Contact Info")) {
                    TextField("Full name", text: $name)
                    TextField("Email", text: $email)
                }
                
                Section(header: Text("Bio")) {
                    TextEditor(text: $bio)
                }
            }
        }
    }
    
    func createUser() {
        state.userViewModel.createUser(name: name, email: email, bio: bio) {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView().environmentObject(AppState())
    }
}
