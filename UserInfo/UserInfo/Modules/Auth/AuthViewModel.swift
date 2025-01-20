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
    }

    private let loginErrorSubject = PassthroughSubject<String, Never>()
    
    private var email = ""
    private var password = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let sessionKeeper: SessionKeeper
    
    init(sessionKeeper: SessionKeeper) {
        self.sessionKeeper = sessionKeeper
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
                return !($0.isEmpty)
                //self.validator.isValidEmail($0)
            }
            .eraseToAnyPublisher()
        
        let passwordIsValid = input.enteredPassword
            .map { [weak self] in
                self?.password = $0
                return !($0.isEmpty)
                //self.validator.isValidPassword($0)
            }
            .eraseToAnyPublisher()
        
        let loginEnabled = Publishers.CombineLatest(emailIsValid, passwordIsValid)
            .map { $0 && $1 }
            .eraseToAnyPublisher()
        
        let enteredEmailInvalid = emailIsValid
            .map {
                return !$0 ? "\(self.email) is Invalid" : ""
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
        
        return Output(
            isLoginEnabled: loginEnabled,
            emailValidationError: enteredEmailInvalid,
            passwordValidationError: enteredPasswordInvalid,
            authError: authError
        )
    }
    
    private func authorizeUser(with type: SessionType) {
        Task {
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
