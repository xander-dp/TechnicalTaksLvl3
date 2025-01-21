//
//  UserEntity.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

struct UserEntity: Codable {
    let name: Name
    let birthData: BirthData
    let picture: UserPicture
    
    enum CodingKeys: String, CodingKey {
        case name
        case birthData = "dob"
        case picture
    }
}

struct Name: Codable {
    let title: String
    let first: String
    let last: String
    
    var full: String {
        "\(title) \(first) \(last)"
    }
}

struct BirthData: Codable {
    let date: Date
    let age: Int
}

struct UserPicture: Codable {
    let medium: String
    let large: String
}
