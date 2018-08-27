//
//  AppDelegate.swift
//  DRNear
//
//  Created by Артмеий Шлесберг on 31/07/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

//swiftlint:disable function_body_length
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        let token = TokenFromString(string: "")
        window?.rootViewController = UINavigationController(
                rootViewController: ViewController(presentation: NumberRegistrationPresentation(numberRegistration: NumberRegistrationFromAPI(leadingTo: { token in
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
                                                                leadingTo: { ViewController(
                                                                        presentation: MyBadHabitsPresentation(
                                                                                badHabits: MyObservableBadHabitsFromAPI(token: token),
                                                                                title: "Вредные привычки",
                                                                                gradient: [.wheatTwo, .rosa],
                                                                                leadingTo: { return ViewController(
                                                                                        presentation: AllBadHabitsPresentation(
                                                                                                badHabits: AllObservableBadHabitsFromAPI(token: token),
                                                                                                update: MyBadHabitsUpdate(token: token),
                                                                                                title: "Список привычек",
                                                                                                gradient: [.wheatTwo, .rosa]
                                                                                        )
                                                                                )}
                                                                        )
                                                                )}
                                                        ),
                                                        MedCardOptionFrom(
                                                                name: "Аллергии",
                                                                image: ObservableImageFrom(
                                                                        image: #imageLiteral(resourceName: "rocketMedYellow")
                                                                ),
                                                                gradientColors: [.peach, .wheat],
                                                                leadingTo: { ViewController(
                                                                        presentation: MyBadHabitsPresentation(
                                                                                badHabits: MyObservableAllergiesFromAPI(token: token),
                                                                                title: "Аллергии",
                                                                                gradient: [.peach, .wheat],
                                                                                leadingTo: { return ViewController(
                                                                                        presentation: AllBadHabitsPresentation(
                                                                                                badHabits: AllObservableAllergiesFromAPI(token: token),
                                                                                                update: AllergiesUpdate(token: token),
                                                                                                title: "Список аллергий",
                                                                                                gradient: [.peach, .wheat]
                                                                                        )
                                                                                )}
                                                                        )
                                                                )}
                                                        ),
                                                        MedCardOptionFrom(
                                                                name: "Прививки",
                                                                image: ObservableImageFrom(
                                                                        image: #imageLiteral(resourceName: "rocketMedGreen")
                                                                ),
                                                                gradientColors: [.paleOliveGreen, .beige],
                                                                leadingTo: { ViewController(
                                                                        presentation: MyBadHabitsPresentation(
                                                                                badHabits: MyObservableVaccinationsFromAPI(token: token),
                                                                                title: "Прививки",
                                                                                gradient: [.paleOliveGreen, .beige],
                                                                                leadingTo: { return ViewController(
                                                                                        presentation: AllBadHabitsPresentation(
                                                                                                badHabits: AllObservableVaccinationsFromAPI(token: token),
                                                                                                update: VaccinationUpdate(token: token),
                                                                                                title: "Список прививок",
                                                                                                gradient: [.paleOliveGreen, .beige]
                                                                                        )
                                                                                )}
                                                                        )
                                                                )}

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
                                                                                ViewController(presentation: MedicalTestEditingPresentation())
                                                                            }))
                                                                }
                                                        ),
                                                        MedCardOptionFrom(
                                                                name: "Хронические заболевания",
                                                                image: ObservableImageFrom(
                                                                        image: #imageLiteral(resourceName: "rocketMedDarkBlue")
                                                                ),
                                                                gradientColors: [.pastelBlue, .powderBlue],
                                                                leadingTo: { ViewController(
                                                                        presentation: MyBadHabitsPresentation(
                                                                                badHabits: MyObservableDiseasesFromAPI(token: token),
                                                                                title: "Хронические заболевания",
                                                                                gradient: [.pastelBlue, .powderBlue],
                                                                                leadingTo: { return ViewController(
                                                                                        presentation: AllBadHabitsPresentation(
                                                                                                badHabits: AllObservableDiseasesFromAPI(token: token),
                                                                                                update: DiseasesUpdate(token: token),
                                                                                                title: "Список заболеваний",
                                                                                                gradient: [.pastelBlue, .powderBlue]
                                                                                        )
                                                                                )}
                                                                        )
                                                                )}

                                                        ),
                                                        MedCardOptionFrom(
                                                                name: "Консультации",
                                                                image: ObservableImageFrom(
                                                                        image: #imageLiteral(resourceName: "rocketMedViolet")
                                                                ),
                                                                gradientColors: [.lightPeriwinkle, .softPink],
                                                                leadingTo: {
                                                                    ViewController(presentation: DDNListPresentation(
                                                                            items: SimpleMyConsultations(),
                                                                            title: "Консультации",
                                                                            gradient: [.lightPeriwinkle, .softPink],
                                                                            leadingTo: {
                                                                                ViewController(presentation: SimpleViewWthButtonPresentation())
                                                                            }))
                                                                }
                                                        )
                                                    ]
                                            )
                                    ).withTabBarStub())
                    ).withoutNavigationBar()
                })))
        ).withoutNavigationBar()
        window?.makeKeyAndVisible()
        return true
    }

    //swiftlint:enable function_body_length

}
