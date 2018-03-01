//
//  RxSwiftViewController.swift
//  MoyaRxSwiftLearn
//
//  Created by brooks on 2018/2/26.
//  Copyright © 2018年 brooks. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RxSwiftLoginViewController: UIViewController {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
 
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!

    
    let disposeBag = DisposeBag()
    let moyaVC = MoyaViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let viewModel = LoginViewModel(input: (username: usernameText.rx.text.orEmpty.asDriver(),
                                               password: passwordText.rx.text.orEmpty.asDriver(),
                                               loginTaps: LoginButton.rx.tap.asDriver()),
                                       service: ValidationService.instance)
        
        viewModel.usernameUsable
            .drive(usernameLabel.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.loginButtonEnabled
            .drive(onNext: { [unowned self] valid in
                self.LoginButton.isEnabled = valid
                self.LoginButton.alpha = valid ? 1 : 0.5
            })
            .disposed(by: disposeBag)
        
        viewModel.loginResult
            .drive(onNext: { [unowned self] result in
                switch result {
                case .ok:
                    // 界面跳转
                    self.navigationController?.pushViewController(self.moyaVC, animated: true)
                case .empty:
                    self.showAlert(message: "")
                case let .failed(message):
                    self.showAlert(message: message)
                }
            })
        
        registerButton.rx.tap
            .subscribe(onNext: {
                let registerVC = RegisterViewController()
                self.navigationController?.pushViewController(registerVC, animated: true)
            })
            .disposed(by: disposeBag)

        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        // 隐藏导航栏
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func showAlert(message: String) {
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertViewController.addAction(action)
        present(alertViewController, animated: true, completion: nil)
    }
    
}
