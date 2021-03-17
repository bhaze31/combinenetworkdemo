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

struct FetchUserResponse: Codable {
    var user: User
}

struct TokenResponse: Codable {
    var access: String
    var refresh: String?
}

class User: Codable, ObservableObject, Identifiable {
    var id: Int
    @Published var name: String
    @Published var email: String
    @Published var bio: String?
    
    init(id: Int, name: String, email: String, bio: String) {
        self.id = id
        self.name = name
        self.email = email
        self.bio = bio
    }

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

    typealias RetryHandler<T: Codable> = (T) -> Void
    
    private var network = NetworkController()

    private func defaultHeaders() -> [String: String] {
        return ["Content-Type": "application/json"]
    }
    
    private var subscriptions: Set<AnyCancellable> = []
}

