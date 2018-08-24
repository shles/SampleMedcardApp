//
// Created by Артмеий Шлесберг on 17/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class MyBadHabitsUpdate: Update {

    private var itemsToCommit = [Identified]()
    private let token: Token
    private let disposeBag = DisposeBag()

    private let transitionSubject = PublishSubject<Transition>()

    init(token: Token) {
        self.token = token
    }

    func addItem(item: Identified) {
        itemsToCommit += [item]
    }

    func apply() {
        if let request = try? AuthorizedRequest(
                path: "/eco-emc/api/my/bad-habits",
                method: .post,
                token: token,
                parameters: itemsToCommit.map { $0.identification }.asParameters(),
                encoding: ArrayEncoding()
        ) {
            request.make().subscribe(onNext: { response in

                if let error = response.error {
                    self.transitionSubject.onNext(ErrorAlertTransition(error: error))
                } else {
                    self.transitionSubject.onNext(PopTransition())
                }
            }).disposed(by: disposeBag)
        }

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
}
