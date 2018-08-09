//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import UIKit

class MedCardCollectionViewPresentation: NSObject, Presentation, UICollectionViewDelegateFlowLayout {

    var view: UIView = UIView()

    private let collectionView: UICollectionView
    private let disposeBag = DisposeBag()
    private let wantsToPushSubject = PublishSubject<UIViewController>()
    private let medCardOptions: MedCard

    private let navBar = SimpleNavigationBar(title: "Медицинская карта")
    .with(rightInactiveButton: UIButton().with(image: #imageLiteral(resourceName: "chatIcon")))

    init(medCardOptions: MedCard) {

        self.medCardOptions = medCardOptions

        let layout = UICollectionViewFlowLayout()

        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init()

        view.addSubviews([navBar, collectionView])
        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        collectionView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }

        let dataSource = RxCollectionViewSectionedReloadDataSource<StandardSectionModel<MedCardOptionApplicableToCollectionViewCell>>(
                configureCell: { _, cv, ip, option in
                    let cell = cv.dequeueReusableCellOfType(MedCardOptionCollectionViewCell.self, for: ip)
                    option.apply(target: cell)
                    return cell
                })

        self.medCardOptions.options()
            .map {
                $0.map { MedCardOptionApplicableToCollectionViewCell(origin: $0) }
            }
            .map {
                [StandardSectionModel(items: $0)]
            }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        collectionView.rx.modelSelected(MedCardOption.self)
            .subscribe(onNext: { option in
                option.interact()
            })
            .disposed(by: disposeBag)

        self.medCardOptions.options()
            .flatMap {
                Observable.merge($0.map { $0.wantsToPush().debug() })
            }
            .bind(to: wantsToPushSubject)
            .disposed(by: disposeBag)

        collectionView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        collectionView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true

    }

    func wantsToPush() -> Observable<UIViewController> {
        return wantsToPushSubject.asObservable()
    }

    func wantsToPresent() -> Observable<UIViewController> {
        return Observable<UIViewController>.never()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.0 - 16, height: 184)
    }

    func wantsToPop() -> Observable<Void> {
        return Observable<Void>.never()    }

    func wantsToBeDismissed() -> Observable<Void> {
        return Observable<Void>.never()
    }

    func willAppear() {

    }
}

extension MedCardCollectionViewPresentation {

    func withTabBarStub() -> Self {

        let tabBarImageView = UIImageView(image: #imageLiteral(resourceName: "tabBarStaub"))
                                .with(contentMode: .scaleAspectFill)
                                .with(backgroundColor: .white)

        view.addSubview(tabBarImageView)
        tabBarImageView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(67)
        }

        collectionView.snp.remakeConstraints { [unowned self] in
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.navBar.snp.bottom)
            $0.bottom.equalTo(tabBarImageView.snp.top)
        }

        return self
    }
}
