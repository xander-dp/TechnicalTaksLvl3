//
//  LocalSessionKeeper.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

import Foundation

final class LocalSessionKeeper: SessionKeeper {
    private var currentSession: Session? {
        didSet {
            if let currentSession {
                storage.writeSession(currentSession)
            } else {
                storage.wipeSessionData()
            }
        }
    }
    
    private let storage: SessionStorage
    private let authService: UserAuthorizationService
    
    init(storage: SessionStorage, authService: UserAuthorizationService) {
        self.storage = storage
        self.authService = authService
    }

    func createSession(for type: SessionType, with credentials: Credentials) async throws {
        let session: Session
        
        switch type {
        case .guest:
            session = try await authService.guestLogin()
        case .user:
            session = try await authService.authorizeWithCredentials(email: credentials.email, password: credentials.password)
        }
        
        currentSession = session
    }
    
    func getSession() -> Session? {
        if let currentSession {
            return currentSession
        }
        
        guard let savedSession = storage.readSession() else {
            return nil
        }
        
        guard savedSession.isValid else {
            currentSession = nil
            return nil
        }
        
        Task {
            try? await updateSession(savedSession)
        }
        
        return savedSession
    }
    
    func updateSession(_ session: Session) async throws -> Session {
        let newSession = try await authService.updateSession(session)
        
        currentSession = newSession
        return newSession
    }
    
    func invalidateCurrentSession() async throws {
        currentSession = nil
        try await authService.logout()
    }
}
