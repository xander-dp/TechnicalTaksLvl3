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
    
    private let window: UIWindow?
    private let sessionKeeper: SessionKeeper
    
    init(window: UIWindow?) {
        self.window = window
        self.sessionKeeper = SessionKeeper(storage: SessionStorageUserDefaults())
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
            
            if let session = self?.sessionKeeper.getSession() {
                self?.startUsersModule()
            } else {
                self?.startAuthModule()
            }
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
