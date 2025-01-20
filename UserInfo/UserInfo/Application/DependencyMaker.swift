//
//  DependencyMaker.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

struct DependencyMaker {
    func makeSessionKeeper() -> SessionKeeper {
        let storage = makeSessionStorage()
        let authService = makeAuthService()
        
        return LocalSessionKeeper(storage: storage, authService: authService)
    }
    
    func makeAppInitStepsProvider() -> AppInitStepsProvider {
        AppInitStepsHardcodedProvider()
    }
    
    func makeCredentialsValidator() -> CredentialsValidator {
        CredentialsValidatorImplementation()
    }
    
    private func makeSessionStorage() -> SessionStorage {
        SessionStorageUserDefaults()
    }
    
    private func makeAuthService() -> UserAuthorizationService {
        let apiService = makeAuthAPIService()
        
        return UserAuthorizationServiceImplementation(apiService: apiService)
    }
    
    private func makeAuthAPIService() -> AuthAPIService {
        AuthAPIServiceStub()
    }
}
