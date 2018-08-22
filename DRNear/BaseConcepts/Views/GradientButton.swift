//
// Created by Артмеий Шлесберг on 16/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit

class GradientButton: UIButton {

    private let gradientLayer = CAGradientLayer()

    private(set)var colors: [CGColor] {
        didSet {
            gradientLayer.colors = colors
        }
    }

    init(colors: [UIColor] = []) {
        self.colors = colors.map { $0.cgColor }
        super.init(frame: .zero)
        self.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        self.colors = colors.map { $0.cgColor }
        
        //TODO: fix gradient
        
        self.backgroundColor = colors.first ?? .peach
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var frame  = self.bounds
        frame.origin = .zero
//        gradientLayer.position = .zero
        gradientLayer.frame = self.layer.bounds
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated")
    }
}
