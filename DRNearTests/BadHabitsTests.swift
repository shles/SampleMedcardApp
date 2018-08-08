//
//  BadHabitsTssts.swift
//  DRNearTests
//
//  Created by Артмеий Шлесберг on 07/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

@testable import DRNear
import Foundation
import Nimble
import Quick
import RxSwift

//swiftlint:disable all
class BadHabitsTests: QuickSpec {
    override func spec() {
        var habits: ObservableBadHabits!
        var badHabitsPresentation: Presentation!

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
                    
                    UIApplication.shared.keyWindow!.rootViewController = navVC
                    navVC.preloadView()
                    vc.preloadView()

                    (badHabitsPresentation as! BadHabitsTableViewPresentation).simulateBackTap()

                    expect(vc) == navVC.viewControllers.first!
                }
            }
        }
    }
}
//swiftlint:enable all
