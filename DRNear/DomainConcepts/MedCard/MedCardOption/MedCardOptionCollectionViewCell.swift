//
// Created by Артмеий Шлесберг on 03/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

class MedCardOptionCollectionViewCell: UICollectionViewCell {

    private let imageView = UIImageView()
            .with(contentMode: .scaleAspectFit)
    private let nameLabel = UILabel()
            .with(numberOfLines: 2)
            .with(font: .medCardCell)
            .with(textColor: .mainText)
    private let gradientView = GradientView()
    private let shadowView = UIView()
            .withShadow(xOffset: 0, yOffset: 5, radius: 20, opacity: 1, shadowColor: .shadow)
            .with(backgroundColor: .white)
    private let innerView = UIView()
            .with(roundedEdges: 4)
            .with(borderWidth: 1, borderColor: .shadow)

    private var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews([shadowView, innerView])

        innerView.addSubviews([imageView, nameLabel, gradientView])

        innerView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(4)
            $0.trailing.bottom.equalToSuperview().inset(4)
        }

        shadowView.snp.makeConstraints {
            $0.edges.equalTo(innerView)
        }
        nameLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(24)
        }

        gradientView.snp.makeConstraints {
            $0.trailing.bottom.leading.equalToSuperview()
            $0.height.equalTo(8)
        }

        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(31)
            $0.top.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(80)
        }

        backgroundColor = .white

        shadowView.alpha = 0
    }

    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.shadowView.alpha = newValue ? 1 : 0
                self?.innerView.layer.borderWidth = newValue ? 0 : 1
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated!")
    }

    func configure(medCardOption: MedCardOption) {
        medCardOption.image.asObservable().bind(to: imageView.rx.image).disposed(by: disposeBag)
        nameLabel.text = medCardOption.name
        gradientView.setColors(medCardOption.gradientColors)
    }
}
