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
    
    //dependencies for childs
    private let initStepsProvider: AppInitStepsProvider
    private let sessionKeeper: SessionKeeper
    private let validator: CredentialsValidator
    private let usersDataService: UsersDataService
    private let usersImageLoader: ImageLoader
    
    init(window: UIWindow?, dependencyMaker: DependencyMaker) {
        self.window = window
        
        initStepsProvider = dependencyMaker.makeAppInitStepsProvider()
        sessionKeeper = dependencyMaker.makeSessionKeeper()
        validator = dependencyMaker.makeCredentialsValidator()
        usersDataService = dependencyMaker.makeUsersDataService()
        usersImageLoader = dependencyMaker.makeImageLoader()
    }
    
    func start() {
        window?.rootViewController = navigationController
        startSplashScreen()
    }
    
    private func startSplashScreen() {
        let coordinator = SplashScreenCoordinator(navigationController, initStepsProvider: initStepsProvider, sessionKeeper: sessionKeeper)
        coordinator.finish = { [weak coordinator] in
            var activeSessionExist = false
            
            if let coordinator {
                //TODO: find out if there is a way to avoid coordinator property usage
                activeSessionExist = coordinator.activeSessionExist
                self.removeChild(coordinator)
            }
            self.navigationController.viewControllers.removeAll()
            
            if activeSessionExist {
                self.startUsersModule()
            } else {
                self.startAuthModule()
            }
        }
        coordinator.start()
        self.addChild(coordinator)
    }
    
    private func startAuthModule() {
        let coordinator = AuthCoordinator(navigationController, sessionKeeper: sessionKeeper, validator: validator)
        coordinator.finish = { [weak coordinator] in
            if let coordinator {
                self.removeChild(coordinator)
            }
            self.navigationController.viewControllers.removeAll()
            self.startUsersModule()
        }
        
        coordinator.start()
        self.addChild(coordinator)
    }
    
    private func startUsersModule() {
        let coordinator = UsersCoordinator(
            navigationController,
            usersDataService: usersDataService,
            imageLoader: usersImageLoader,
            sessionKeeper: sessionKeeper
        )
        
        coordinator.finish = { [weak coordinator] in
            if let coordinator = coordinator {
                self.removeChild(coordinator)
            }
            self.navigationController.viewControllers.removeAll()
            self.startAuthModule()
        }
        
        coordinator.start()
        self.addChild(coordinator)
    }
    
    private func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    private func removeChild(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}
