//
//  UsersCoordinator.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import UIKit

final class UsersCoordinator: Coordinator {
    var finish: (() -> Void)?

    var navigationController: UINavigationController

    private let dataService: UsersDataService
    
    init(_ navigationController: UINavigationController, usersDataService: UsersDataService) {
        self.navigationController = navigationController
        dataService = usersDataService
    }
    
    func start() {
        let s = Session(token: UUID(), validUntil: Date.distantFuture, type: .user)
        Task {
            do {
                try await dataService.updateData(in: s)
            } catch {
                print(error)
            }
        }
    }
}
