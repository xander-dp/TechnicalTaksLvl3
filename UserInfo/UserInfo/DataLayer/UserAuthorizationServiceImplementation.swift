//
//  UserAuthorizationServiceImplementation.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

final class UserAuthorizationServiceImplementation: UserAuthorizationService {
    private let apiService: AuthAPIService
    
    init(apiService: AuthAPIService) {
        self.apiService = apiService
    }
    
    func authorizeWithCredentials(email: String, password: String) async throws -> Session {
        let sessionData = try await apiService.performAuthorizationRequest(email: email, password: password)
        
        return Session(
            token: sessionData.token,
            validUntil: sessionData.validUntil,
            type: .user
        )
    }
    
    func guestLogin() async throws -> Session {
        let sessionData = try await apiService.performGuestLoginRequest()
        
        return Session(
            token: sessionData.token,
            validUntil: sessionData.validUntil,
            type: .guest
        )
    }
    
    func updateSession(_ session: Session) async throws -> Session {
        let sessionData = try await apiService.performSessionUpdateRequest(session)
        
        return Session(
            token: sessionData.token,
            validUntil: sessionData.validUntil,
            type: .guest
        )
    }
    
    func logout() async throws {
        try await apiService.perfromLogoutRequest()
    }
}
