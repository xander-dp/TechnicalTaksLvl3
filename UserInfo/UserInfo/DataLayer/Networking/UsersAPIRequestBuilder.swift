//
//  UsersAPIRequestBuilder.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

struct UsersAPIRequestBuilder: APIRequestBuilder {
    var scheme: String {
        "https"
    }
    
    var host: String {
        "randomuser.me"
    }
    
    func buildRequest(for endpoint: APIEndpoint) -> URLRequest? {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = endpoint.path
        urlComponents.queryItems = endpoint.querryParams
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        
        return request
    }
    
    func buildRequest(from absoluteString: String) -> URLRequest? {
        guard let url = URL(string: absoluteString) else { return nil }
        
        return URLRequest(url: url)
    }
}
