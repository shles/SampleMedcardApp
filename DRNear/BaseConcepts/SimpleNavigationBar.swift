//
// Created by Артмеий Шлесберг on 03/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

class SimpleNavigationBar: UIView {

    private var titleLabel = UILabel()
    .with(font: .navigatoinLarge)
    .with(textColor: .mainText)

    init(title: String) {
        titleLabel.text = title
        super.init(frame: .zero)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(48)
        }
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated!")
    }

    func with(rightInactiveButton button: UIButton ) -> Self {
        addSubview(button)
        button.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(titleLabel)
        }
        return self
    }
}

class NavigationBarWithBackButton: UIView, TransitionSource {

    private var titleLabel = UILabel()
            .with(font: .navigatoinLarge)
            .with(textColor: .white)

    private var backButton = UIButton()
            .with(image: #imageLiteral(resourceName: "backIcon"))
            .with(contentMode: .center)

    init(title: String) {
        titleLabel.text = title
        super.init(frame: .zero)
        addSubviews([titleLabel, backButton])
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing).offset(12)
            $0.top.equalToSuperview().offset(48)
        }
        backButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(27)
            $0.width.equalTo(18)
        }
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated!")
    }

    func with(rightInactiveButton button: UIButton) -> Self {
        addSubview(button)
        button.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(titleLabel)
        }
        return self
    }

    func wantsToPerform() -> Observable<Transition> {
        return backButton.rx.tap.map { _ in PopTransition() }
    }
}
