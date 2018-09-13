//
// Created by Артмеий Шлесберг on 28/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

//TODO: Make injection o f all presentations. It will help testing.
//Tests will inject 'Spy' presentations that will detect method invocations.
//Spy presentation objects will inherit from original presentations6 just adding tracking methods or properties

class ApplicationConfiguration {

    func activateTouchID(forCode code: String) {
        UserDefaults.standard.set(true, forKey: "touchIDKey")
        saveCode(code: code)
    }

    func activateFaceID(forCode code: String) {
        UserDefaults.standard.set(true, forKey: "faceIDKey")
        saveCode(code: code)
    }

    func saveCode(code: String) {
        //TODO: make it secure
        UserDefaults.standard.set(code, forKey: "userCodeKey")
    }

    func saveRefreshToken(token: String) {
        UserDefaults.standard.set(token, forKey: "refreshTokenKey")
    }

    var token: String? {
        return UserDefaults.standard.string(forKey: "refreshTokenKey")
    }

    var code: String? {
        return UserDefaults.standard.string(forKey: "userCodeKey")
    }

    func rootController() -> UIViewController {

        if UserDefaults.standard.value(forKey: "touchIDKey") != nil ||
               UserDefaults.standard.value(forKey: "faceIDKey") != nil ||
               UserDefaults.standard.value(forKey: "userCodeKey") != nil {
            return ViewController(presentation: AuthorizationPresentation(auth: InAppAuthorization(leadingTo: mainAppSetup)))
        } else {
            return UINavigationController(
                rootViewController: ViewController(
                    presentation: NumberRegistrationPresentation(
                        numberRegistration: NumberRegistrationFromAPI(leadingTo: mainAppSetup)
                    )
                )
            ).withoutNavigationBar()
        }
    }

    let mainAppSetup: (Token) -> (UIViewController) = { token in
        UINavigationController(
            rootViewController: ViewController(
                presentation: MedCardCollectionViewPresentation(
                    medCardOptions: MedCardFrom(
                        options: [
                            MedCardOptionFrom(
                                name: "Вредные привычки",
                                image: ObservableImageFrom(
                                    image: #imageLiteral(resourceName: "rocketMed")
                                ),
                                gradientColors: [.rosa, .wheatTwo],
                                leadingTo: PushTransition(leadingTo: {
                                    ViewController(
                                        presentation: MyBadHabitsPresentation(
                                            badHabits: MyObservableBadHabitsFromAPI(token: token),
                                            title: "Вредные привычки",
                                            gradient: [.wheatTwo, .rosa],
                                            leadingTo: {
                                                return ViewController(
                                                    presentation: AllBadHabitsPresentation(
                                                        badHabits: AllObservableBadHabitsFromAPI(token: token),
                                                        update: MyBadHabitsUpdate(token: token),
                                                        title: "Добавить привычку",
                                                        gradient: [.wheatTwo, .rosa]
                                                    )
                                                )
                                            },
                                            emptyStateView: EmptyStateView(
                                                image: #imageLiteral(resourceName: "emptyState"),
                                                title: "Добавьте в этот раздел привычки, которыми вы обладаете.")
                                        )
                                    )
                                })
                            ),
                            MedCardOptionFrom(
                                name: "Аллергии",
                                image: ObservableImageFrom(
                                    image: #imageLiteral(resourceName: "rocketMedYellow")
                                ),
                                gradientColors: [.peach, .wheat],
                                leadingTo: PushTransition(leadingTo: {
                                    ViewController(
                                        presentation: MyBadHabitsPresentation(
                                            badHabits: MyObservableAllergiesFromAPI(token: token),
                                            title: "Аллергии",
                                            gradient: [.peach, .wheat],
                                            leadingTo: {
                                                return ViewController(
                                                    presentation: AllBadHabitsPresentation(
                                                        badHabits: AllObservableAllergiesFromAPI(token: token),
                                                        update: AllergiesUpdate(token: token),
                                                        title: "Добавить аллергию",
                                                        gradient: [.peach, .wheat]
                                                    )
                                                )
                                        },
                                            emptyStateView: EmptyStateView(
                                                image: #imageLiteral(resourceName: "emptyState"),
                                                title: "Добавьте в этот раздел аллергии, которые у вас были диагностированы.")
                                        )
                                    )
                                })
                            ),
                            MedCardOptionFrom(
                                name: "Прививки",
                                image: ObservableImageFrom(
                                    image: #imageLiteral(resourceName: "rocketMedGreen")
                                ),
                                gradientColors: [.paleOliveGreen, .beige],
                                leadingTo: PushTransition(leadingTo: {
                                    ViewController(
                                        presentation: MyBadHabitsPresentation(
                                            badHabits: MyObservableVaccinationsFromAPI(token: token),
                                            title: "Прививки",
                                            gradient: [.paleOliveGreen, .beige],
                                            leadingTo: {
                                                return ViewController(
                                                    presentation: AllBadHabitsPresentation(
                                                        badHabits: AllObservableVaccinationsFromAPI(token: token),
                                                        update: VaccinationUpdate(token: token),
                                                        title: "Добавить прививку",
                                                        gradient: [.paleOliveGreen, .beige]
                                                    )
                                                )
                                        },
                                            emptyStateView: EmptyStateView(
                                                image: #imageLiteral(resourceName: "emptyState"),
                                                title: "Добавьте в этот раздел прививки, которые вам были поставленны.")
                                        )
                                    )
                                })

                            ),
                            MedCardOptionFrom(
                                name: "Исследования и анализы",
                                image: ObservableImageFrom(
                                    image: #imageLiteral(resourceName: "rocketMedBlue")
                                ),
                                gradientColors: [.darkSkyBlue, .tiffanyBlue],
                                leadingTo: PushTransition(leadingTo: {
                                    ViewController(presentation: DDNListPresentation(
                                        items: MyObservableMedicalTestsFromAPI(token: token),
                                        title: "Исследования и анализы",
                                        gradient: [.darkSkyBlue, .tiffanyBlue],
                                        leadingTo: {
                                            ViewController(presentation: MedicalTestEditingPresentation(token: token))
                                    },
                                        emptyStateView: EmptyStateView(
                                            image: #imageLiteral(resourceName: "emptyState"),
                                            title: "Добавьте в этот раздел анализы, которые вы проводили.")))
                                })
                            ),
                            MedCardOptionFrom(
                                name: "Хронические заболевания",
                                image: ObservableImageFrom(
                                    image: #imageLiteral(resourceName: "rocketMedDarkBlue")
                                ),
                                gradientColors: [.pastelBlue, .powderBlue],
                                leadingTo: PushTransition(leadingTo: {
                                    ViewController(
                                        presentation: MyBadHabitsPresentation(
                                            badHabits: MyObservableDiseasesFromAPI(token: token),
                                            title: "Хронические заболевания",
                                            gradient: [.pastelBlue, .powderBlue],
                                            leadingTo: {
                                                return ViewController(
                                                    presentation: AllBadHabitsPresentation(
                                                        badHabits: AllObservableDiseasesFromAPI(token: token),
                                                        update: DiseasesUpdate(token: token),
                                                        title: "Добавить заболевание",
                                                        gradient: [.pastelBlue, .powderBlue]
                                                    )
                                                )
                                        },
                                            emptyStateView: EmptyStateView(
                                                image: #imageLiteral(resourceName: "emptyState"),
                                                title: "Добавьте в этот раздел заболевания, которые у вас были диагностированы.")
                                        )
                                    )
                                })

                            ),
                            MedCardOptionFrom(
                                name: "Консультации",
                                image: ObservableImageFrom(
                                    image: #imageLiteral(resourceName: "rocketMedViolet")
                                ),
                                gradientColors: [.lightPeriwinkle, .softPink],
                                leadingTo: PushTransition(leadingTo: {
                                    ViewController(presentation: DDNListPresentation(
                                        items: (try? MyObservableConsultationsFromAPI(token: token)) ?? ObservableSimpleMyConsultations(),
                                        title: "Консультации",
                                        gradient: [.lightPeriwinkle, .softPink],
                                        leadingTo: {
                                            ViewController(presentation: ConsultationEditingPresentation(token: token))
                                    },
                                        emptyStateView: EmptyStateView(
                                            image: #imageLiteral(resourceName: "emptyState"),
                                            title: "Добавьте в этот раздел заболевания, которые вы посещали.")))
                                })
                            )
                        ]
                    )
                ).withTabBarStub()
            )
        ).withoutNavigationBar()
    }
}
