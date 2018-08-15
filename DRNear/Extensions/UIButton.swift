//
// Created by Timofey on 6/28/17.
// Copyright (c) 2017 Jufy. All rights reserved.
//

import UIKit

extension UIButton {

    func with(image: UIImage, for state: UIControlState = .normal) -> Self {
        self.setImage(image, for: state)
        return self
    }

    func with(title: String?, for state: UIControlState = .normal) -> Self {
        self.setTitle(title, for: state)
        return self
    }

    func with(titleColor: UIColor?, for state: UIControlState = .normal) -> Self {
        self.setTitleColor(titleColor, for: state)
        return self
    }

}
