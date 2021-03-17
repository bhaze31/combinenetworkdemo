//
//  UserDetailView.swift
//  CombineDemo
//
//  Created by Brian Hasenstab on 3/15/21.
//

import SwiftUI

struct SavingView: View {
    @EnvironmentObject var state: AppState
    @Binding var editing: Bool
    
    var handleEditToggle: () -> Void
    var attemptingToAddUser = false

    var body: some View {
        VStack {
            if attemptingToAddUser {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button(action: handleEditToggle) {
                    Text(self.editing ? "Done" : "Edit")
                }
            }
        }
    }
}
struct UserDetailView: View {
    @EnvironmentObject var state: AppState

    @State var user: User
    @State var editing: Bool = false

    var body: some View {
        Text("User Details")
    }
    
    func toggleEdit() {
        if editing == true {
            // Save user
            self.editing.toggle()
        } else {
            self.editing.toggle()
        }
    }
}

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserDetailView(user: User(
                id: 0, name: "Brian Hasenstab", email: "bhasenstab@atlassian.com", bio: "The creator of the demo"
            ))
            .environmentObject(AppState())
        }
    }
}
