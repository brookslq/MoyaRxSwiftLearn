//
//  Service.swift
//  MoyaRxSwiftLearn
//
//  Created by brooks on 2018/2/26.
//  Copyright © 2018年 brooks. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ValidationService {
    
    static let instance = ValidationService()
    private init() {}
    
    // MARK: - 注册部分
    
    let usernameMinCharacters = 2
    let passwordMinCharacters = 6
    
    // 此处返回一个Observab对象，这个请求过程需要被监听
    func validateUsername(_ username: String) -> Observable<MResult> {
        if username.count == 0 {
            return .just(.empty) // 字符等于0时，啥也不做
        }
        if username.count < usernameMinCharacters {
            return .just(.failed(message: "号码长度至少2个字符"))
        }
        if usernameValid(username) {
            return .just(.failed(message: "账户已存在"))
        }
        return .just(.ok(message: "用户名可用"))
    }
    
    // 验证password
    func validatePassword(_ password: String) -> MResult {
        if password.count == 0 {
            return .empty
        }
        if password.count < passwordMinCharacters {
            return .failed(message: "密码长度至少6个字符")
        }
        return .ok(message: "密码可用")
    }
    
    // 再次检查密码
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> MResult {
        if repeatedPassword.count == 0 {
            return .empty
        }
        if repeatedPassword == password {
            return .ok(message: "密码一致")
        }
        return .failed(message: "两次密码不一样")
    }
    
    
    // 注册保存用户名
    func register(_ username: String, password: String) -> Observable<MResult> {
        let userDic = [username: password]
        let filePath = NSHomeDirectory() + "/Documents/users.plist"
        if (userDic as NSDictionary).write(toFile: filePath, atomically: true){
            return .just(.ok(message: "注册成功"))
        }
        return .just(.failed(message: "注册失败"))
        
    }
    
    // 从本地数据库中检测用户名是否已经存在
    func usernameValid(_ username: String) -> Bool {
        let filePath = NSHomeDirectory() + "/Documents/users.plist"
        let userDic = NSDictionary(contentsOfFile: filePath)
        let usernameArray = userDic?.allKeys
        guard usernameArray != nil else {
            return false
        }
        
        if (usernameArray! as NSArray).contains(username ) {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - 登录部分
    func loginUsernameValid(_ username: String) -> Observable<MResult> {
        if username.count == 0 {
            return .just(.empty)
        }
        if usernameValid(username) {
            return .just(.ok(message: "用户名可用"))
        }
        return .just(.failed(message: "用户名不存在"))
    }
    
    func login(_ username: String, password: String) -> Observable<MResult> {
        let filePath = NSHomeDirectory() + "/Documents/users.plist"
        let userDic = NSDictionary(contentsOfFile: filePath)
        if let userPass = userDic?.object(forKey: username) as? String {
            if  userPass == password {
                return .just(.ok(message: "登录成功"))
            }
        }
        return .just(.failed(message: "密码错误"))
    }
    
}
