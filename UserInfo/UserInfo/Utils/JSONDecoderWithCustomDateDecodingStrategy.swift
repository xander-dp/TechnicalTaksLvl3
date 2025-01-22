//
//  JSONDecoderWithCustomDateFormat.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

final class JSONDecoderWithCustomDateDecodingStrategy: JSONDecoder, @unchecked Sendable {
    init(formatter: ISO8601DateFormatter) {
        super.init()
        
        self.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateEncoded = try container.decode(String.self)
            
            guard let date = formatter.date(from: dateEncoded) else {
                let description = "Unable to parse Date from given String(\(dateEncoded))"
                let ctxt = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: description)
                throw DecodingError.dataCorrupted(ctxt)
            }
            
            return date
        })
    }
}
