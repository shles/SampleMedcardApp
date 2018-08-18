//
// Created by Артмеий Шлесберг on 16/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol MedicalTest: Named, Dated, Described, SystemRelated, Editable, Deletable, Identified {

}

protocol ObservableMedicalTests: DatedListRepresentable {

  func asObservable() -> Observable<[MedicalTest]>

}

extension ObservableMedicalTests {
    func toListRepresentable() -> Observable<[DatedListApplicable]> {
        return asObservable().map { $0.map { $0 as DatedListApplicable } }
    }
}

class SimpleMedicalTest: MedicalTest {
    private(set) var name: String = "Анализ крови"
    private(set) var date: Date = Date()
    var description: String = "Лаборатория NKL №122 Лабораторные исследования"

    private var deletionSubject = PublishSubject<Void>()

    func delete() {
        deletionSubject.onNext(())
    }

    func wantsToPerform() -> Observable<Transition> {
        return deletionSubject.map { [unowned self] _ in
            PresentTransition(
                    leadingTo: { ViewController(
                            presentation: DeletionPresentation(
                                    title: "Вы уверены, что хотите удалить \"\(self.name)\"?",
                                    onAccept: { }
                            )
                    )}
            )
        }
    }

    private(set) var isRelatedToSystem: Bool = false

    func edit() {

    }

    private(set) var identification: String = ""
}

class SimpleMyMedicalTests: ObservableMedicalTests {

    private let tests = [SimpleMedicalTest(),
                         SimpleMedicalTest(),
                         SimpleMedicalTest()]

    func asObservable() -> Observable<[MedicalTest]> {
        return Observable.just(tests)
    }
}

