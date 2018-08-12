//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import UIKit

protocol Presentation: TransitionSource {

    var view: UIView { get }

    func willAppear()

}

class SimpleViewWthButtonPresentation: Presentation {

    let view: UIView
    private let button = UIButton()

    init() {
        view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.addSubview(button)
        button.setTitle("Present", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return button.rx.tap.asObservable().map {
            PresentTransition(leadingTo: { ViewController(presentation: SimpleViewWthButtonPresentation()) })
        }
    }
}
