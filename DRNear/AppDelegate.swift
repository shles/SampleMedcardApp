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
        window?.rootViewController = UINavigationController(
                rootViewController: ViewController(
                        presentation: MedCardCollectionViewPresentation(
                                medCardOptions: SimpleObservableMedCardOptions()
                        )
                )
        )

        window?.makeKeyAndVisible()
        return true
    }

}
