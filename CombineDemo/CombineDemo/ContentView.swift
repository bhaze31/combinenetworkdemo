//
//  ContentView.swift
//  CombineDemo
//
//  Created by Brian Hasenstab on 3/15/21.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var userViewModel = UserViewModel()
    
    private var subscriptions: Set<AnyCancellable> = []

    init() {
        userViewModel.objectWillChange.sink(receiveValue: { self.objectWillChange.send() })
            .store(in: &subscriptions)
    }
}

struct UserRow: View {
    @ObservedObject var user: User
    
    var body: some View {
        NavigationLink(destination: Text("Hello")) {
            HStack {
                VStack(alignment: .leading) {
                    Text(user.name)
                        .fontWeight(.bold)
                        .font(.headline)
                    Text(user.email)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var state: AppState

    @State private var addUser: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                List(state.userViewModel.users) { user in
                    UserRow(user: user)
                }
                .listStyle(PlainListStyle())
                Spacer()
            }
            .navigationBarTitle("Contacts")
            .navigationBarItems(trailing:
                Button(action: showAddUsers) {
                    Image(systemName: "plus.circle")
                })
        }
        .onAppear {
            state.userViewModel.fetchUsers()
        }
        .sheet(isPresented: $addUser, onDismiss: navigateToUserOnCreation, content: {
            AddUserView()
                .environmentObject(state)
        })
    }
    
    func showAddUsers() {
        addUser.toggle()
    }
    
    func navigateToUserOnCreation() {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
