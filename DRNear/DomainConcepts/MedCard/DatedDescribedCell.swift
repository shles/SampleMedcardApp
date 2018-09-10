//
// Created by Артмеий Шлесберг on 16/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import SnapKit
import UIKit

class DatedDescribedCell: UITableViewCell {

    private var dateLabel = UILabel()
    .with(numberOfLines: 3)
    .aligned(by: .center)
    .with(textColor: .mainText)
    private var systemEventIndicator = RoundIndicatorView()
    private var nameLabel = UILabel()
        .with(numberOfLines: 2)
    .with(font: .medCardCell)
    .with(textColor: .mainText)

    private var descriptionLabel = UILabel()
    .with(numberOfLines: 2)
    .with(font: .subtitleText13)
    .with(textColor: .blueGrey)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let separatorView = UIView()
            .with(backgroundColor: .shadow)

        addSubviews([dateLabel, separatorView, systemEventIndicator, nameLabel, descriptionLabel])

        separatorView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(124)
            $0.width.equalTo(1)
            $0.leading.equalToSuperview().offset(84)
        }

        dateLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.width.equalTo(68)
        }

        nameLabel.snp.makeConstraints {
            $0.bottom.equalTo(dateLabel.snp.centerY).inset(4)
            $0.leading.equalTo(separatorView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.centerY).inset(4)
            $0.leading.equalTo(separatorView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }

        systemEventIndicator.snp.makeConstraints {
            $0.center.equalTo(separatorView)
            $0.width.height.equalTo(10)
        }

    }

    func configured(item: Named & Dated & Described & SystemRelated) -> DatedDescribedCell {

        nameLabel.text = item.name

        let formatter = DateFormatter()

        formatter.dateFormat = "dd MMMM yyyy"

        let attrString = NSMutableAttributedString(
                string: formatter.string(from: item.date),
                attributes: [NSAttributedStringKey.font: UIFont.navigatoinLarge])

        attrString.addAttribute(NSAttributedStringKey.font,
                value: UIFont.subtitleText13,
                range: NSRange(location: 2, length: attrString.string.count - 6))

        dateLabel.attributedText = attrString

        systemEventIndicator.configure(activated: item.isRelatedToSystem)

        descriptionLabel.text = item.description

        return self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class RoundIndicatorView: UIView {

    private var activated: Bool {
        didSet {
            layer.borderColor = activated ? UIColor.lightTeal.cgColor : UIColor.mainText.cgColor
        }
    }

    init(activated: Bool = false) {
        self.activated = activated
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.layer.borderWidth = 2
        self.clipsToBounds = true
    }

    override func layoutSubviews() {
        self.layer.cornerRadius = frame.width / 2.0
    }

    func configure(activated: Bool) {
        self.activated = activated
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
