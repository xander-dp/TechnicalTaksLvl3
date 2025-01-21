//
//  DependencyMaker.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

import Foundation

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
    
    func makeUsersDataService() -> UsersDataService {
        let apiService = makeUsersApiService()
        
        return UsersDataServiceImplementation(apiService: apiService)
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
    
    private func makeUsersApiService() -> UsersAPIService {
        let requestBuilder = makeUsersAPIRequestBuilder()
        let dataRequester = makeHTTPRequester()
        let decoder = makeCustomJSONDecoder()
        
        return UsersAPIServiceImplementation(
            apiRequestBuilder: requestBuilder,
            dataRequester: dataRequester,
            jsonDecoder: decoder
        )
    }
    
    private func makeUsersAPIRequestBuilder() -> APIRequestBuilder {
        UsersAPIRequestBuilder()
    }
    
    private func makeHTTPRequester() -> DataHTTPRequester {
        UsersDataHTTPRequester()
    }
    
    private func makeCustomJSONDecoder() -> JSONDecoder {
        let sharedFormatter = ISO8601DateFormatterSingleton.instance
        return JSONDecoderWithCustomDateDecodingStrategy(formatter: sharedFormatter)
    }
}
