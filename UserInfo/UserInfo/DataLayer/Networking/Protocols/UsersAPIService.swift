//
//  UsersAPIService.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

enum RequestPhase {
    case create
    case mapping
}

enum APIRequestError: Error {
    case unableToProcessRequest(phase: RequestPhase)
    case requestFailedWithCode(code: Int)
    case networkError(wrappedError: Error)
    case serviceUnavailable(description: String)
}

protocol UsersAPIService {
    func getUsersData(for session: Session) async throws -> [UserEntity]
    func getUsersData(for session: Session, amount: Int) async throws -> [UserEntity]
}
