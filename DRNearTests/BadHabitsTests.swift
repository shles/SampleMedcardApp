//
//  BadHabitsTssts.swift
//  DRNearTests
//
//  Created by Артмеий Шлесберг on 07/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
@testable import DRNear

//swiftlint:disable all
class BadHabitsTests: QuickSpec {
    override func spec() {
        var habits: ObservableBadHabits!
        var badHabitsPresentation: Presentation!
        var disposeBag: DisposeBag!

        beforeEach {
            habits = SimpleObservableBadHabits()
            badHabitsPresentation = BadHabitsTableViewPresentation(observableHabits: habits)
        }

        describe("Bad habit presentation") {
            context("when back button tapped") {
                it("should want pop ") {

                    var vc = UIViewController()
                    var navVC = UINavigationController(rootViewController: vc)
                    navVC.pushViewController(ViewController(presentation: badHabitsPresentation), animated: false)

                    (badHabitsPresentation as! BadHabitsTableViewPresentation).simulateBackTap()

                    expect(vc).to(equal(navVC.viewControllers.first!))
                }
            }
        }
    }
}
//swiftlint:enable all

