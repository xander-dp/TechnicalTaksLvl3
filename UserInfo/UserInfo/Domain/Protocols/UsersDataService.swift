//
//  UsersDataService.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

protocol UsersDataService {
    func fetchData() async throws -> [UserEntity]
    func updateData(in session: Session) async throws
    func clearData() async throws
}
