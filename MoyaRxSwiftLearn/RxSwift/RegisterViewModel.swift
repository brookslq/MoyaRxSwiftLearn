//
//  RegisterViewModel.swift
//  MoyaRxSwiftLearn
//
//  Created by brooks on 2018/2/26.
//  Copyright © 2018年 brooks. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RegisterViewModel {
    // input:
    let username = Variable<String>("")
    let password = Variable<String>("")
    let repeatPassword = Variable<String>("")
    let registerTaps = PublishSubject<Void>()
    
    // output:
    let usernameUsable: Observable<MResult>     // 用户名是否可用
    let passwordUsable: Observable<MResult>     // 密码是否可用
    let repeatPasswordUsable: Observable<MResult>   // 密码是否正确
    let registerButtonEnabled: Observable<Bool>
    let registerResult: Observable<MResult>
    
    init() {
        let service = ValidationService.instance
        
        usernameUsable = username.asObservable()
            .flatMapLatest{ username in
                return service.validateUsername(username)
                .observeOn(MainScheduler.instance)
                .catchErrorJustReturn(.failed(message: "username检测出错"))
            }
            .share(replay: 1)
        
        passwordUsable = password.asObservable()
            .map{ password in
                return service.validatePassword(password)
        }
        .share(replay: 1)
        
        repeatPasswordUsable = Observable.combineLatest(password.asObservable(), repeatPassword.asObservable()) {
            return service.validateRepeatedPassword($0, repeatedPassword: $1)
        }
        .share(replay: 1)
        
        // 注册
        registerButtonEnabled = Observable.combineLatest(usernameUsable, passwordUsable, repeatPasswordUsable) {
            (username, password, repeatPassword) in
            username.isValid && password.isValid && repeatPassword.isValid
        }
        .distinctUntilChanged()
        .share(replay: 1)
        
        let usernameAndPassword = Observable.combineLatest(username.asObservable(), password.asObservable()) {
            ($0, $1)
        }
        
        registerResult = registerTaps.asObservable().withLatestFrom(usernameAndPassword)
            .flatMapLatest{ (username, password) in
                return service.register(username, password: password)
                    .observeOn(MainScheduler.instance)
                    .catchErrorJustReturn(.failed(message: "注册出错"))
        }
        .share(replay: 1)
    }
}
