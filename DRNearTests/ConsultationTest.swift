//
//  ConsultationTest.swift
//  DRNearTests
//
//  Created by Артмеий Шлесберг on 11/09/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
import RxSwift
@testable import DRNear

class ConsultationTest: QuickSpec {
    override func spec() {
        describe("consultation") {
            let consultation = MyConsultationFrom(name: "test", id: "test", date: Date(), description: "aerta", token: TokenFromString(string: ""))
            context("when interacted") {
                var testValue: Transition!
                let disposeBag = DisposeBag()
                consultation.wantsToPerform().subscribe(onNext: {
                    testValue = $0
                }).disposed(by: disposeBag)
                
                consultation.interact()
                
                it("should lead to self presentation") {
                    expect(testValue).notTo(beNil())
                }
            }
            context("when deleting") {
                var testValue: Transition!
                let disposeBag = DisposeBag()
                consultation.wantsToPerform().subscribe(onNext: {
                    testValue = $0
                }).disposed(by: disposeBag)
                
                consultation.delete()
                it("should lead to presentation") {
                    expect(testValue).notTo(beNil())
                }
            }
            context("when editing") {
                
                var testValue: Transition!
                let disposeBag = DisposeBag()
                consultation.wantsToPerform().subscribe(onNext: {
                    testValue = $0
                }).disposed(by: disposeBag)
                
                consultation.edit()
                it("should lead to presentation") {
                    expect(testValue).notTo(beNil())
                }
            }
        }
    }
}

class SystemConsultationTest: QuickSpec {
    override func spec() {
        describe("system consultation") {
            let cons = SimpleSystemConsultation()
            context("presentation", {
                let presentation = SystemConsultationPresentation(item: cons, gradient: [])
                it("should exist") {
                    let view = presentation.view
                    expect(view).notTo(beNil())
                }
            })
        }
    }
}
