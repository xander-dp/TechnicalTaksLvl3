//
//  DependencyMaker.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

final class DependencyMaker {
    func makeSessionKeeper() -> SessionKeeper {
        let storage = makeSessionStorage()
        return SessionKeeper(storage: storage)
    }
    
    func makeAppInitStepsProvider() -> AppInitStepsProvider {
        AppInitStepsHardcodedProvider()
    }
    
    private func makeSessionStorage() -> SessionStorage {
        SessionStorageUserDefaults()
    }
}
