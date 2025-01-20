//
//  TextFieldWithError.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 20.01.25.
//

import UIKit

fileprivate struct Constants {
    static let errorVerticalOffset: CGFloat = 4.0
    static let errorHorizontalOffset: CGFloat = 10.0
}

final class TextFieldWithError: UITextField {
    private let errorLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .systemRed
        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: Constants.errorVerticalOffset),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.errorHorizontalOffset),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func showError(_ errorText: String) {
        errorLabel.text = errorText
        errorLabel.isHidden = false
    }
    
    func hideError() {
        errorLabel.text = nil
        errorLabel.isHidden = true
    }
}
