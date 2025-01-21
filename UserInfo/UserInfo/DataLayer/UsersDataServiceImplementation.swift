//
//  UsersDataServiceImplementation.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

final class UsersDataServiceImplementation: UsersDataService {
    private let dataStorage: UsersStorage
    private let apiService: UsersAPIService
    
    init(dataStorage: UsersStorage, apiService: UsersAPIService) {
        self.dataStorage = dataStorage
        self.apiService = apiService
    }
    
    func fetchData() async throws -> [UserEntity] {
        return try await self.dataStorage.read()
    }
    
    func updateData(in session: Session) async throws {
        let receivedData = try await self.apiService.getUsersData(for: session)
        try await dataStorage.write(entities: receivedData)
    }
    
    func clearData() async throws {
        try await dataStorage.clearStorage()
    }
}
