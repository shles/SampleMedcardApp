//
// Created by Артмеий Шлесберг on 16/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit

class GradientButton: UIButton {

    private let gradientLayer = CAGradientLayer()

    private(set)var colors: [CGColor] = [] {
        didSet {
            gradientLayer.backgroundColor = colors.first
            gradientLayer.colors = colors
        }
    }

    init(colors: [UIColor] = []) {
        super.init(frame: .zero)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.backgroundColor = colors.first?.cgColor
        gradientLayer.colors = colors.map { $0.cgColor }
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated")
    }
}
