//
//  SessionKeeper.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import Foundation

protocol SessionKeeper {
    typealias Credentials = (email: String, password: String)
    
    func createSession(for type: SessionType, with credentials: Credentials) async throws
    func getSession() -> Session?
    func updateSession(_ session: Session) async throws -> Session
    func invalidateCurrentSession(sessionInvalidatedCallback: (() -> Void)?) async throws
}
