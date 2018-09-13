//
//  MedicalTestTests.swift
//  DRNearTests
//
//  Created by Артмеий Шлесберг on 12/09/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
import RxSwift
@testable import DRNear

class MedicalTestTests: QuickSpec {
    override func spec() {
        describe("presentation") {
            let test = MyMedicalTestFrom(name: "test", id: "test", date: Date(), description: "test", token: TokenFromString(string: "test"))
            let presentation = MedicalTestEditingPresentation(medTest: test, onSave: { () -> Observable<Void> in
                return Observable.just(())
            })
            context("when creaitng") {
                it("view should exist") {
                    UIApplication.shared.keyWindow?.rootViewController = ViewController(presentation: presentation)
                    UIApplication.shared.keyWindow?.rootViewController?.preloadView()
                    let view = UIApplication.shared.keyWindow?.rootViewController?.view
                    
                    expect(view).notTo(beNil())
                }
            }
        }
    }
}


