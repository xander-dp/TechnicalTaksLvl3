//
//  APIEndpoint.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

enum HttpMethod: String {
    case GET
}

protocol APIEndpoint {
    var method: String { get }
    var path: String { get }
    var querryParams: [URLQueryItem] { get }
}
