//
//  ViewController.swift
//  DRNear
//
//  Created by Артмеий Шлесберг on 31/07/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class ViewController: UIViewController {

    let presentation: Presentation
    private var disposeBag = DisposeBag()

    init(presentation: Presentation) {
        self.presentation = presentation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(presentation.view)
        presentation.view.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        view.backgroundColor = .white
        presentation.wantsToPerform().subscribe(onNext: {
            $0.perform(on: self)
        }).disposed(by: disposeBag)

        setNeedsStatusBarAppearanceUpdate()
        automaticallyAdjustsScrollViewInsets = false

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        //FIXME: awfult, but set here views that shouldn't hide keyboard
//        guard !(self is PhoneAuthorizationRequestViewController) && !(self is PhoneAuthorizationCodeViewController) else {
//            return
//        }
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presentation.willAppear()

        navigationController?.interactivePopGestureRecognizer?.delegate = nil

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        disposeBag = DisposeBag()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if presentation is MedCardCollectionViewPresentation {
            return .default
        }
        return .lightContent
    }

    override func anotherWillAppear() {
        presentation.willAppear()
    }
}
