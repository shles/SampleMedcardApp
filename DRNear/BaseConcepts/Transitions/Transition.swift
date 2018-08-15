//
// Created by Артмеий Шлесберг on 12/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit

protocol Transition {

    func perform(on viewController: UIViewController)

}

class PushTransition: Transition {

    private let leadingTo: () -> (UIViewController)

    init(leadingTo: @escaping () -> (UIViewController)) {
        self.leadingTo = leadingTo
    }

    func perform(on viewController: UIViewController) {
        viewController.navigationController?.pushViewController(leadingTo(), animated: true)
    }

}

class PresentTransition: Transition {

    private let leadingTo: () -> (UIViewController)

    init(leadingTo: @escaping () -> (UIViewController)) {
        self.leadingTo = leadingTo
    }

    func perform(on viewController: UIViewController) {
        viewController.present(leadingTo(), animated: true)
    }

}

class PopTransition: Transition {

    func perform(on viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }

}

class DismissTransition: Transition {

    func perform(on viewController: UIViewController) {
        viewController.dismiss(animated: true)
    }

}


class NewWindowRootControllerTransition: Transition {
    private let leadingTo: () -> (UIViewController)

    init(leadingTo: @escaping () -> (UIViewController)) {
        self.leadingTo = leadingTo
    }

    func perform(on viewController: UIViewController) {

        let vc = leadingTo()

        viewController.present(vc, animated: true) {
            UIApplication.shared.keyWindow?.rootViewController = vc
        }

    }
}
