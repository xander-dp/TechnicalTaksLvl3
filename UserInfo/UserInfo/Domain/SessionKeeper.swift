//
//  SessionKeeper.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import Foundation

fileprivate enum Constants {
    static let ttlInMinutes = 10
}

final class SessionKeeper {
    private var currentSession: Session? {
        didSet {
            if let currentSession {
                storage.writeSession(currentSession)
            } else {
                storage.wipeSession()
            }
        }
    }
    
    private let storage: SessionStorage
    
    init(storage: SessionStorage) {
        self.storage = storage
    }

    func createSession(of type: AuthType) -> Session {
        let validityOffset = TimeInterval(Constants.ttlInMinutes * 60)
        let session = Session(
            token: UUID(),
            validUntil: Date().advanced(by: validityOffset),
            type: type
        )
        
        currentSession = session
        return session
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
        
        return savedSession
    }
    
    func updateSession(_ session: Session) -> Session {
        let validityOffset = TimeInterval(Constants.ttlInMinutes * 60)
        
        let newSession = Session (
            token: session.token,
            validUntil: Date().advanced(by: validityOffset),
            type: session.type
        )
        
        currentSession = newSession
        return newSession
    }
    
    func invalidateSession() {
        currentSession = nil
    }
}
