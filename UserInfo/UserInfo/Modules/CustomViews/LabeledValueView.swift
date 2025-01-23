//
//  LabeledValueView.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 22.01.25.
//

import UIKit

final class LabeledValueView: UIView {
    private let descriptionLabel = UILabel()
    private let valueLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    func setLabel(_ text: String) {
        descriptionLabel.text = text
    }
    
    func setValue(_ text: String) {
        valueLabel.text = text
    }
    
    func setupLayout() {
        let topInset: CGFloat = 10.0
        let leadingInset: CGFloat = 25.0
        let trailingInset: CGFloat = -15.0
        let bottomInset: CGFloat = -10.0
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        addSubview(descriptionLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: topInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomInset),
            
            valueLabel.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor),
            valueLabel.heightAnchor.constraint(equalTo: descriptionLabel.heightAnchor, multiplier: 1.0),
            valueLabel.leadingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingInset)
        ])
    }
}
