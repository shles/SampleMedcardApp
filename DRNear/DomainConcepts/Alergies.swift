//
// Created by Артмеий Шлесберг on 15/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

/*
    TODO: create MyObservableAllergies and AllObservableAllergies
    examle in MyBadHabitFrom, BadHabitFrom, AllObservableBadHabitsFfomAPI, MyObservableBadHabitsFromAPI
*/

protocol Allergies: ListApplicable {

}

protocol ObservableAllergies: ListRepresentable {
    func asObservable() -> Observable<Allergies>
}
