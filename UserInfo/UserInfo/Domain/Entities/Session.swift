//
//  Session.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import Foundation

enum SessionType: Int {
    case guest
    case user
}

struct Session: Equatable, Copyable {
    let token: UUID
    let validUntil: Date
    let type: SessionType
    
    var isValid: Bool {
        Date().distance(to: validUntil) > 0
    }
    
    static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.token == rhs.token
    }
}

extension Session: Codable {
    enum CodingKeys: String, CodingKey {
        case token
        case validUntil
        case typeRaw
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        token = try container.decode(UUID.self, forKey: .token)
        validUntil = try container.decode(Date.self, forKey: .validUntil)
        let typeRaw = try container.decode(Int.self, forKey: .typeRaw)
        type = SessionType(rawValue: typeRaw)!
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(token, forKey: .token)
        try container.encode(validUntil, forKey: .validUntil)
        try container.encode(type.rawValue, forKey: .typeRaw)
    }
}
