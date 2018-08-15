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

        let navContgroller = UINavigationController(
            rootViewController:
            ViewController(presentation: SimpleLoginPresentation(authority: AuthorityFromAPI(), leadingTo: { token in
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
                                                            badHabits: ObservableSimpleMyBadHabits(),//(try? ObservableMyBadHabitsFromAPI(token: token)) ?? SimpleObservableBadHabits(),
                                                            leadingTo: { return ViewController(
                                                                    presentation: AllBadHabitsPresentation(
                                                                            badHabits: (try? ObservableBadHabitsFromAPI(token: token)) ?? SimpleObservableBadHabits(),
                                                                            update: MyBadHabitsUpdate(token: token)
                                                                    )
                                                            )}
                                                    )
                                                )}
                                    ),
                                    InactiveMedCardOptionFrom(
                                            name: "Аллергии",
                                            image: ObservableImageFrom(
                                                    image: #imageLiteral(resourceName: "rocketMedYellow")
                                            ),
                                            gradientColors: [.peach, .wheat]

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
            }))

        )
//        navContgroller.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = navContgroller
        window?.makeKeyAndVisible()
        return true
    }

}
