//
//  SessionStorage.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import Foundation
import Dispatch
import OSLog

protocol SessionStorage {
    func writeSession(_ session: Session)
    func readSession() -> Session?
    func wipeSessionData()
}

final class SessionStorageUserDefaults: SessionStorage {
    private let key = "session_data"
    private let userDefaults: UserDefaults
    
    private let accessQueue: DispatchQueue
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        accessQueue = DispatchQueue(label: "com.technicaltasklvl3.SessionStorage.accessQueue",
                                    qos: .userInteractive,
                                    attributes: [],
                                    autoreleaseFrequency: .inherit,
                                    target: nil)
        self.userDefaults = userDefaults
    }
    
    func writeSession(_ session: Session) {
        do {
            let encoded = try PropertyListEncoder().encode(session)
            accessQueue.sync {
                self.userDefaults.set(encoded, forKey: self.key)
            }
        } catch {
            Logger.session.error("Error during session saving: \(error)")
        }
    }
    
    func readSession() -> Session? {
        var data: Data?
        accessQueue.sync {
            data = userDefaults.object(forKey: key) as? Data
        }
        
        guard let someData = data else {
            return nil
        }
        
        do {
            let decoded = try PropertyListDecoder().decode(Session.self, from: someData)
            return decoded
        } catch {
            Logger.session.error("Error during session saving: \(error)")
            return nil
        }
    }
    
    func wipeSessionData() {
        accessQueue.sync {
            userDefaults.removeObject(forKey: key)
        }
    }
}
