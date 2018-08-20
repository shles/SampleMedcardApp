//
//  UITextField.swift
//  DiscountMarket
//
//  Created by Артмеий Шлесберг on 01/07/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

extension UITextField {
    func with(placeholder: String?) -> Self {
        self.placeholder = placeholder
        return self
    }

    func with(textAlignment alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }

    func with(font: UIFont) -> Self {
        self.font = font
        return self
    }

    func with(keyboard: UIKeyboardType) -> Self {
        self.keyboardType = keyboard
        return self
    }

    func with(next responder: UIResponder?, disposeBag: DisposeBag) -> Self {
        self.rx.methodInvoked(#selector(UITextField.resignFirstResponder)).subscribe(onNext: { _ in
            responder?.becomeFirstResponder()
        })
        .disposed(by: disposeBag)
        return self
    }

    func with(resignOn controlEvent: UIControlEvents, disposeBag: DisposeBag) -> Self {
        self.rx.controlEvent(controlEvent).subscribe(onNext: { [unowned self] _ in
            self.resignFirstResponder()
        }).disposed(by: disposeBag)
        return self
    }
    func with(texColor: UIColor) -> Self {
        self.textColor = texColor
        return self
    }

    /// Should be called after setting placeholder test
    func with(placeholderColor: UIColor) -> Self {

        if let attrPlaceholder = attributedPlaceholder {
            var attributes = attrPlaceholder.attributes(at: 0, effectiveRange: nil)

            attributes[.foregroundColor] = placeholderColor
            self.attributedPlaceholder = NSAttributedString(
                    string: attrPlaceholder.string,
                    attributes: attributes
            )
        } else if let placeholder = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(
                    string: placeholder,
                    attributes: [.foregroundColor: placeholderColor])
        }

        return self
    }

    /// Should be called after setting placeholder test
    func with(placeholderFont: UIFont) -> Self {

        if let attrPlaceholder = attributedPlaceholder {
            var attributes = attrPlaceholder.attributes(at: 0, effectiveRange: nil)

            attributes[.font] = placeholderFont
            self.attributedPlaceholder = NSAttributedString(
                    string: attrPlaceholder.string,
                    attributes: attributes
            )
        } else if let placeholder = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(
                    string: placeholder,
                    attributes: [.font: placeholderFont])
        }

        return self
    }
}
