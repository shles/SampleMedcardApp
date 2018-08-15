//
// Created by Артмеий Шлесберг on 15/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit

class ErrorAlertTransition: Transition {

    private var error: Error

    init(error: Error) {
        self.error = error
    }

    func perform(on viewController: UIViewController) {
        let alertController = UIAlertController(
                title: "Ошибка",
                message: error.localizedDescription,
                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default)

        alertController.addAction(okAction)

        viewController.present(alertController, animated: true, completion: nil)
    }
}
