//
//  AuthAPIServiceStub.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

import Foundation

fileprivate enum Constants {
    private static let ttlInMinutes = 10.0
    static let validityOffset: Double = ttlInMinutes * 60
}

final class AuthAPIServiceStub: AuthAPIService {
    private let hardcodedCredentials = [
        "test@email.com" : "1",
        "my_user@i.ua" : "pa$$w0rd",
        "nickname@gmail.com" : "s0me_pass!",
        "user1@test.com" : "123",
        "admin@user.net" : "admin"
    ]
    
    func performAuthorizationRequest(email: String, password: String) async throws -> ReceivedSessionData {
        let requestDuration = randomInterval(from: (2.0...3.0))
        
        try await Task.sleep(nanoseconds: requestDuration)
        
        if isKnownUser(credentials: (key: email, value: password)) {
            return (token: UUID(), validUntil: Date().advanced(by: Constants.validityOffset))
        } else {
            throw AuthError.invalidCredentials
        }
    }
    
    func performGuestLoginRequest() async throws -> ReceivedSessionData {
        let requestDuration = randomInterval(from: (0.1...1.0))
        
        try await Task.sleep(nanoseconds: requestDuration)
        
        return (token: UUID(), validUntil: Date().advanced(by: Constants.validityOffset))
    }
    
    func performSessionUpdateRequest(_ session: Session) async throws -> ReceivedSessionData {
        let requestDuration = randomInterval(from: (0.1...0.3))
        
        try await Task.sleep(nanoseconds: requestDuration)
        
        return (token: session.token, validUntil: Date().advanced(by: Constants.validityOffset))
    }
    
    func perfromLogoutRequest() async throws {
        let requestDuration = randomInterval(from: (0.1...0.3))
        
        try await Task.sleep(nanoseconds: requestDuration)
    }
    
    private func isKnownUser(credentials: (key: String, value:String)) -> Bool {
        hardcodedCredentials.contains { storedCredentials in
            storedCredentials == credentials
        }
    }
    
    private func randomInterval(from range: ClosedRange<Double>) -> UInt64 {
        let randomInterval = Double.random(in: range)
        return UInt64(randomInterval * Double(NSEC_PER_SEC))
    }
}
