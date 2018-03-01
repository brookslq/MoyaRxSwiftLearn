//
//  ViewController.swift
//  MoyaRxSwiftLearn
//
//  Created by brooks on 2018/2/23.
//  Copyright © 2018年 brooks. All rights reserved.
//

import UIKit
import SwiftyJSON
import Moya

struct Network {
    static let provider = MoyaProvider<DouBan>()
    static func request(
        _ target: DouBan,
        success successCallback: @escaping (JSON) -> Void,
        error errorCallback: @escaping (Int) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
        ){
        provider.request(target) {result in
            switch result {
            case let .success(response):
                do {
                    //如果数据返回成功则直接将结果转为JSON
                    try response.filterSuccessfulStatusCodes()
                    let json = try JSON(response.mapJSON())
                    successCallback(json)
                }
                catch let error {
                    //如果数据获取失败，则返回错误状态码
                    errorCallback((error as! MoyaError).response!.statusCode)
                }
            case let .failure(error):
                //如果连接异常，则返沪错误信息（必要时还可以将尝试重新发起请求）
                //if target.shouldRetry {
                //    retryWhenReachable(target, successCallback, errorCallback,
                //      failureCallback)
                //}
                //else {
                failureCallback(error)
                //}
            }
        }
    }
}

class MoyaViewController: UIViewController {

    
    // 显示频道列表的tableview
    var tableView: UITableView!
    // 频道列表数据
    var channels: Array<JSON> = []
    
    override func viewWillAppear(_ animated: Bool) {
        // 从登录进来显示导航栏
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        let DouBanProvider = MoyaProvider<DouBan>(plugins: [
            RequestAlertPlugin(viewController: self)
            ])
        
        // 使用我们的Provider进行网络请求（获取频道列表数据）
        DouBanProvider.request(.channels) { result in
            switch result {
            case let .success(response):
                
                do {
                    // 过滤成功的状态码响应
                    try response.filterSuccessfulStatusCodes()
                    // 解析数据
                    let data = try? response.mapJSON()
                    let json = JSON(data!)
                    self.channels = json["channels"].arrayValue
                    
                    // 刷新表格数据
                    // 异步进行
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                catch {
                    // 处理错误状态码的响应
                }

            // switch里面可以继续 switch
            case let .failure(error):
                switch error {
                case .imageMapping(let response):
                    print("错误原因：\(error.errorDescription ?? "")")
                    print(response)
                case .jsonMapping(let response):
                    print("错误原因：\(error.errorDescription ?? "")")
                    print(response)
                case .statusCode(let response):
                    print("错误原因：\(error.errorDescription ?? "")")
                    print(response)
                case .stringMapping(let response):
                    print("错误原因：\(error.errorDescription ?? "")")
                    print(response)
                case .requestMapping:
                    print("错误原因：\(error.errorDescription ?? "")")
                    print("nil")
                case .objectMapping(_, _):
                    break
                case .encodableMapping(_):
                    break
                case .parameterEncoding(_):
                    break
                case .underlying(_, _):
                    break
                }
            }
        }
    }
    
    //显示消息
    func showAlert(title:String, message:String){
        let alertController = UIAlertController(title: title,
                                                message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

 
}

extension MoyaViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 获取选中项信息
        let channelName = channels[indexPath.row]["name"].stringValue
        let channelId = channels[indexPath.row]["channel_id"].stringValue
        
        // 使用Provider进行网络请求（根据频道ID获取下面的歌曲）
//        DouBanProvider.request(.playlist(channelId)) { result in
//            if case let .success(response) = result {
//                // 解析数据，获取歌曲信息
//                let data = try? response.mapJSON()
//                let json = JSON(data!)
//                let music = json["song"].arrayValue[0]
//                let artist = music["artist"].stringValue
//                let title = music["title"].stringValue
//                let message = "歌手：\(artist)\n歌曲：\(title)"
//
//                //将歌曲信息弹出显示
//                self.showAlert(title: channelName, message: message)
//            }
//        }
        
        Network.request(.playlist(channelId), success: { json in
            // 获取歌曲信息
            guard json["song"].arrayValue.count >= 1 else {
                return
            }
            
            let music = json["song"].arrayValue[0]
            let artist = music["artist"].stringValue
            let title = music["title"].stringValue
            let message = "歌手：\(artist)\n歌曲：\(title)"
            // 将歌曲信息弹出显示
            self.showAlert(title: channelName, message: message)
        }, error: { statusCode in
            // 服务器报错等问题
            print("请求错误！错误码：\(statusCode)")
        }, failure: { error in
            //没有网络等问题
            print("请求失败！错误信息：\(error.errorDescription ?? "")")
        })
    }
}

extension MoyaViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        // 设置单元格内容
        cell.textLabel?.text = channels[indexPath.row]["name"].stringValue
        return cell
    }
    
}



























