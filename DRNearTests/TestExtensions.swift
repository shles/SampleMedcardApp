//
// Created by Ар?тмеий Шлесберг on 07/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

extension NavigationBarWithBackButton {
    func simulateBackTap() {
        self.subviews.first { $0 is UIButton }.flatMap { $0 as? UIButton }?
        .sendActions(for: .touchUpInside)
    }
}

extension BadHabitsTableViewPresentation {
    func simulateBackTap() {
        self.view.subviews
                .first { $0 is NavigationBarWithBackButton }
                .flatMap { $0 as? NavigationBarWithBackButton }?
            .simulateBackTap()
    }
}

extension SimpleViewWthButtonPresentation {
    func simulateButtonTap() {
        self.view.subviews.first { $0 is UIButton }.flatMap { $0 as? UIButton }?
                .sendActions(for: .touchUpInside)
    }
}

extension UIViewController {
    func preloadView() {
        _ = self.view
    }
}
