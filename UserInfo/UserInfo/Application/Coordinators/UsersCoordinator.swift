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
    private let imageLoader: ImageLoader
    private let sessionKeeper: SessionKeeper
    
    init(
        _ navigationController: UINavigationController,
        usersDataService: UsersDataService,
        imageLoader: ImageLoader,
        sessionKeeper: SessionKeeper
    ) {
        self.navigationController = navigationController
        self.dataService = usersDataService
        self.imageLoader = imageLoader
        self.sessionKeeper = sessionKeeper
    }
    
    func start() {
        let viewModel = UsersListViewModel(
            dataService: dataService,
            imageLoader: imageLoader,
            sessionKeeper: sessionKeeper
        )
        
        viewModel.itemSelected = { [weak self] item in
            self?.presentDetailController(with: item)
        }
        
        viewModel.logoutPerformed = { [weak self] in
            self?.finish?()
        }
        
        let viewController = UsersListViewController()
        viewController.viewModel = viewModel
        
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    private func presentDetailController(with item: UserEntity) {
        let viewModel = UserDetailsViewModel(entity: item, imageLoader: imageLoader)
        let viewConttroller = UserDetailsViewController()
        viewConttroller.viewModel = viewModel
        navigationController.present(viewConttroller, animated: true)
    }
}
