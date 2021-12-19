// 
//  ViewController.swift
//  Hahow-iOS-Recruit
//
//  Created by Fish Shih on 2021/12/19.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

enum LayoutStyle {
    case wide
    case slim
}

class ViewController: UIViewController {

    // MARK: - Property

    var viewModel: ViewModelPrototype?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        guard let viewModel = viewModel else { return }

        bind(viewModel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 裝置翻轉、分割畫面調整，將觸發此處

        // 取得當前 window 寬度，以供後續應用
        guard let width = view.window?.bounds.width else { return }

        // CourseItemView.minImageWidth x 4 為調整畫面界線
        // 因 CourseItemView.minImageWidth 為 small 佈局的課程圖片寬度
        // 若當前畫面小於 CourseItemView.minImageWidth x 4
        // 則表示文字內容寬度將小於圖片寬度
        // 畫面佈局將不宜閱讀，故以此為判斷依據

        let mediumWidht = CourseItemView.minImageWidth * 4

        switch width {
        case mediumWidht ... .greatestFiniteMagnitude:
            style.accept(.wide)
        default:
            style.accept(.slim)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadSections(.init(integer: 0), with: .automatic)
            self.tableView.layoutIfNeeded()
        }
    }

    // MARK: - Private property

    private let style = BehaviorRelay<LayoutStyle>(value: .slim)

    private var dataModel: CoursesDataModel? {
        didSet {
            tableView.reloadData()
        }
    }

    private let tableView = UITableView() --> {
        $0.register(CourseCategoryTableViewCell.self)
        $0.separatorStyle = .none
    }

    private let disposeBag = DisposeBag()
}

// MARK: - UI configure

private extension ViewController {

    func setupUI() {

        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Binding

private extension ViewController {

    func bind(_ viewModel: ViewModelPrototype) {

        viewModel
            .output
            .coursesData
            .subscribe(onNext: {
                [weak self] in
                self?.dataModel = $0
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataModel?.data.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = CourseCategoryTableViewCell.use(table: tableView, for: indexPath)
        let course = dataModel?.data[indexPath.row]

        cell.categoryItem.accept(course)

        style
            .bind(to: cell.style)
            .disposed(by: cell.reuseDisposeBag)
        
        return cell
    }
}
