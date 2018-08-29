//
// Created by Артмеий Шлесберг on 28/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class AuthorizationPresentation: Presentation {

    private var auth: Authorization
    private var enterCodeView: EnterCodeView

    init(auth: Authorization) {
        self.auth = auth

        enterCodeView = EnterCodeView(
                title: "Введите пинкод",
                image: #imageLiteral(resourceName: "page1Copy"),
                symbolsNumber: 4)

        view.addSubview(enterCodeView)

        enterCodeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        enterCodeView.codeEntered.subscribe(onNext: { [unowned self] in
            self.auth.auth(code: $0)
        })
    }

    func willAppear() {
        auth.tryToAuthWithBiometry()
    }

    private(set) var view: UIView = UIView()

    func wantsToPerform() -> Observable<Transition> {
        return auth.wantsToPerform()
    }
}

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
                                    numberRegistration: NumberRegistrationFromAPI(leadingTo: mainAppSetup )
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
                                                    leadingTo: {
                                                        ViewController(
                                                                presentation: MyBadHabitsPresentation(
                                                                        badHabits: MyObservableBadHabitsFromAPI(token: token),
                                                                        title: "Добавить привычку",
                                                                        gradient: [.wheatTwo, .rosa],
                                                                        leadingTo: {
                                                                            return ViewController(
                                                                                    presentation: AllBadHabitsPresentation(
                                                                                            badHabits: AllObservableBadHabitsFromAPI(token: token),
                                                                                            update: MyBadHabitsUpdate(token: token),
                                                                                            title: "Список привычек",
                                                                                            gradient: [.wheatTwo, .rosa]
                                                                                    )
                                                                            )
                                                                        }
                                                                )
                                                        )
                                                    }
                                            ),
                                            MedCardOptionFrom(
                                                    name: "Аллергии",
                                                    image: ObservableImageFrom(
                                                            image: #imageLiteral(resourceName: "rocketMedYellow")
                                                    ),
                                                    gradientColors: [.peach, .wheat],
                                                    leadingTo: {
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
                                                                        }
                                                                )
                                                        )
                                                    }
                                            ),
                                            MedCardOptionFrom(
                                                    name: "Прививки",
                                                    image: ObservableImageFrom(
                                                            image: #imageLiteral(resourceName: "rocketMedGreen")
                                                    ),
                                                    gradientColors: [.paleOliveGreen, .beige],
                                                    leadingTo: {
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
                                                                        }
                                                                )
                                                        )
                                                    }

                                            ),
                                            MedCardOptionFrom(
                                                    name: "Исследования и анализы",
                                                    image: ObservableImageFrom(
                                                            image: #imageLiteral(resourceName: "rocketMedBlue")
                                                    ),
                                                    gradientColors: [.darkSkyBlue, .tiffanyBlue],
                                                    leadingTo: {
                                                        ViewController(presentation: DDNListPresentation(
                                                                items: MyObservableMedicalTestsFromAPI(token: token),
                                                                title: "Исследования и анализы",
                                                                gradient: [.darkSkyBlue, .tiffanyBlue],
                                                                leadingTo: {
                                                                    ViewController(presentation: MedicalTestEditingPresentation(token: token))
                                                                }))
                                                    }
                                            ),
                                            MedCardOptionFrom(
                                                    name: "Хронические заболевания",
                                                    image: ObservableImageFrom(
                                                            image: #imageLiteral(resourceName: "rocketMedDarkBlue")
                                                    ),
                                                    gradientColors: [.pastelBlue, .powderBlue],
                                                    leadingTo: {
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
                                                                        }
                                                                )
                                                        )
                                                    }

                                            ),
                                            MedCardOptionFrom(
                                                    name: "Консультации",
                                                    image: ObservableImageFrom(
                                                            image: #imageLiteral(resourceName: "rocketMedViolet")
                                                    ),
                                                    gradientColors: [.lightPeriwinkle, .softPink],
                                                    leadingTo: {
                                                        ViewController(presentation: DDNListPresentation(
                                                                items: (try? MyObservableConsultationsFromAPI(token: token)) ?? ObservableSimpleMyConsultations(),
                                                                title: "Консультации",
                                                                gradient: [.lightPeriwinkle, .softPink],
                                                                leadingTo: {
                                                                    ViewController(presentation: ConsultationEditingPresentation(token: token))
                                                                }))
                                                    }
                                            )
                                        ]
                                )
                        ).withTabBarStub()
                )
        ).withoutNavigationBar()
    }
}
