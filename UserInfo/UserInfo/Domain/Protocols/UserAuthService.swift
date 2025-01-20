//
//  UserAuthService.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

enum AuthError: Error {
    case invalidCredentials
}

protocol UserAuthorizationService {
    func authorizeWithCredentials(email: String, password: String) async throws -> Session
    func guestLogin() async throws -> Session
    func updateSession(_ session: Session) async throws -> Session
    func logout() async throws
}
