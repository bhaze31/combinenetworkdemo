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

    typealias RequestHandler<T: Codable> = (T) -> Void

    private var network = NetworkController()

    private func defaultHeaders() -> [String: String] {
        return ["Content-Type": "application/json"]
    }
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private var refreshSubscription: AnyCancellable?

    private func handleFetchMap(data: Data, _response: URLResponse) throws -> Data {
        // Check response code, etc, throw any errors
        guard let response = _response as? HTTPURLResponse else {
            throw NetworkError.Unknown
        }
        
        if response.statusCode >= 400 {
            switch response.statusCode {
                case 401:
                    throw NetworkError.NotAllowed
                default:
                    throw NetworkError.Unknown
            }
        }

        return data
    }
    
    private func handleFetchCompletion(complete: Subscribers.Completion<Error>) {
        switch complete {
            case .failure(let e):
                print(e)
                if let err = e as? NetworkError, err == NetworkError.NotAllowed {
                    print("NOT ALLOWED TO TAKE THAT ACTION")
                }
            case .finished:
                print("User API Completed")
                
        }
    }
    
    private func handleFetchCompletionWithRetry<T: Codable>(complete: Subscribers.Completion<Error>, retry: AnyPublisher<T, Error>, handler: @escaping RequestHandler<T>) {
        switch complete {
            case .failure(let e):
                print(e)
                if let err = e as? NetworkError, err == NetworkError.NotAllowed {
                    print("NOT ALLOWED TO TAKE THAT ACTION")
                    // In reality, make another call, get a token, do something, etc. This
                    // will just fail again
                    retry
                        .sink(receiveCompletion: handleFetchCompletion, receiveValue: handler)
                        .store(in: &subscriptions)
                }
            case .finished:
                print("User API Completed")
                
        }
    }
    
    
    func handlePossibleRefreshToken<T: Codable>() -> AnyPublisher<T, Error> {
        let endpoint = Endpoint(path: "/users")
        
        return network.get(url: endpoint.url, headers: defaultHeaders(), handler: handleFetchMap)
            .eraseToAnyPublisher()
    }

    func fetchUsers() {
        let endpoint = Endpoint(path: "/users")
        
        let request: AnyPublisher<FetchUsersResponse, Error> = network.get(url: endpoint.url, headers: defaultHeaders(), handler: handleFetchMap)

        network.get(url: endpoint.url, headers: defaultHeaders(), handler: handleFetchMap)
            .sink(
                receiveCompletion: { self.handleFetchCompletionWithRetry(complete: $0, retry: request, handler: self.handleFetchUsers) },
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

        let request: AnyPublisher<CreateUserResponse, Error> = network.post(url: endpoint.url, body: bodyData, headers: defaultHeaders(), handler: handleFetchMap)
            
        network.post(url: endpoint.url, body: bodyData, headers: defaultHeaders(), handler: handleFetchMap)
            .sink(
                receiveCompletion: { self.handleFetchCompletionWithRetry(complete: $0, retry: request, handler: self.handleCreateUser(callback: callback)) },
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
    
    func editUser(id: Int, name: String, email: String, bio: String, callback: @escaping () -> Void) {
        let endpoint = Endpoint(path: "/users/\(id)")
        
        let bodyData = [
            "name": name,
            "email": email,
            "bio": bio
        ]
        
        let request: AnyPublisher<CreateUserResponse, Error> = network.put(url: endpoint.url, body: bodyData, headers: defaultHeaders(), handler: handleFetchMap)

        network.put(url: endpoint.url, body: bodyData, headers: defaultHeaders(), handler: handleFetchMap)
            .sink(
                receiveCompletion: { self.handleFetchCompletionWithRetry(complete: $0, retry: request, handler: self.handleEditUser(callback: callback)) },
                receiveValue: handleEditUser(callback: callback)
            )
            .store(in: &subscriptions)
    }
    
    func handleEditUser(callback: @escaping () -> Void) -> (CreateUserResponse) -> Void {
        func _handleEditUser(response: CreateUserResponse) {
            if let _user = self.users.filter({ $0.id == response.user.id }).first {
                _user.bio = response.user.bio
            } else {
                self.users.append(response.user)
            }
            self.selectedUser = response.user
            
            callback()
        }
        
        return _handleEditUser
    }
    
    func fetchUser(userID: Int) {
        let endpoint = Endpoint(path: "/users/\(userID)")
        
        let request: AnyPublisher<FetchUserResponse, Error> = network.get(url: endpoint.url, headers: defaultHeaders(), handler: handleFetchMap)

        network.get(url: endpoint.url, headers: defaultHeaders(), handler: handleFetchMap)
            .sink(
                receiveCompletion: { self.handleFetchCompletionWithRetry(complete: $0, retry: request, handler: self.handleFetchUser) },
                receiveValue: handleFetchUser
            )
            .store(in: &subscriptions)
    }

    private func handleFetchUser(response: FetchUserResponse) {
        if let _user = self.users.filter({ $0.id == response.user.id }).first {
            _user.bio = response.user.bio
        } else {
            self.users.append(response.user)
        }
        
        self.selectedUser = response.user
    }
}

