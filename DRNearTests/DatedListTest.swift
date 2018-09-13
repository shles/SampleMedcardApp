//
//  DatedListTest.swift
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

class DatedListTest: QuickSpec {
    override func spec() {
        let items = SimpleObservableSystemConsultations()
        let presentation = DDNListPresentation(items: items, title: "", gradient: [], leadingTo: { ViewController(presentation: SimpleViewWthButtonPresentation()) }, emptyStateView: UIView())
        describe("list") {
            context("when appears") {
                it("") {
                    UIApplication.shared.keyWindow?.rootViewController = ViewController(presentation: presentation)
                    UIApplication.shared.keyWindow?.rootViewController?.preloadView()
                    let view = UIApplication.shared.keyWindow?.rootViewController?.view
                    
                    expect(view).notTo(beNil())
                }
            }
        }
    }
}

class DatedItemPresentationTest: QuickSpec {
    override func spec() {
        let test = MyMedicalTestFrom(name: "test", id: "test", date: Date(), description: "test", token: TokenFromString(string: "test"))
        let presentation = DatedDescribedFileContainedPresentation(item: test, gradient: [] )
        describe("item presentation") {
            context("when presented", {
                it("should exist") {
                    UIApplication.shared.keyWindow?.rootViewController = ViewController(presentation: presentation)
                    UIApplication.shared.keyWindow?.rootViewController?.preloadView()
                    let view = UIApplication.shared.keyWindow?.rootViewController?.view
                    
                    expect(view).notTo(beNil())
                }
            })
        }
    }
}

class DatedCellTest: QuickSpec {
    override func spec() {
        let test = MyMedicalTestFrom(name: "test", id: "test", date: Date(), description: "test", token: TokenFromString(string: "test"))
        let cell = DatedDescribedCell(style: .default, reuseIdentifier: "")
        describe("item presentation") {
            context("when presented", {
                it("should exist") {
                   
                    let view = cell.configured(item: test).contentView
        
                    expect(view).notTo(beNil())
                }
            })
        }
    }
}
