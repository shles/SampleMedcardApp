//
// Created by Артмеий Шлесберг on 16/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxSwift
import UIKit

class GradientButton: UIButton {

    private let gradientLayer = CAGradientLayer()

    private(set)var colors: [CGColor] = [] {
        didSet {
            gradientLayer.backgroundColor = colors.first
            gradientLayer.colors = colors
        }
    }

    private let disposeBag = DisposeBag()

    init(colors: [UIColor] = []) {
        super.init(frame: .zero)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.backgroundColor = colors.first?.cgColor
        gradientLayer.colors = colors.map { $0.cgColor }
        self.layer.insertSublayer(gradientLayer, at: 0)

        rx.controlEvent(.touchDown).subscribe(onNext: { [unowned self] in
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.5)
            self.titleLabel?.alpha = 0.8
        }).disposed(by: disposeBag)

        rx.controlEvent([.touchCancel, .touchUpOutside, .touchUpInside]).subscribe(onNext: { [unowned self] in
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(1)
            self.titleLabel?.alpha = 1
        }).disposed(by: disposeBag)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated")
    }
}
