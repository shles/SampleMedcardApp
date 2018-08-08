//
// Created by Артмеий Шлесберг on 16/06/2017.
// Copyright (c) 2017 Jufy. All rights reserved.
//

import UIKit

extension UIView {

    func addSubviews(_ views: [UIView] ) {
        for view in views {
            addSubview(view)
        }
    }

    func with(contentMode: UIViewContentMode) -> Self {
        self.contentMode = contentMode
        return self
    }

    func with(clipsToBounds: Bool) -> Self {
        self.clipsToBounds = clipsToBounds
        return self
    }

    func with(roundedEdges radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        return self.with(clipsToBounds: true)
    }

    func with(backgroundColor: UIColor) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }

    @discardableResult
    func withShadow(
        xOffset: CGFloat = 0,
        yOffset: CGFloat = 2,
        radius: CGFloat = 2,
        opacity: Float = 1,
        shadowColor: UIColor = UIColor.black
    ) -> Self {
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize(width: xOffset, height: yOffset)
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        return self
    }

    func with(borderWidth: CGFloat, borderColor: UIColor) -> Self {
        (self.layer as CALayer).borderWidth = borderWidth
        (self.layer as CALayer).borderColor = borderColor.cgColor
        return self
    }

}
