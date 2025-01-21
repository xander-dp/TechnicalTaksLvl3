//
//  Coordinator.swift
//  ShipsInfoReview
//
//  Created by Oleksandr Savchenko on 16.01.25.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    
    var finish: (() -> Void)? { get set }
    func start()
}
