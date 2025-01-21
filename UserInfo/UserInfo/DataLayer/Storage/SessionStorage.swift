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
    func wipeSessionData()
}

final class SessionStorageUserDefaults: SessionStorage {
    private let key = "session_data"
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    //Discuss: error handling, thread safety?
    //TODO: log erros, thread safety with serial queue
    func writeSession(_ session: Session) {
        let encoded = try? PropertyListEncoder().encode(session)
        userDefaults.set(encoded, forKey: key)
    }
    
    func readSession() -> Session? {
        guard let someData = userDefaults.object(forKey: key) as? Data else {
            return nil
        }
        
        let decoded = try? PropertyListDecoder().decode(Session.self, from: someData)
        return decoded
    }
    
    func wipeSessionData() {
        userDefaults.removeObject(forKey: key)
    }
}
