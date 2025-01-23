//
//  UsersAPIEndpoint.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

fileprivate enum QuerryItems: String {
    case page
    case results
    case seed
}

enum UsersAPIEndpoint: APIEndpoint {
    
    case getUsers(page: Int, amount: Int, seed: String)
    
    var method: String {
        switch self {
        case .getUsers:
            HttpMethod.GET.rawValue
        }
    }
    
    var path: String {
        let endpoint: String
        
        switch self {
        case .getUsers:
            endpoint = "api"
        }
        
        return "/\(endpoint)"
    }
    
    var querryParams: [URLQueryItem] {
        switch self {
        case .getUsers(let page, let amount, let seed):
            [
                URLQueryItem(name: QuerryItems.page.rawValue, value: String(page)),
                URLQueryItem(name: QuerryItems.results.rawValue, value: String(amount)),
                URLQueryItem(name: QuerryItems.seed.rawValue, value: seed)
            ]
        }
    }
}
