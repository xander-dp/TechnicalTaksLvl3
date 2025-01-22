//
//  UsersAPIServiceImplementation.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

final class UsersAPIServiceImplementation: UsersAPIService {
    private let jsonDecoder: JSONDecoder
    private let requestBuilder: APIRequestBuilder
    private let dataRequester: DataHTTPRequester
    
    init(apiRequestBuilder: APIRequestBuilder, dataRequester: DataHTTPRequester, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.requestBuilder = apiRequestBuilder
        self.dataRequester = dataRequester
        self.jsonDecoder = jsonDecoder
    }
    
    func getUsersData(for session: Session, from page: Int, amount: Int) async throws -> [UserEntity] {
        let token = session.token.uuidString
        let endpoint = UsersAPIEndpoint.getUsers(page: page, amount: amount, seed: token)
        
        guard let urlRequest = requestBuilder.buildRequest(for: endpoint) else {
            throw APIRequestError.unableToProcessRequest(phase: .create)
        }
        
        let responseData = try await self.dataRequester.executeRequest(urlRequest: urlRequest)
        
        let response: UsersAPIResponse
        do {
            response = try self.jsonDecoder.decode(UsersAPIResponse.self, from: responseData)
        } catch {
            throw APIRequestError.unableToProcessRequest(phase: .mapping)
        }
        
        if let error = response.error {
            throw APIRequestError.serviceUnavailable(description: error)
        }
        
        guard let results = response.results else {
            throw APIRequestError.unableToProcessRequest(phase: .mapping)
        }
        
        let receivedEntities = results
        
        return receivedEntities
    }
}
