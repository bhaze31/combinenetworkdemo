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
}
