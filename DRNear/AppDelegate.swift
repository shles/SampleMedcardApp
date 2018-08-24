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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)

        window?.rootViewController = UINavigationController(rootViewController: ViewController(
            presentation: NumberRegistrationPresentation(numberRegistration: NumberRegistrationFromAPI(leadingTo: { token in
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
                                                                            badHabits: (try? MyObservableBadHabitsFromAPI(token: token)) ?? SimpleObservableBadHabits(),
                                                                            title: "Вредные привычки",
                                                                            gradient: [.wheatTwo, .rosa],
                                                                            leadingTo: { return ViewController(
                                                                                    presentation: AllBadHabitsPresentation(
                                                                                            badHabits: (try? AllObservableBadHabitsFromAPI(token: token)) ?? SimpleObservableBadHabits(),
                                                                                            update: MyBadHabitsUpdate(token: token),
                                                                                            title: "Вредные привычки",
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
                                                            leadingTo: {
                                                                ViewController(presentation: DDNListPresentation(
                                                                        items: SimpleMyMedicalTests(),
                                                                        title: "Анализы и исследования",
                                                                        gradient: [.peach, .wheat],
                                                                        leadingTo: {
                                                                            ViewController(presentation: SimpleViewWthButtonPresentation())
                                                                        }))
                                                            }

                                                    ),
                                                    InactiveMedCardOptionFrom(
                                                            name: "Прививки",
                                                            image: ObservableImageFrom(
                                                                    image: #imageLiteral(resourceName: "rocketMedGreen")
                                                            ),
                                                            gradientColors: [.paleOliveGreen, .beige]

                                                    ),
                                                    InactiveMedCardOptionFrom(
                                                            name: "Исследования и анализы",
                                                            image: ObservableImageFrom(
                                                                    image: #imageLiteral(resourceName: "rocketMedBlue")
                                                            ),
                                                            gradientColors: [.darkSkyBlue, .tiffanyBlue]

                                                    ),
                                                    InactiveMedCardOptionFrom(
                                                            name: "Хронические заболевания",
                                                            image: ObservableImageFrom(
                                                                    image: #imageLiteral(resourceName: "rocketMedDarkBlue")
                                                            ),
                                                            gradientColors: [.pastelBlue, .powderBlue]

                                                    ),
                                                    InactiveMedCardOptionFrom(
                                                            name: "Консультации",
                                                            image: ObservableImageFrom(
                                                                    image: #imageLiteral(resourceName: "rocketMedViolet")
                                                            ),
                                                            gradientColors: [.lightPeriwinkle, .softPink]

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

}
