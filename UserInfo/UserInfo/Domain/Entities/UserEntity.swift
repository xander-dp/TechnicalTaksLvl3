//
//  UserEntity.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

struct UserEntity: Codable, Hashable {
    let email: String
    let name: Name
    let birthData: BirthData
    let picture: UserPicture
    
    enum CodingKeys: String, CodingKey {
        case email
        case name
        case birthData = "dob"
        case picture
    }
    
    static func == (lhs: UserEntity, rhs: UserEntity) -> Bool {
        lhs.email == rhs.email
    }
}

struct Name: Codable, Hashable {
    let title: String
    let first: String
    let last: String
    
    var full: String {
        "\(title) \(first) \(last)"
    }
}

struct BirthData: Codable, Hashable {
    let date: Date
    let age: Int
}

struct UserPicture: Codable, Hashable {
    let medium: String
    let large: String
}
