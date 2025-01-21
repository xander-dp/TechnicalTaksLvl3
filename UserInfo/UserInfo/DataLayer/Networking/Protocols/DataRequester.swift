//
//  DataRequester.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

protocol DataHTTPRequester {
    func executeRequest(urlRequest: URLRequest) async throws(APIRequestError) -> Data
}
