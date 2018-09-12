//
//  File.swift
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

class VaccinationTest: QuickSpec {
    
    override func spec() {
        var vaccination = VaccinationFrom(name: "test", id: "test", code: "test", date: Date(), selected: false, token: TokenFromString(string: ""))
        var disposeBag: DisposeBag = DisposeBag()
        beforeEach {
            disposeBag = DisposeBag()
        }
        describe("bad habit") {
            context("when selected") {
                it("should become selected") {
                    var testValue: Bool = false
                    vaccination.isSelected.asObservable().subscribe(onNext: {
                        testValue = $0
                    }).disposed(by: disposeBag)
                    vaccination.select()
                    expect(testValue).to(be(true))
                }
            }
        }
    }
}

class MyVaccinationTest: QuickSpec {
    
    override func spec() {
        var vaccination = MyVaccinationFrom(name: "test", id: "test", code: "test", date: Date(), token: TokenFromString(string: ""))
        var disposeBag: DisposeBag = DisposeBag()
        beforeEach {
            disposeBag = DisposeBag()
        }
        describe("bad habit") {
            context("when deleting", {
                it("should return deletion presentation") {
                    var testValue: Transition?
                    vaccination.wantsToPerform().subscribe(onNext: {
                        testValue = $0
                    }).disposed(by: disposeBag)
                    vaccination.delete()
                    expect(testValue).notTo(beNil())
                }
            })
        }
    }
}
