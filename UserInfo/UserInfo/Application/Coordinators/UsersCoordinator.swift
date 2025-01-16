//
//  UsersCoordinator.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import UIKit

final class UsersCoordinator: Coordinator {
    var finish: (() -> Void)?

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    func start() {
        
    }
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
