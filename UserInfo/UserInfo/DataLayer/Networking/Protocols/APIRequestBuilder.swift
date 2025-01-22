//
//  APIRequestBuilder.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

protocol APIRequestBuilder {
    var scheme: String { get }
    var host: String { get }
    
    func buildRequest(for endpoint: APIEndpoint) -> URLRequest?
    func buildRequest(from absoluteString: String) -> URLRequest?
}
