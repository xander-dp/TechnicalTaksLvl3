//
//  AuthCoordinator.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import UIKit

final class AuthCoordinator: Coordinator {
    var finish: (() -> Void)?

    var navigationController: UINavigationController
    
    private let sessionKeeper: SessionKeeper
    private let validator: CredentialsValidator
    
    init(_ navigationController: UINavigationController, sessionKeeper: SessionKeeper, validator: CredentialsValidator) {
        self.navigationController = navigationController
        self.sessionKeeper = sessionKeeper
        self.validator = validator
    }
    
    func start() {
        let viewModel = AuthViewModel(sessionKeeper: sessionKeeper, validator: validator)
        
        viewModel.userAuthorized = { [weak self] in
            self?.finish?()
        }
        
        let viewController = AuthViewController()
        viewController.viewModel = viewModel
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
