//
//  UsersAPIResponse.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

struct UsersAPIResponse: Codable {
    struct Info: Codable {
        let seed: String
        let results: Int
        let page: Int
        let version: String
    }
    
    let results: [UserEntity]?
    let info: Info?
    let error: String?
}

