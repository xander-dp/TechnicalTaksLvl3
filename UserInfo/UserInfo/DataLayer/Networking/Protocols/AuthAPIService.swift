//
//  AuthAPIService.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

import Foundation

protocol AuthAPIService {
    typealias ReceivedSessionData = (token: UUID, validUntil: Date)
    
    func performAuthorizationRequest(email: String, password: String) async throws -> ReceivedSessionData
    func performGuestLoginRequest() async throws -> ReceivedSessionData
    func performSessionUpdateRequest(_ session: Session) async throws -> ReceivedSessionData
    func perfromLogoutRequest() async throws
}
