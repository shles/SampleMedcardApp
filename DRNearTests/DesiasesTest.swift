//
//  DiseasesTest.swift
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

class DiseaseTest: QuickSpec {
    
    override func spec() {
        var disease = DiseaseFrom(name: "test", id: "test", code: "test", selected: false, token: TokenFromString(string: ""))
        var disposeBag: DisposeBag = DisposeBag()
        beforeEach {
            disposeBag = DisposeBag()
        }
        describe("bad habit") {
            context("when selected") {
                it("should become selected") {
                    var testValue: Bool = false
                    disease.isSelected.asObservable().subscribe(onNext: {
                        testValue = $0
                    }).disposed(by: disposeBag)
                    disease.select()
                    expect(testValue).to(be(true))
                }
            }
        }
    }
}

class MyDiseaseTest: QuickSpec {
    
    override func spec() {
        let disease = MyDiseaseFrom(name: "test", id: "test", code: "test", token: TokenFromString(string: ""))
        var disposeBag: DisposeBag = DisposeBag()
        beforeEach {
            disposeBag = DisposeBag()
        }
        describe("bad habit") {
            context("when deleting", {
                it("should return deletion presentation") {
                    var testValue: Transition?
                    disease.wantsToPerform().subscribe(onNext: {
                        testValue = $0
                    }).disposed(by: disposeBag)
                    disease.delete()
                    expect(testValue).notTo(beNil())
                }
            })
        }
    }
}
