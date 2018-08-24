//
//  DiseasesUpdate.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class DiseasesUpdate: Update {

    private var itemsToCommit = [CommentedDisease]()
    private let token: Token
    private let disposeBag = DisposeBag()
    private let transitionSubject = PublishSubject<Transition>()

    init(token: Token) {
        self.token = token
    }

    func addItem(item: Identified) {

        if let item = item as? Disease {

            transitionSubject.onNext(PresentTransition(leadingTo: {
                ViewController(presentation: CommentPresentation(title: "Комментарий", gradient: [.peach, .wheat], onAccept: { [unowned self] in
                    self.itemsToCommit += [CommentedDisease(origin: item, comment: $0)]
                }))
            }))
        }
    }

    func apply() {
        if let request = try? AuthorizedRequest(
            path: "/eco-emc/api/my/diagnoses",
            method: .post,
            token: token,
            parameters: itemsToCommit.map { [
                "name": [
                    "code": $0.identification
                ],
                "comment": $0.comment
            ] }.asParameters(),
            encoding: ArrayEncoding()
            ) {
            request.make().subscribe(onNext: { [unowned self] _ in
                self.transitionSubject.onNext(PopTransition())
            }, onError: { [unowned self] in
                self.transitionSubject.onNext(ErrorAlertTransition(error: $0))
            }).disposed(by: disposeBag)
        }

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
}
