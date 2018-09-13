//
// Created by Артмеий Шлесберг on 04/09/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import UIKit

class DatePickerTextField: UITextField {

    var datePicker: UIDatePicker!

    var data: [String] = []
    var pickerInput: UIPickerView!
    var onSelectIndex: ((Int) -> Void)?

    init() {
        super.init(frame: .zero)
        configureInputs()
    }

    func configureInputs() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        self.inputView = datePicker

        addToolBar()
    }

    @objc func donePikerView() {
        let date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        self.text = dateFormatter.string(from: date)

        if delegate != nil {
            _ = self.delegate?.textFieldShouldReturn!(self)
        }

    }

    @objc func cancelPikerView() {
        self.endEditing(true)
    }

    func addToolBar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.white
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Ок", style: .done, target: self, action: #selector(donePikerView))
        doneButton.tintColor = UIColor.black
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let cancelButton = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelPikerView))
        cancelButton.tintColor = UIColor.black
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)

        self.inputAccessoryView = toolBar
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are deprecated")
    }
}
