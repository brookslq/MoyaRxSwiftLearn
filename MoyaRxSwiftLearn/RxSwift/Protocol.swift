//
//  Protocol.swift
//  MoyaRxSwiftLearn
//
//  Created by brooks on 2018/2/26.
//  Copyright © 2018年 brooks. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

// 表示我们的一些请求的结果
enum MResult {
    case ok(message: String)
    case empty
    case failed(message: String)
}

extension MResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

extension MResult {
    var textColor: UIColor {
        switch self {
        case .ok:
            return UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue:  109.0 / 255.0, alpha: 1.0)
        case .empty:
            return UIColor.black
        case .failed:
            return UIColor.red
        }
    }
}

extension MResult {
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case let .failed(message):
            return message
        }
    }
}

// 自定义
extension Reactive where Base: UILabel {
    var validationResult: Binder<MResult> {
        return Binder(self.base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}

extension Reactive where Base: UITextField {
    var inputEnabled: Binder<MResult> {
        return Binder(self.base) { textField, result in
            textField.isEnabled = result.isValid
        }
    }
}










