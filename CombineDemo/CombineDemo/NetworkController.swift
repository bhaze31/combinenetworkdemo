//
//  NetworkController.swift
//  CombineDemo
//
//  Created by Brian Hasenstab on 3/15/21.
//

import Foundation
import Combine


struct Endpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
    
    let baseURL = URL(string: "http://localhost:8888")!
}

extension Endpoint {
    var url: URL {
        let _url = baseURL.appendingPathComponent(path).absoluteString
        if queryItems.count > 0, var components = URLComponents(string: _url) {
            components.queryItems = queryItems
            if let fullUrl = components.url {
                return fullUrl
            }
        }
        
        return baseURL.appendingPathComponent(path)
    }
}

class NetworkController {
    typealias RequestHandler = (Data, URLResponse) throws -> Data

    func get<T: Codable>(url: URL, headers: [String: String], handler: @escaping RequestHandler) -> AnyPublisher<T, Error> {
        
        var request = URLRequest(url: url)
        
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
        
        return makeRequest(request, handler: handler)
    }

    func post<T: Codable, B: Codable>(url: URL, body: B, headers: [String: String], handler: @escaping RequestHandler) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.httpBody = serializeCodable(body: body)
        
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
        
        return makeRequest(request, handler: handler)
    }
    
    func put<T: Codable, B: Codable>(url: URL, body: B, headers: [String: String], handler: @escaping RequestHandler) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: url)
        
        request.httpMethod = "PUT"
        request.httpBody = serializeCodable(body: body)
        
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
        
        return makeRequest(request, handler: handler)
    }
    
    func delete<T: Codable>(url: URL, headers: [String: String], handler: @escaping RequestHandler) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"

        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
        
        return makeRequest(request, handler: handler)
    }
    
    private func makeRequest<T: Codable>(_ request: URLRequest, handler: @escaping RequestHandler) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(handler)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func serializeCodable<T: Codable>(body: T, options: JSONSerialization.WritingOptions = []) -> Data? {
        return try? JSONEncoder().encode(body)
    }
}
