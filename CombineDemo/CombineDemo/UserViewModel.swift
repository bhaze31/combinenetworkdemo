//
//  UserViewModel.swift
//  CombineDemo
//
//  Created by Brian Hasenstab on 3/15/21.
//

import Foundation
import Combine

struct FetchUsersResponse: Codable {
    var users: [User]
}

struct CreateUserResponse: Codable {
    var user: User
}

struct DeleteUserResponse: Codable {
    var success: Bool
}

class User: Codable, ObservableObject, Identifiable {
    var id: Int
    @Published var name: String
    @Published var email: String
    @Published var bio: String?
    
    required init(from decoder: Decoder) throws {
        let coder = try decoder.container(keyedBy: CodingKeys.self)
        id = try coder.decode(Int.self, forKey: .id)
        name = try coder.decode(String.self, forKey: .name)
        email = try coder.decode(String.self, forKey: .email)
        bio = try coder.decodeIfPresent(String.self, forKey: .bio)
    }
    
    func encode(to encoder: Encoder) throws {
        var coder = encoder.container(keyedBy: CodingKeys.self)
        try coder.encode(self.id, forKey: .id)
        try coder.encode(self.name, forKey: .name)
        try coder.encode(self.email, forKey: .email)
        try coder.encode(self.bio, forKey: .bio)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case email
        case bio
    }
}

final class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var selectedUser: User?
    @Published var attemptingToAddUser: Bool = false

    private var network = NetworkController()

    private func defaultHeaders() -> [String: String] {
        return ["Content-Type": "application/json"]
    }
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private func handleFetchMap(data: Data, response: URLResponse) throws -> Data {
        // Check response code, etc, throw any errors
        return data
    }
    
    private func handleFetchCompletion(complete: Subscribers.Completion<Error>) {
        switch complete {
            case .failure(let e):
                print(e)
            case .finished:
                print("User API Completed")
        }
    }

    func fetchUsers() {
        let endpoint = Endpoint(path: "/users")
        
        network.get(url: endpoint.url, headers: defaultHeaders(), handler: handleFetchMap)
            .sink(
                receiveCompletion: handleFetchCompletion,
                receiveValue: handleFetchUsers
            )
            .store(in: &subscriptions)
    }

    private func handleFetchUsers(response: FetchUsersResponse) {
        self.users = response.users
    }
    
    func createUser(name: String, email: String, bio: String, callback: @escaping () -> Void) {
        let endpoint = Endpoint(path: "/users")
        attemptingToAddUser.toggle()
        
        let bodyData = [
            "name": name,
            "email": email,
            "bio": bio
        ]

        network.post(url: endpoint.url, body: bodyData, headers: defaultHeaders(), handler: handleFetchMap)
            .sink(
                receiveCompletion: handleFetchCompletion,
                receiveValue: handleCreateUser(callback: callback)
            )
            .store(in: &subscriptions)
    }
    
    private func handleCreateUser(callback: @escaping () -> Void) -> (CreateUserResponse) -> Void {
        func _handleCreateUser(response: CreateUserResponse) {
            self.users.append(response.user)
            self.selectedUser = response.user
            self.attemptingToAddUser.toggle()
            
            callback()
        }
        
        return _handleCreateUser
    }
    
    func editUser(id: Int, name: String, email: String, bio: String) {
        let endpoint = Endpoint(path: "/users/\(id)")
        
        let bodyData = [
            "name": name,
            "email": email,
            "bio": bio
        ]
        
        network.put(url: endpoint.url, body: bodyData, headers: defaultHeaders(), handler: handleFetchMap)
            .sink(
                receiveCompletion: handleFetchCompletion,
                receiveValue: handleEditUser
            )
            .store(in: &subscriptions)
    }
    
    func handleEditUser(user: User) {
        self.selectedUser = user
    }
    
    func fetchUser(userID: Int) {
        let endpoint = Endpoint(path: "/users/\(userID)")
        
        network.get(url: endpoint.url, headers: defaultHeaders(), handler: handleFetchMap)
            .sink(
                receiveCompletion: handleFetchCompletion,
                receiveValue: handleFetchUser
            )
            .store(in: &subscriptions)
    }

    private func handleFetchUser(user: User) {
        self.selectedUser = user
    }
    
   
}

