//
//  AppCoordinator.swift
//  ShipsInfoReview
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import UIKit

final class AppCoordinator: Coordinator {
    var finish: (() -> Void)?
    
    var childCoordinators = [Coordinator]()
    var navigationController = UINavigationController()
    
    private var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        window?.rootViewController = navigationController
        startSplashScreen()
    }
    
    func startSplashScreen() {
        let coordinator = SplashScreenCoordinator(navigationController)
        coordinator.finish = { [weak self, weak coordinator] in
            if let coordinator {
                self?.removeChild(coordinator)
            }
            self?.navigationController.viewControllers.removeAll()
            //TODO: analyze session and decide which module to start
        }
        coordinator.start()
        self.addChild(coordinator)
    }
    
    func startAuthModule() {
        let coordinator = AuthCoordinator(navigationController)
        coordinator.finish = { [weak self, weak coordinator] in
            if let coordinator {
                self?.removeChild(coordinator)
            }
            self?.navigationController.viewControllers.removeAll()
            self?.startUsersModule()
        }
        
        coordinator.start()
        self.addChild(coordinator)
    }
    
    func startUsersModule() {
        let coordinator = UsersCoordinator(navigationController)
        coordinator.finish = { [weak self, weak coordinator] in
            if let coordinator = coordinator {
                self?.removeChild(coordinator)
            }
            self?.navigationController.viewControllers.removeAll()
            self?.startAuthModule()
        }
        
        coordinator.start()
        self.addChild(coordinator)
    }
}
