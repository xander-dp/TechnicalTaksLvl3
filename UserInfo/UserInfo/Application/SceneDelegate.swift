//
//  SceneDelegate.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let dependencyMaker = DependencyMaker()
        
        appCoordinator = AppCoordinator(window: window, dependencyMaker: dependencyMaker)
        appCoordinator.start()
        
        window?.makeKeyAndVisible()
    }
}

