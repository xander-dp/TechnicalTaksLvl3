//
//  DateFormatterSingleton.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

final class ISO8601DateFormatterSingleton {
    
    static var instance: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFullDate
        return formatter
    }()
    
    private init() {}
}

extension ISO8601DateFormatterSingleton: NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
