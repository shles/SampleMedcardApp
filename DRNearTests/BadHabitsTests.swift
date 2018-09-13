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
            badHabitsPresentation = BadHabitsTableViewPresentation(observableHabits: habits.toListApplicable(), tintColor: .white, emptyStateView: UIView())
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
            context("with remote objects") {
                it("should do the same") {

                    habits = MyObservableBadHabitsFromAPI(token: TokenFromString(string: ""))

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

class BadHabitTest: QuickSpec {

    override func spec() {
        var badHabit = BadHabitFrom(name: "test", id: "test", selected: false, token: TokenFromString(string: ""))
        var disposeBag: DisposeBag = DisposeBag()
        beforeEach {
            disposeBag = DisposeBag()
        }
        describe("bad habit") {
            context("when selected") {
                it("should become selected") {
                    var testValue: Bool = false
                    badHabit.isSelected.asObservable().subscribe(onNext: {
                        testValue = $0
                    }).disposed(by: disposeBag)
                    badHabit.select()
                    expect(testValue).to(be(true))
                }
            }
        }
    }
}

class MyBadHabitTest: QuickSpec {

    override func spec() {
        var badHabit = MyBadHabitFrom(name: "test", id: "test", token: TokenFromString(string: ""))
        var disposeBag: DisposeBag = DisposeBag()
        beforeEach {
            disposeBag = DisposeBag()
        }
        describe("bad habit") {
            context("when deleting", {
                it("should return deletion presentation") {
                    var testValue: Transition?
                    badHabit.wantsToPerform().subscribe(onNext: {
                        testValue = $0
                    }).disposed(by: disposeBag)
                    badHabit.delete()
                    expect(testValue).notTo(beNil())
                }
            })
        }
    }
}

class VaccinationsTests: QuickSpec {
    override func spec() {
        var vaccinations: ObservableVaccinations!
        var vaccinationsPresentation: Presentation!

        beforeEach {
            vaccinations = SimpleObservableVaccinations()
            vaccinationsPresentation = BadHabitsTableViewPresentation(observableHabits: vaccinations.toListApplicable(), tintColor: .white, emptyStateView: UIView())
        }

        describe("Bad habit presentation") {
            context("when back button tapped") {
                it("should want pop ") {

                    var vc = UIViewController()
                    var navVC = UINavigationController(rootViewController: vc)
                    navVC.pushViewController(ViewController(presentation: vaccinationsPresentation), animated: false)

                    UIApplication.shared.keyWindow!.rootViewController = navVC
                    navVC.preloadView()
                    vc.preloadView()

                    (vaccinationsPresentation as! BadHabitsTableViewPresentation).simulateBackTap()

                    expect(vc) == navVC.viewControllers.first!
                }
            }
            context("with remote objects") {
                it("should do the same") {

                    vaccinations = MyObservableVaccinationsFromAPI(token: TokenFromString(string: ""))

                    var vc = UIViewController()
                    var navVC = UINavigationController(rootViewController: vc)
                    navVC.pushViewController(ViewController(presentation: vaccinationsPresentation), animated: false)

                    UIApplication.shared.keyWindow!.rootViewController = navVC
                    navVC.preloadView()
                    vc.preloadView()

                    (vaccinationsPresentation as! BadHabitsTableViewPresentation).simulateBackTap()

                    expect(vc) == navVC.viewControllers.first!

                }
            }
        }
    }
}
//swiftlint:enable all
