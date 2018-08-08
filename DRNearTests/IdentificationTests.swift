//
// Created by Артмеий Шлесберг on 07/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

@testable import DRNear
import Foundation
import Nimble
import Quick

class IdentificationTests: QuickSpec {
    override func spec() {

        describe("Two identifiable objects") {
            context("when have same id's") {
                it("should be equal") {

                    let habit = SimpleBadHabit()
                    let sameHabit = SimpleBadHabit()

                    expect(habit.isEqual(to: sameHabit)).to(be(true))
                }
            }
            context("having different id's") {
                it("should not be equal") {

                    let habit = SimpleBadHabit()
                    let notSameHabit = SimpleBadHabit()

                    notSameHabit.identification = "124"
                    expect(habit.isEqual(to: notSameHabit)).to(be(false))
                }
            }
        }
    }
}
