//
//  RegisterViewController.swift
//  MoyaRxSwiftLearn
//
//  Created by brooks on 2018/3/1.
//  Copyright © 2018年 brooks. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var usernameText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var passwordCheckText: UITextField!
    

    @IBOutlet weak var usernameTips: UILabel!

    @IBOutlet weak var passwordTips: UILabel!
 
    @IBOutlet weak var passwordCheckTips: UILabel!

    @IBOutlet weak var creatAccountButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(RegisterViewController.self)", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 导航栏
        self.navigationController?.isNavigationBarHidden = false
        self.title = "注册"
        
        let viewModel = RegisterViewModel()
        usernameText.rx.text.orEmpty
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)
        
        viewModel.usernameUsable
            .bind(to: usernameTips.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.usernameUsable
            .bind(to: passwordText.rx.inputEnabled)
            .disposed(by: disposeBag)
        
        
        passwordText.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        passwordCheckText.rx.text.orEmpty
            .bind(to: viewModel.repeatPassword)
            .disposed(by: disposeBag)
        
        viewModel.passwordUsable
            .bind(to: passwordTips.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.passwordUsable
            .bind(to: passwordCheckText.rx.inputEnabled)
            .disposed(by: disposeBag)
        viewModel.repeatPasswordUsable
            .bind(to: passwordCheckTips.rx.validationResult)
            .disposed(by: disposeBag)
        
        // 注册按钮点击响应事件绑定
        creatAccountButton.rx.tap
            .bind(to: viewModel.registerTaps)
            .disposed(by: disposeBag)
        
        viewModel.registerButtonEnabled
            .subscribe(onNext: { [unowned self] valid in
                self.creatAccountButton.isEnabled = valid
                self.creatAccountButton.alpha = valid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
        viewModel.registerResult
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .ok:
                    self.navigationController?.popViewController(animated: true)
                    self.passwordCheckText.resignFirstResponder()
                case .empty:
                    self.showAlert(message: "")
                case let .failed(message):
                    self.showAlert(message: message)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func showAlert(message: String) {
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertViewController.addAction(action)
        present(alertViewController, animated: true, completion: nil)
    }
    
}

