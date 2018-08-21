//
//  AllergiesUpdate.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class AllergiesUpdate: Update {
    
    private var itemsToCommit = [Identified]()
    private let token: Token
    private let disposeBag = DisposeBag()

    private let transitionSubject = PublishSubject<Transition>()
    init(token: Token) {
        self.token = token
    }
    
    func addItem(item: Identified) {
        transitionSubject.onNext(PresentTransition(leadingTo: {
            ViewController(presentation: CommentPresentation(title: "Комментарий", onAccept: { [unowned self] in
                self.itemsToCommit += [item]
            }))
        }))
    }
    
    func apply() {

        if let request = try? AuthorizedRequest(
            path: "/eco-emc/api/my/allergies",
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
        return transitionSubject
    }
}
