//
//  UsersDataHTTPRequester.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

final class UsersDataHTTPRequester: DataHTTPRequester {
    let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func executeRequest(urlRequest: URLRequest) async throws(APIRequestError) -> Data {
        let requestResult: (data: Data, response: URLResponse)
        
        do {
            requestResult = try await urlSession.data(for: urlRequest)
        } catch {
            throw .networkError(wrappedError: error)
        }
        
        let httpResponse = try getHTTPResponse(from: requestResult.response)
        
        try validateReceived(statusCode: httpResponse.statusCode)
        
        return requestResult.data
    }
    
    private func getHTTPResponse(from urlResponse: URLResponse) throws(APIRequestError) -> HTTPURLResponse {
        guard let httpResponse = urlResponse as? HTTPURLResponse
        else {
            throw .unableToProcessRequest(phase: .mapping)
        }
        
        return httpResponse
    }
    
    private func validateReceived(statusCode: Int) throws(APIRequestError) {
        if !(200...299).contains(statusCode) {
            throw .requestFailedWithCode(code: statusCode)
        }
    }
}
