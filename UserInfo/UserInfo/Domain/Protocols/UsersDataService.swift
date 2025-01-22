//
//  UsersDataService.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

protocol UsersDataService {
    func fetchData(for session: Session) async throws -> [UserEntity]
    func updateData(in session: Session, startingFrom currentAmount: Int) async throws -> [UserEntity]
    func clearData() async throws
}
