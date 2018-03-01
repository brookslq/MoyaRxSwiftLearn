//
//  DouBanAPI.swift
//  MoyaRxSwiftLearn
//
//  Created by brooks on 2018/2/23.
//  Copyright © 2018年 brooks. All rights reserved.
//

import Foundation
import Moya

// 初始化豆瓣FM请求的Provider
//let DouBanProvider = MoyaProvider<DouBan>()

/** 下面定义豆瓣FM请求的endpoints （供provider使用） **/

// 请求分类
public enum DouBan {
    case channels           //获取频道
    case playlist(String)   // 获取歌曲
}

// 请求配置
extension DouBan: TargetType {
    // 服务器地址
    public var baseURL: URL {
        switch self {
        case .channels:
            return URL(string: "https://www.douban.com")!
        case .playlist(_):
            return URL(string: "https://douban.fm")!
        }
    }
    
    // 各个请求的具体路径
    public var path: String {
        switch self {
        case .channels:
            return "/j/app/radio/channels"
        case .playlist(_):
            return "/j/mine/playlist"
        }
    }
    
    // 请求类型
    // Post 和 Get 方法的不同，参数传递的方式也不同。
    // Get: 参数直接拼接在 url 上，可见。
    // Post: 参数是放在 Http body 中传递，url 不可见。
    public var method: Moya.Method {
        return .get
    }
    
    // 请求任务事件
    // 如果将参数中一个值设置为 nil，那么不管是在 Get 还是 Post
    // 这个参数是不会传递的
    public var task: Task {
        switch self {
        case .playlist(let channel):
            var params: [String: Any] = [:]
            params["channel"] = channel
            params["type"] = "n"
            params["from"] = "mainsite"
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    // 是否执行Alamofire验证
    public var validate: Bool {
        return false
    }
    
    // 这个是做单元测试模拟的数据，只会在单元测试文件中有作用
    public var sampleData: Data {
        return "{}".data(using: .utf8)!
    }
    
    // 请求头
    public var headers: [String: String]? {
        return nil
    }
}


























