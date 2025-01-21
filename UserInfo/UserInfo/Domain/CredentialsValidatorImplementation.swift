//
//  CredentialsValidatorImplementation.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

struct CredentialsValidatorImplementation: CredentialsValidator {
    func validateEmail(_ value: String) -> Bool {
        let regex = #"^(?:[^@\\]|\\@)+@[^@]+\.[^@]+$"#
        return value.range(of: regex, options: .regularExpression) != nil
    }
    
    func validatePassword(_ value: String) -> Bool {
        !value.isEmpty
    }
}
