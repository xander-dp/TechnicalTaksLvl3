//
//  AuthViewController.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

import UIKit
import Combine

fileprivate enum Constants {
    static let headerTitle = "WELCOME TO THE USERS LIST PROJECT"
    static let emailPlaceholder = "Email"
    static let passwordPlaceholder = "Password"
    static let loginButtonTitle = "Login"
    static let loginGuestButtonTitle = "Login as a guest"
    static let errorAlertTitle = "Error"
    
    static let contentInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
    static let welcomeLabelInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    static let fieldsSpacing: CGFloat = 60.0
    static let errorLabelSpacing: CGFloat = 8.0
}

final class AuthViewController: UIViewController {
    var viewModel: AuthViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.headerTitle
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.fieldsSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let emailTextField: TextFieldWithError = {
        let textField = TextFieldWithError()
        textField.placeholder = Constants.emailPlaceholder
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let passwordTextField: TextFieldWithError = {
        let textField = TextFieldWithError()
        textField.placeholder = Constants.passwordPlaceholder
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.loginButtonTitle, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    private let guestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.loginGuestButtonTitle, for: .normal)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .red
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    let viewReadySubject = PassthroughSubject<Void, Never>()
    let emailInputChanged = PassthroughSubject<String, Never>()
    let passwordInputChanged = PassthroughSubject<String, Never>()
    let loginButtonTappedSubject = PassthroughSubject<SessionType, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupLayout()
        setupActions()
        bindViewModel()
        
        viewReadySubject.send()
    }
    
    private func setupLayout() {
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(guestButton)
        
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.welcomeLabelInsets.top),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.welcomeLabelInsets.left),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.welcomeLabelInsets.right),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.contentInsets.left),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.contentInsets.right),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        guestButton.addTarget(self, action: #selector(guestButtonTapped), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(emailFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordFieldDidChange), for: .editingChanged)
    }
    
    private func bindViewModel() {
        let input = AuthViewModel.Input(
            enteredEmail: emailInputChanged.eraseToAnyPublisher(),
            enteredPassword: passwordInputChanged.eraseToAnyPublisher(),
            loginButtonTapped: loginButtonTappedSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.isLoginEnabled
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables)
        
        output.emailValidationError
            .sink { [weak self] errorDescription in
                self?.emailTextField.showError(errorDescription)
            }
            .store(in: &cancellables)
        
        output.passwordValidationError
            .sink { [weak self] errorDescription in
                self?.passwordTextField.showError(errorDescription)
            }
            .store(in: &cancellables)
        
        output.authError
            .sink { [weak self] errorDescription in
                self?.presentAlert(message: errorDescription)
            }
            .store(in: &cancellables)
    }
    
    @objc func emailFieldDidChange() {
        emailTextField.hideError()
        
        guard let text = emailTextField.text else { return }
        
        emailInputChanged.send(text)
    }
    
    @objc func passwordFieldDidChange() {
        passwordTextField.hideError()
        
        guard let text = passwordTextField.text else { return }
        
        passwordInputChanged.send(text)
    }
    
    @objc func loginButtonTapped() {
        loginButtonTappedSubject.send(.user)
    }
    
    @objc func guestButtonTapped() {
        loginButtonTappedSubject.send(.guest)
    }
    
    func presentAlert(message: String) {
        let alertController = UIAlertController(
            title: Constants.errorAlertTitle,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
