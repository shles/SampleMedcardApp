//
// Created by Артмеий Шлесберг on 03/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class SimpleNavigationBar: UIView {

    private var titleLabel = UILabel()
    .with(font: .navigatoinLarge)
    .with(textColor: .mainText)

    init(title: String) {
        titleLabel.text = title
        super.init(frame: .zero)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(48)
        }
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated!")
    }
}
