//
//  Session.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import Foundation

enum AuthType {
    case guest
    case user
}

struct Session: Equatable, Copyable {
    let token: UUID
    let validUntil: Date
    let type: AuthType
    
    var isValid: Bool {
        Date().distance(to: validUntil) > 0
    }
    
    static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.token == rhs.token
    }
}
