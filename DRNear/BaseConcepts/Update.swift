//
// Created by Артмеий Шлесберг on 14/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

protocol Update: TransitionSource {

    func addItem(item: Identified)

    func apply()

}


class MyBadHabitsUpdate: Update {

    private var itemsToCommit = [Identified]()
    private let token: Token
    private let disposeBag = DisposeBag()

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
            request.make().subscribe(onNext: { _ in

            }).disposed(by: disposeBag)
        }

    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.never()
    }
}
