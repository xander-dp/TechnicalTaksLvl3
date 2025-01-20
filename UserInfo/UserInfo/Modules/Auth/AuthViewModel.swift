//
//  AuthViewModel.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

import Combine
import Foundation

final class AuthViewModel {
    var userAuthorized: (() -> Void)?
    
    struct Input {
        let enteredEmail: AnyPublisher<String, Never>
        let enteredPassword: AnyPublisher<String, Never>
        let loginButtonTapped: AnyPublisher<SessionType, Never>
    }
    
    struct Output {
        let isLoginEnabled: AnyPublisher<Bool, Never>
        let emailValidationError: AnyPublisher<String, Never>
        let passwordValidationError: AnyPublisher<String, Never>
        let authError: AnyPublisher<String, Never>
        let requestInProgress: AnyPublisher<Bool, Never>
    }

    private let loginErrorSubject = PassthroughSubject<String, Never>()
    private let progressSubject = PassthroughSubject<Bool, Never>()
    
    private var email = ""
    private var password = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let sessionKeeper: SessionKeeper
    private let validator: CredentialsValidator
    
    init(sessionKeeper: SessionKeeper, validator: CredentialsValidator) {
        self.sessionKeeper = sessionKeeper
        self.validator = validator
    }
    
    func transform(input: Input) -> Output {
        input.loginButtonTapped
            .sink { [weak self] type in
                self?.authorizeUser(with: type)
            }
            .store(in: &cancellables)
        
        let emailIsValid = input.enteredEmail
            .map { [weak self] in
                self?.email = $0
                return self?.validator.validateEmail($0) ?? false
            }
            .eraseToAnyPublisher()
        
        let passwordIsValid = input.enteredPassword
            .map { [weak self] in
                self?.password = $0
                
                return self?.validator.validatePassword($0) ?? false
            }
            .eraseToAnyPublisher()
        
        let loginEnabled = Publishers.CombineLatest(emailIsValid, passwordIsValid)
            .map { $0 && $1 }
            .eraseToAnyPublisher()
        
        let enteredEmailInvalid = emailIsValid
            .map { [weak self] isValid in
                var error = ""
                guard let self else { return error}
                if !isValid {
                    if (self.email.isEmpty) {
                        error = "Email shouldn't be empty"
                    } else {
                        error = "\(self.email) is Invalid Email"
                    }
                }
                return error
            }
            .eraseToAnyPublisher()
        
        let enteredPasswordInvalid = passwordIsValid
            .map {
                return !$0 ? "Password shouldn't be empty" : ""
            }
            .eraseToAnyPublisher()
        
        let authError = self.loginErrorSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let progress = self.progressSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return Output(
            isLoginEnabled: loginEnabled,
            emailValidationError: enteredEmailInvalid,
            passwordValidationError: enteredPasswordInvalid,
            authError: authError,
            requestInProgress: progress
        )
    }
    
    private func authorizeUser(with type: SessionType) {
        progressSubject.send(true)
        
        Task {
            defer {
                progressSubject.send(false)
            }
            
            do {
                try await sessionKeeper.createSession(for: type, with: (email: self.email, password: self.password))
                
                await MainActor.run {
                    userAuthorized?()
                }
            } catch {
                //As far we are using Stub of AuthorizationAPIService here handeled only invalid credentials
                if let authError = error as? AuthError,
                   authError == .invalidCredentials {
                    self.loginErrorSubject.send("Invalid credentials =(")
                } else {
                    self.loginErrorSubject.send("Error during SignIn request =()")
                }
            }
        }
    }
}
