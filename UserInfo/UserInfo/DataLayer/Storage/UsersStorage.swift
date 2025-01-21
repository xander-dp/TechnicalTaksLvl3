//
//  UsersStorage.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

enum DataStorageError: Error {
    case creation
    case reading
    case deletion
    case unexistingRecord
}

protocol UsersStorage {
    func write(entities: [UserEntity]) async throws(DataStorageError)
    func read() async throws(DataStorageError) -> [UserEntity]
    func clearStorage() async throws(DataStorageError)
}
