//
//  SplashScreenViewController.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 17.01.25.
//

import UIKit
import Combine

fileprivate enum Constants {
    static let logoImage = UIImage(named: "logo")
    static let backgroundColor = UIColor.white
    static let logoInsets = UIEdgeInsets(top: 120.0, left: 20.0, bottom: 80.0, right: 20.0)
    static let contentInsets = UIEdgeInsets(top: 20.0, left: 40.0, bottom: 20.0, right: 40.0)
    static let progressBarHeight: CGFloat = 32.0
}

final class SplashScreenViewController: UIViewController {
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Constants.logoImage
        imageView.image = .logo
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let initProgressBar: HorizontalProgressBar = {
        let progressBar = HorizontalProgressBar()
        progressBar.color = .black
        progressBar.gradientColor = .systemBlue
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let initStepLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var viewModel: SplashScreenViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    private let viewReadySubject = PassthroughSubject<Void, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        viewReadySubject.send()
    }
    
    private func setupUI() {
        view.backgroundColor = Constants.backgroundColor
        
        view.addSubview(logoImageView)
        view.addSubview(initProgressBar)
        view.addSubview(initStepLabel)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.logoInsets.top),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.logoInsets.left),
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.logoInsets.right),
            
            initProgressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initProgressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            initProgressBar.topAnchor.constraint(greaterThanOrEqualTo: logoImageView.bottomAnchor, constant: Constants.logoInsets.bottom),
            initProgressBar.heightAnchor.constraint(equalToConstant: Constants.progressBarHeight),
            initProgressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.contentInsets.left),
            initProgressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.contentInsets.right),

            initStepLabel.topAnchor.constraint(equalTo: initProgressBar.bottomAnchor, constant: Constants.contentInsets.top),
            initStepLabel.widthAnchor.constraint(equalTo: initProgressBar.widthAnchor),
            initStepLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func bindViewModel() {
        let ready = viewReadySubject.eraseToAnyPublisher()
        let input = SplashScreenViewModel.Input(viewReady: ready)
        
        let output = viewModel.transform(input: input)
        
        output.currentStepName
            .sink { [weak self] name in
                self?.initStepLabel.text = name
            }
            .store(in: &cancellables)
        
        output.progress
            .sink { [weak self] progress in
                self?.initProgressBar.progress = CGFloat(progress)
            }
            .store(in: &cancellables)
        
    }
}
