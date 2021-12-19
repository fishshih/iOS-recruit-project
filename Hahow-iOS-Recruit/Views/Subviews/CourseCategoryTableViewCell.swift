// 
//  CourseCategoryTableViewCell.swift
//  Hahow-iOS-Recruit
//
//  Created by Fish Shih on 2021/12/19.
//

import UIKit
import RxSwift
import RxCocoa

class CourseCategoryTableViewCell: UITableViewCell {

    struct Config {

        struct WideConfig {
            /// 可顯示的最大數量
            var maxNumberOfDisplay: Int
        }

        struct SlimConfig {

            /// 需強調的元件 index
            var highlightedIndexes: [Int]

            /// 可顯示的最大數量
            var maxNumberOfDisplay: Int
        }

        var wideConfig: WideConfig
        var slimConfig: SlimConfig
    }

    // MARK: - Property

    let config = BehaviorRelay<Config>(
        value: .init(
            wideConfig: .init(maxNumberOfDisplay: 4),
            slimConfig: .init(highlightedIndexes: [0], maxNumberOfDisplay: 3)
        )
    )

    let style = BehaviorRelay<LayoutStyle>(value: .slim)

    let categoryItem = BehaviorRelay<CategoryItem?>(value: nil)

    var reuseDisposeBag = DisposeBag()

    // MARK: - Life cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()

        bind()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = .init()
    }

    // MARK: - Private property

    private let titleLabel = UILabel() --> {
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .black
    }

    private let mainStackView = UIStackView() --> {
        $0.axis = .vertical
    }

    private var sectionStackViews = [UIStackView]()
    private var itemViews = [CourseItemView]()

    private let padding = BehaviorRelay<CGFloat>(value: 18)
    private let stackViewSpacing = BehaviorRelay<CGFloat>(value: 18)

    private let disposeBag = DisposeBag()
}

// MARK: - UI configure

private extension CourseCategoryTableViewCell {

    func setupUI() {
        selectionStyle = .none
        configureTitleLabel()
        configureMainStackView()
    }

    func configureTitleLabel() {

        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(padding.value)
            $0.trailing.lessThanOrEqualTo(-padding.value)
            $0.height.equalTo(34)
        }
    }

    func configureMainStackView() {

        contentView.addSubview(mainStackView)

        mainStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalTo(titleLabel)
            $0.bottom.equalTo(-18).priority(.high)
        }
    }
}

// MARK: - Private func

private extension CourseCategoryTableViewCell {

    /// 嘗試取得已建立的 CourseItemView 並對其設置資料
    /// 若無法取得，則建立新的 CourseItemView
    func makeOfSetupCourseItemView(by index: Int, courseItem: Course) {

        let itemView: CourseItemView

        if let view = itemViews[safe: index] {

            // 若有足夠的 CourseItemViews，則直接取出
            itemView = view

        } else {

            // 若 CourseItemViews 不足，則建立新的

            itemView = .init()
            itemViews.append(itemView)

            // 取得存放的 sectionStackView
            //（每個 sectionStackView 放置兩個 CourseItemView）
            // 若不足則新增

            let sectionIndex = index / 2

            if let stackView = sectionStackViews[safe: sectionIndex] {
                stackView.addArrangedSubview(itemView)
            } else {
                let stackView = UIStackView()
                stackView.spacing = stackViewSpacing.value
                sectionStackViews.append(stackView)
                mainStackView.addArrangedSubview(stackView)
                stackView.addArrangedSubview(itemView)
            }
        }

        // 設定資料

        itemView.set(
            imageUrl: courseItem.coverImageURL,
            title: courseItem.title,
            name: courseItem.name
        )

        itemView.isHidden = false
    }

    /// 透過參數設置所有 CourseItemView
    func setupItemViews(by allCourses: [Course], config: Config, style: LayoutStyle) {

        var maxNumberOfDisplay: Int {
            switch style {
            case .wide:
                return config.wideConfig.maxNumberOfDisplay
            case .slim:
                return config.slimConfig.maxNumberOfDisplay
            }
        }

        // 取得需要顯示的課程資料
        let courses = allCourses[0 ..< min(allCourses.endIndex, maxNumberOfDisplay)]

        // 依照課程資料處理 CourseItemView
        for (index, courseItem) in courses.enumerated() {
            makeOfSetupCourseItemView(by: index, courseItem: courseItem)
        }

        // 隱藏未顯示的元件
        if courses.count < self.itemViews.count {
            itemViews[courses.count ..< self.itemViews.count].forEach {
                $0.isHidden = true
            }
        }

        // 依 style 調整 sectionStackViews 中所有 StackView
        sectionStackViews.forEach {
            $0.axis = style == .wide ? .horizontal : .vertical
            $0.distribution = style == .slim ? .fill : .fillEqually
        }

        // 依照 style 調整所有 CourseItemView 的 style
        switch style {
        case .wide:
            self.itemViews.forEach {
                $0.style.accept(.small)
            }
        case .slim:
            self.itemViews.enumerated().forEach {
                $1.style.accept(config.slimConfig.highlightedIndexes.contains($0) ? .large : .small)
            }
        }
    }
}

// MARK: - Binding

private extension CourseCategoryTableViewCell {

    func bind() {

        let categoryItem = self.categoryItem
            .compactMap { $0 }

        // 設定標題
        categoryItem
            .map(\.category.title)
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        // 當 config 、 style 、 categoryItem 之一變動時
        // 觸發設定所有 CourseItemView 事件
        Observable
            .combineLatest(
                self.config,
                style.distinctUntilChanged(),
                categoryItem
            )
            .subscribe(onNext: {
                [weak self] config, style, item in
                // 設置所有 CourseItemView
                self?.setupItemViews(
                    by: item.courses,
                    config: config,
                    style: style
                )
            })
            .disposed(by: disposeBag)

        // 依照 style 調整部分元件間距
        style
            .map {
                switch $0 {
                case .wide:
                    return 22
                case .slim:
                    return 18
                }
            }
            .bind(to: padding, stackViewSpacing)
            .disposed(by: disposeBag)

        // padding & stackViewSpacing 異動事件

        padding
            .subscribe(onNext: {
                [weak titleLabel] padding in
                titleLabel?.snp.updateConstraints {
                    $0.leading.equalTo(padding)
                    $0.trailing.lessThanOrEqualTo(-padding)
                }
            })
            .disposed(by: disposeBag)

        stackViewSpacing
            .subscribe(onNext: {
                [weak self] spacing in
                self?.mainStackView.spacing = spacing
                self?.sectionStackViews.forEach {
                    $0.spacing = spacing
                }
            })
            .disposed(by: disposeBag)
    }
}
