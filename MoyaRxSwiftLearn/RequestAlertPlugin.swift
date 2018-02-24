//
//  RequestAlertPlugin.swift
//  MoyaRxSwiftLearn
//
//  Created by brooks on 2018/2/23.
//  Copyright © 2018年 brooks. All rights reserved.
//

import UIKit
import Moya
import Result

final class RequestAlertPlugin: PluginType {
    
    // 当前的视图控制器
    private let viewController: UIViewController
    // 活动状态指示器 （菊花）
    private var spinner: UIActivityIndicatorView!
    
    // 插件初始化的时候传入当前的视图控制器
    init(viewController: UIViewController) {
        self.viewController = viewController
        // 初始化活动状态指示器
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.spinner.center = self.viewController.view.center
    }
    
    // 开始发起请求
    func willSend(_ request: RequestType, target: TargetType) {
        // 请求时在界面中央显示一个活动状态指示器
        viewController.view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    // 收到请求
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        // 移除界面中央的活动状态指示器
        spinner.removeFromSuperview()
        spinner.stopAnimating()
        
        // 只有请求错误时会继续往下执行
        guard case let Result.failure(error) = result else {return}
        
        // 弹出并显示错误信息
        let message = error.errorDescription ?? "未知错误"
        let alertViewController = UIAlertController(title: "请求失败",
                                                    message: "\(message)",
            preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "确定", style: .default,
                                                    handler: nil))
        viewController.present(alertViewController, animated: true)
    }
    
}
