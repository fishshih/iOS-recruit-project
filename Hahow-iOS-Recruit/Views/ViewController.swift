// 
//  ViewController.swift
//  Hahow-iOS-Recruit
//
//  Created by Fish Shih on 2021/12/19.
//

import UIKit
import RxSwift
import RxCocoa

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

    // MARK: - Private property

    private let disposeBag = DisposeBag()
}

// MARK: - UI configure

private extension ViewController {

    func setupUI() {

    }
}

// MARK: - Private func

private extension ViewController {

}

// MARK: - Binding

private extension ViewController {

    func bind(_ viewModel: ViewModelPrototype) {

    }
}
