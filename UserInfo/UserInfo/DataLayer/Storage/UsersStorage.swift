//
//  UsersStorage.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

enum DataStorageError: Error {
    case creation
    case reading
    case deletion
    case unexistingRecord
}

protocol UsersStorage {
    func writeUnique(entities: [UserEntity], with token: UUID) async throws(DataStorageError) -> [UserEntity]
    func read(with token: UUID) async throws(DataStorageError) -> [UserEntity]
    func clearStorage() async throws(DataStorageError)
}
