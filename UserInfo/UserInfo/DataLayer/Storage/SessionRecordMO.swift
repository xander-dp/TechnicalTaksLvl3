//
//  SessionRecordMO.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 22.01.25.
//

import CoreData

final class SessionRecordMO: NSManagedObject, Identifiable {
    @NSManaged var token: UUID
    
    static let entityName = "SessionRecord"
    
    @nonobjc static func fetchRequest() -> NSFetchRequest<SessionRecordMO> {
        return NSFetchRequest<SessionRecordMO>(entityName: Self.entityName)
    }
}
