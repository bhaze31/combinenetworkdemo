//
//  UserDetailView.swift
//  CombineDemo
//
//  Created by Brian Hasenstab on 3/15/21.
//

import SwiftUI

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct SavingView: View {
    @EnvironmentObject var state: AppState
    @Binding var editing: Bool
    
    var handleEditToggle: () -> Void

    var body: some View {
        VStack {
            if state.userViewModel.attemptingToAddUser {
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
        VStack {
            Text(user.name)
                .font(.title)
            Text(user.email)
                .font(.subheadline)
                .padding(.bottom, 30)

            
            if self.editing {
                TextEditor(text: $user.bio ?? "")
                    .padding()
            } else {
                Text(user.bio ?? "")
                    .padding()
            }
                
            Spacer()
        }
        .navigationBarItems(trailing:
            SavingView(editing: $editing, handleEditToggle: toggleEdit))
        .onAppear {
            if user.bio == nil {
                state.userViewModel.fetchUser(userID: user.id)
            }
        }
    }
    
    func toggleEdit() {
        if editing == true {
            state.userViewModel.editUser(id: user.id, name: user.name, email: user.email, bio: user.bio ?? "") {
                self.editing.toggle()
            }
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
