// 
//  CourseItemView.swift
//  Hahow-iOS-Recruit
//
//  Created by Fish Shih on 2021/12/19.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher

class CourseItemView: UIView {

    /// 課程元件之佈局風格
    enum Style {
        case large
        case small
    }

    // MARK: - Property

    static let minImageWidth = CGFloat(128)

    /// 透過 Style 控制單一課程元件的佈局
    let style = BehaviorRelay<Style>(value: .small)

    // MARK: - Life cycle

    init() {
        super.init(frame: .zero)

        setupUI()

        bind()
    }

    required init?(coder: NSCoder) {
        super.init(frame: .zero)

        setupUI()

        bind()
    }

    // MARK: - Private property

    private let objectStackView = UIStackView() --> {
        $0.spacing = 12
    }

    private let labelStackView = UIStackView() --> {
        $0.axis = .vertical
        $0.spacing = 8
    }

    private let imageView = UIImageView() --> {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }

    private let titleLabel = UILabel() --> {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .black
        $0.numberOfLines = 2
    }

    private let nameLabel = UILabel() --> {
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = .gray
        $0.numberOfLines = 1
    }

    private var imageViewWidthConstraint: Constraint?

    private let disposeBag = DisposeBag()
}

// MARK: - UI configure

private extension CourseItemView {

    func setupUI() {
        configureObjectStackView()
        configureImageView()
        configureLabelStackView()
        configureLabels()
    }

    func configureObjectStackView() {

        addSubview(objectStackView)

        objectStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configureImageView() {

        objectStackView.addArrangedSubview(imageView)

        imageView.snp.makeConstraints {
            $0.width.equalTo(imageView.snp.height).multipliedBy(1.75)
            // 對 imageView 多增加一條約束，以方便佈置兩種 style
            imageViewWidthConstraint = $0.width.equalTo(Self.minImageWidth).constraint
        }
    }

    func configureLabelStackView() {

        // labelStackView 將放置於 objectStackView 中
        // 因 objectStackView 可能為 水平 也可能為 垂直，
        // 使用一個容器概念的 view 去放置 labelStackView
        // 可以減少兩個 stackView 的互相影響 

        let containerView = UIView()

        objectStackView.addArrangedSubview(containerView)
        containerView.addSubview(labelStackView)

        labelStackView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.bottom.lessThanOrEqualToSuperview()
        }
    }

    func configureLabels() {
        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(nameLabel)
    }
}

// MARK: - Private func

private extension CourseItemView {

    func layoutImageView(by style: Style) {

        // 若為 large style，取消 imageView 的寬的約束，並將 objectStackView axis 改為垂直
        // 若為 small style，則啟用 imageView 寬度約束，將 objectStackVeiw axis 改為水平
        // 由 viewController 決定應該採用何種 style 佈局
        // 元件內僅提供可調整設定

        switch style {
        case .large:

            // 解除 imageView 寬度約束
            // imageView 寬度將依照 stackView 設定
            imageViewWidthConstraint?.deactivate()

            // 調整 objectStackView.axis 為 垂直，以符合 large 佈局
            objectStackView.axis = .vertical

        case .small:

            // 啟用 imageView 寬度約束
            // imageView 將被限制寬度，調整為小圖
            imageViewWidthConstraint?.activate()

            // 調整 objectStackView.axis 為 水平，以符合 small 佈局
            objectStackView.axis = .horizontal
        }
    }
}

// MARK: - Public func

extension CourseItemView {

    func set(imageUrl: String, title: String, name: String) {

        if let url = URL(string: imageUrl) {
            imageView.kf.setImage(with: .network(url))
        }

        titleLabel.text = title
        nameLabel.text = name
    }
}

// MARK: - Binding

private extension CourseItemView {

    func bind() {

        style
            .subscribe(onNext: {
                [weak self] style in
                self?.layoutImageView(by: style)
            })
            .disposed(by: disposeBag)
    }
}
