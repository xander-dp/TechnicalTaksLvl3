//
//  UserDetailsViewController.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import UIKit
import Combine

enum UserDetailType {
    case email
    case name
    case birthDate
    case age
    
    var labelText: String {
        switch self {
        case .email: "Email :"
        case .name: "Name :"
        case .birthDate: "Date of birth :"
        case .age: "Age :"
        }
    }
}

fileprivate enum Constants {
    static let dismissImage = UIImage(systemName: "xmark")
    static let imageSize = CGSize(width: 240, height: 240)
    static let imageRounding = imageSize.width / 2
    static let verticalSpacing = 30.0
    static let horizontalPadding = 15.0
}

final class UserDetailsViewController: UIViewController {
    var viewModel: UserDetailsViewModel!
    private var cancellable = Set<AnyCancellable>()
    
    private let contentView = UIView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let userPictureView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Constants.imageRounding
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let nameView: LabeledValueView = {
        let view = LabeledValueView()
        view.setLabel(UserDetailType.name.labelText)
        return view
    }()
    
    private let emailView: LabeledValueView = {
        let view = LabeledValueView()
        view.setLabel(UserDetailType.email.labelText)
        return view
    }()
    
    private let birthDateView: LabeledValueView = {
        let view = LabeledValueView()
        view.setLabel(UserDetailType.birthDate.labelText)
        return view
    }()
    
    private let ageView: LabeledValueView = {
        let view = LabeledValueView()
        view.setLabel(UserDetailType.age.labelText)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameView, emailView, birthDateView, ageView])
        stackView.axis = .vertical
        stackView.spacing = 8.0
        return stackView
    }()
    
    private let viewReadySubject = PassthroughSubject<Void, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bindViewModel()
        
        viewReadySubject.send()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        userPictureView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userPictureView)
        NSLayoutConstraint.activate([
            userPictureView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            userPictureView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalSpacing),
            userPictureView.widthAnchor.constraint(equalToConstant: Constants.imageSize.width),
            userPictureView.heightAnchor.constraint(equalToConstant: Constants.imageSize.height)
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: userPictureView.bottomAnchor, constant: Constants.verticalSpacing),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalSpacing)
        ])
    }
    
    private func bindViewModel() {
        let viewReady = viewReadySubject.eraseToAnyPublisher()
        let input = UserDetailsViewModel.Input(viewReady: viewReady)
        
        let output = viewModel.transform(input)
        
        output.presentData
            .sink { entity in
                self.userPictureView.image = entity.image
                self.nameView.setValue(entity.fullName)
                self.emailView.setValue(entity.email)
                self.birthDateView.setValue(entity.birthDate)
                self.ageView.setValue(entity.age)
            }
            .store(in: &cancellable)
        
        output.imageLoaded
            .sink { loadedImage in
                self.userPictureView.image = loadedImage
            }
            .store(in: &cancellable)
    }
    
    @objc private func dismissAction() {
        self.dismiss(animated: true)
    }
}
