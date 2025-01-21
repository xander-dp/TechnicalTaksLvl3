//
//  UsersAPIServiceImplementation.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

final class UsersAPIServiceImplementation: UsersAPIService {
    private let defaultAmount = 20
    private var lastRequestedPage: Int?
    private var nextPage: Int {
        if let lastRequestedPage {
            lastRequestedPage + 1
        } else {
            1
        }
    }
    
    private let jsonDecoder: JSONDecoder
    private let requestBuilder: APIRequestBuilder
    private let dataRequester: DataHTTPRequester
    
    init(apiRequestBuilder: APIRequestBuilder, dataRequester: DataHTTPRequester, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.requestBuilder = apiRequestBuilder
        self.dataRequester = dataRequester
        self.jsonDecoder = jsonDecoder
    }
    
    func getUsersData(for session: Session) async throws -> [UserEntity] {
        try await getUsersData(for: session, amount: defaultAmount)
    }
    
    func getUsersData(for session: Session, amount: Int) async throws -> [UserEntity] {
        let currentPage = nextPage
        let token = session.token.uuidString
        let endpoint = UsersAPIEndpoint.getUsers(page: currentPage, amount: amount, seed: token)
        
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
        
        guard let results = response.results,
              let info = response.info else {
            throw APIRequestError.unableToProcessRequest(phase: .mapping)
        }
        
        let receivedEntities = results
        lastRequestedPage = info.page
        
        return receivedEntities
    }
    
    func pullToRefresh(session: Session) async throws {
        self.lastRequestedPage = 0
        try await getUsersData(for: session)
    }
}
