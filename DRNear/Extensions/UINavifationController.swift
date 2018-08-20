//
//  UINavifationController.swift
//  DRNear
//
//  Created by Артмеий Шлесберг on 12/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import UIKit

extension UINavigationController {
    func withoutNavigationBar() -> Self {
        setNavigationBarHidden(true, animated: false)
//        self.navigationBar.isHidden = true
        return self
    }
}
