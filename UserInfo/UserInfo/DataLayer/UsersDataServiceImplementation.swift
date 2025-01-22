//
//  UsersDataServiceImplementation.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

final class UsersDataServiceImplementation: UsersDataService {
    private let defaultAmount = 20
    
    private let dataStorage: UsersStorage
    private let apiService: UsersAPIService
    
    init(dataStorage: UsersStorage, apiService: UsersAPIService) {
        self.dataStorage = dataStorage
        self.apiService = apiService
    }
    
    func fetchData(for session: Session) async throws -> [UserEntity] {
        return try await self.dataStorage.read(with: session.token)
    }
    
    func updateData(in session: Session, startingFrom currentAmount: Int) async throws -> [UserEntity] {
        let page = currentAmount / defaultAmount + 1
        let receivedData = try await self.apiService.getUsersData(for: session, from: page, amount: defaultAmount)
        let uniqueEntities = try await dataStorage.writeUnique(entities: receivedData, with: session.token)
        
        return uniqueEntities
    }
    
    func clearData() async throws {
        try await dataStorage.clearStorage()
    }
}
