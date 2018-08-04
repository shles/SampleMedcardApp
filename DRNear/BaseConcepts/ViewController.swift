//
//  ViewController.swift
//  DRNear
//
//  Created by Артмеий Шлесберг on 31/07/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

class ViewController: UIViewController {

    private let presentation: Presentation
    private let disposeBag = DisposeBag()

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
            $0.edges.equalToSuperview()
        }

        presentation.wantsToPresent().subscribe(onNext: { [unowned self] in
            self.present($0, animated: true)
        }).disposed(by: disposeBag)

        presentation.wantsToPush().subscribe(onNext: { [unowned self] in
            self.navigationController?.pushViewController($0, animated: true)
        }).disposed(by: disposeBag)

        presentation.wantsToPop().subscribe(onNext: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)

        presentation.wantsToBeDismissed().subscribe(onNext: {
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)

    }

}
