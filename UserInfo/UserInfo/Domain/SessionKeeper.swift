//
//  SessionKeeper.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import Foundation

protocol SessionKeeper {
    func createSession(of type: AuthType) -> Session
    func getSession() -> Session?
    func updateSession(_ session: Session) -> Session
    func invalidateCurrentSession()
}
