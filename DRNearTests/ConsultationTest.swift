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
            let consultation = SimpleConsultation()
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
