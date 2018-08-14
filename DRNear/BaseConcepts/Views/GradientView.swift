//
// Created by Артмеий Шлесберг on 03/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit

class GradientView: UIView {

    private let gradientLayer = CAGradientLayer()

    private(set)var colors: [CGColor] {
        didSet {
            gradientLayer.colors = colors
        }
    }

    init() {
        colors = []
        super.init(frame: .zero)
        self.layer.addSublayer(gradientLayer)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var frame = self.frame

        frame.origin = .zero
        gradientLayer.frame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated!")
    }

    func setColors(_ colors: [UIColor]) {
        self.colors = colors.map { $0.cgColor }
    }

}
