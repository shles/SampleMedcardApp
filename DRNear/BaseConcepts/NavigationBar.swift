//
// Created by Артмеий Шлесберг on 03/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

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
}

class NavigationBarWithBackButton: UIView, TransitionSource {

    private var titleLabel = UILabel()
            .with(font: .navigatoinLarge)
            .with(textColor: .mainText)

    private var backButton = UIButton()
            .with(image: #imageLiteral(resourceName: "backIcon"))

    init(title: String) {
        titleLabel.text = title
        super.init(frame: .zero)
        addSubviews([titleLabel, backButton])
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing).offset(12)
            $0.top.equalToSuperview().offset(48)
        }
        backButton.snp.makeConstraints {
            $0.lastBaseline.equalTo(titleLabel)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(18)
            $0.width.equalTo(12)
        }
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated!")
    }


    func wantsToPush() -> RxSwift.Observable<UIViewController> {
        return Observable.never()//just(ViewController(presentation: SimpleViewWthButtonPresentation()))
    }

    func wantsToPresent() -> Observable<UIViewController> {
        return Observable.never()
    }

    func wantsToPop() -> Observable<Void> {
        return backButton.rx.tap.map {_ in }
    }

    func wantsToBeDismissed() -> Observable<Void> {
        return Observable<Void>.never()
    }

    func with(gradient colors: [UIColor]) -> Self {
        let gradientView = GradientView()
        addSubview(gradientView)
        sendSubview(toBack: gradientView)
        gradientView.setColors(colors)
        gradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        titleLabel.textColor = .white
        return self
    }

}
