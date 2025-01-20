//
//  AuthCoordinator.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import UIKit

final class AuthCoordinator: Coordinator {
    var finish: (() -> Void)?

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let sessionKeeper: SessionKeeper
    
    init(_ navigationController: UINavigationController, sessionKeeper: SessionKeeper) {
        self.navigationController = navigationController
        self.sessionKeeper = sessionKeeper
    }
    
    func start() {
        let viewModel = AuthViewModel(sessionKeeper: sessionKeeper)
        
        viewModel.userAuthorized = { [weak self] in
            self?.finish?()
        }
        
        let viewController = AuthViewController()
        viewController.viewModel = viewModel
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
