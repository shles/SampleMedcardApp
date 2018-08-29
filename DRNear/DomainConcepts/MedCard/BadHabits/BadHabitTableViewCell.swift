//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

class SimpleTickedCell: UITableViewCell {

    private var title = UILabel()
        .with(font: .regular)
        .with(textColor: .mainText)
    private var tick = UIImageView()
        .with(image: #imageLiteral(resourceName: "tick"))
        .with(contentMode: .scaleAspectFit)
    private var subtitle = UILabel()
        .with(font: .subtitleText13)
        .with(textColor: .blueGrey)
    private var subtitleBottomConstraint: Constraint!

    private var disposeBag = DisposeBag()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubviews([title, tick, subtitle])

        title.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
        }

        tick.snp.makeConstraints {
            $0.centerY.equalTo(title)
            $0.trailing.equalToSuperview().inset(28)
            $0.leading.equalTo(title.snp.trailing)
            $0.width.equalTo(16)
            $0.height.equalTo(19)
        }

        subtitle.snp.makeConstraints {
            $0.leading.trailing.equalTo(title)
            $0.top.equalTo(title.snp.bottom).offset(4)
            self.subtitleBottomConstraint = $0.bottom.equalToSuperview().inset(10).constraint
        }

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated!")
    }

    func configured(item: Named & Selectable, tickColor: UIColor) -> Self {
        title.text = item.name
        tick.tintColor = tickColor
        item.isSelected.asObservable().subscribe(onNext: { [unowned self] in
            self.tick.isHidden = !$0
        }).disposed(by: disposeBag)

        if let subtitle = (item as? Described)?.description, subtitle != "" {
            self.subtitle.text = subtitle
        } else {
            self.subtitleBottomConstraint.update(inset: 5)
            self.subtitle.text = ""
        }

        return self
    }
}
