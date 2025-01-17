//
//  SessionStorage.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import Foundation

protocol SessionStorage {
    func writeSession(_ session: Session)
    func readSession() -> Session?
    func wipeSession()
}

final class SessionStorageUserDefaults: SessionStorage {
    private let key = "session_data"
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    func writeSession(_ session: Session) {
        userDefaults.set(session, forKey: key)
    }
    
    func readSession() -> Session? {
        guard let some = userDefaults.object(forKey: key) else {
            return nil
        }
        
        return some as? Session
    }
    
    func wipeSession() {
        userDefaults.removeObject(forKey: key)
    }
}
