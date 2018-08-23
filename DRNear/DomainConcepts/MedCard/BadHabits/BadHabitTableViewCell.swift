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

    private var disposeBag = DisposeBag()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubviews([title, tick])

        title.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }

        tick.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(28)
            $0.leading.equalTo(title.snp.trailing)
            $0.width.equalTo(16)
            $0.height.equalTo(19)
            $0.top.equalToSuperview().offset(18)
            $0.bottom.equalToSuperview().inset(18)
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

        return self
    }
}
