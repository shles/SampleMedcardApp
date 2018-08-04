//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import RxSwift

protocol Presentation: TransitionSource {

    var view: UIView { get }

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

    func wantsToPush() -> RxSwift.Observable<UIViewController> {
        return Observable.never()//just(ViewController(presentation: SimpleViewWthButtonPresentation()))
    }

    func wantsToPresent() -> Observable<UIViewController> {
        return button.rx.tap.asObservable().map {
            ViewController(presentation: SimpleViewWthButtonPresentation())
        }
    }

    func wantsToPop() -> Observable<Void> {
        return Observable<Void>.never()
    }

    func wantsToBeDismissed() -> Observable<Void> {
        return Observable<Void>.never()    }
}
