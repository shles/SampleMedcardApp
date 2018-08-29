//
//  SimpleConsultation.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class SimpleConsultation: Consultation, ContainFiles {

    private(set) var name: String = "Врач-педиатр"
    private(set) var date: Date = Date()
    var description: String = "Первичная консультация"

    private var deletionSubject = PublishSubject<Void>()
    private var interactionSubject = PublishSubject<Void>()
    private var editionSubject = PublishSubject<Void>()

    func delete() {
        deletionSubject.onNext(())
    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.merge([
            deletionSubject.map { [unowned self] _ in
                PresentTransition(leadingTo: {
                    ViewController(
                            presentation: DeletionPresentation(
                                    title: "Вы уверены, что хотите удалить \"\(self.name)\"?",
                                    onAccept: {Observable.just(())}
                            )
                    )
                }
                )
            },
            interactionSubject.debug("interacted with \(self.description)").map { [unowned self] _ in
                PushTransition(leadingTo: {
                    ViewController(presentation: DatedDescribedFileContainedPresentation(item: self, gradient: [.lightPeriwinkle, .softPink]))
                })
            }
//            editionSubject.map { [unowned self] _ in
//                PushTransition(leadingTo: {
//                    ViewController(presentation: MedicalTestEditingPresentation(medTest: self))
//                })
//            }
        ])
    }

    private(set) var isRelatedToSystem: Bool = false

    func edit() {
        editionSubject.onNext(())
    }

    private(set) var identification: String = ""

    func interact() {
        interactionSubject.onNext(())
    }

    var files: [File] = [FileFrom(name: "Записи с консультации", size: 11)]

    private(set) var json: [String: Any] = [:]
}

class SimpleMyConsultations: ObservableConsultations {

    private let tests = [SimpleConsultation(),
                         SimpleConsultation(),
                         SimpleConsultation()]

    func asObservable() -> Observable<[Consultation]> {
        return Observable.just(tests)
    }
}
