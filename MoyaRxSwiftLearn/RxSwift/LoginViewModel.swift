//
//  LoginViewModel.swift
//  MoyaRxSwiftLearn
//
//  Created by brooks on 2018/2/27.
//  Copyright © 2018年 brooks. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class LoginViewModel {
    
    // output
    let usernameUsable: Driver<MResult>
    let loginButtonEnabled: Driver<Bool>
    let loginResult: Driver<MResult>
    
    init(input: (username: Driver<String>, password: Driver<String>, loginTaps: Driver<Void>),
         service: ValidationService) {
        usernameUsable = input.username
            .flatMapLatest{ username in
                return service.loginUsernameValid(username)
                    .asDriver(onErrorJustReturn: .failed(message: "连接server失败"))
        }
        let usernameAndPassword = Driver.combineLatest(input.username, input.password) {
            ($0, $1)
        }
        
        loginResult = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest{(username, password) in
                return service.login(username, password: password)
                    .asDriver(onErrorJustReturn: .failed(message: "连接server失败"))
        }
        
        loginButtonEnabled = input.password
            .map{ $0.count > 0 }
            .asDriver()
        
    }
    
    
}
