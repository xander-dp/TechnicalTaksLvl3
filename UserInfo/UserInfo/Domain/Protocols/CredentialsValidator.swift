//
//  CredentialsValidator.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

import Foundation

protocol CredentialsValidator {
    func validateEmail(_ value: String) -> Bool
    func validatePassword(_ value: String) -> Bool
}
