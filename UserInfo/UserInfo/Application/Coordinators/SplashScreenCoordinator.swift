//
//  SplashScreenCoordinator.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import UIKit

final class SplashScreenCoordinator: Coordinator {
    var finish: (() -> Void)?
    
    var navigationController: UINavigationController
    
    //Discuss: state in coordinator?
    var activeSessionExist: Bool = false
    
    private let initStepsProvider: AppInitStepsProvider
    private let sessionKeeper: SessionKeeper
    
    init(_ navigationController: UINavigationController, initStepsProvider: AppInitStepsProvider, sessionKeeper: SessionKeeper) {
        self.navigationController = navigationController
        self.initStepsProvider = initStepsProvider
        self.sessionKeeper = sessionKeeper
    }
    
    func start() {
        let viewModel = SplashScreenViewModel(stepsProvider: initStepsProvider, sessionKeeper: sessionKeeper)
        
        viewModel.initializationCompleted = { [weak self] hasActiveSession in
            self?.activeSessionExist = hasActiveSession
            self?.finish?()
        }
        
        let viewController = SplashScreenViewController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
    }
}
