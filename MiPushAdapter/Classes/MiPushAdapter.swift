//
//  MiPushAdapter.swift
//  SportVideo
//
//  Created by 王小涛 on 2018/5/26.
//  Copyright © 2018年 Huaying. All rights reserved.
//

import Foundation

public protocol MiPushAdapterDelegate: class {
    func miPushAdapter(_: MiPushAdapter, didGetRegId: String)
    func miPushAdapter(_: MiPushAdapter, didReceiveNotification: MiPushAdapter.PushData)
}

public class MiPushAdapter: NSObject {
    
    public struct PushData {
        
        public struct APS {
            struct Alert {
                let title: String?
                let subtitle: String?
                let body: String
            }
            let badge: Int?
            let sound: String?
            let alert: Alert
        }
        
        private let data: [AnyHashable: Any]
        
        public let aps: APS
        
        public init(aps: APS, data: [AnyHashable: Any]) {
            self.aps = aps
            self.data = data
        }
        
        public func getExtraParameter(_ key: String) -> String? {
            return data[key] as? String
        }
    }
    
    public static let shared = MiPushAdapter()
    
    private override init() {}
    
    public weak var delegate: MiPushAdapterDelegate?
    
    private var mipushHandler: MipushHandler = MipushHandler()
    
    public func registerAPNs() {
        MiPushSDK.registerMiPush(self.mipushHandler, type: [.badge, .alert, .sound], connect: true)
    }
    
    public func clearBadge() {
        // 如果无效请尝试，原因是，在推送时badge设置为0，这样你在app中再次设置就会失效
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // 不提供subscribe接口，subscribe的操作最佳实践应该放在服务器
    // 实际上setAlias和setAccount如果可以放服务器更佳（但目前服务器没有提供这两个接口，仅提供subscribe接口）
    public func setAlias(_ alias: String) {
        MiPushSDK.setAlias(alias)
    }
    
    public func unsetAlias(_ alias: String) {
        MiPushSDK.unsetAlias(alias)
    }
    
    public func setAccount(_ account: String) {
        MiPushSDK.setAccount(account)
    }
    
    public func unsetAccount(_ account: String) {
        MiPushSDK.unsetAccount(account)
    }
}

protocol MiPushDelegateHandlerProtocol: class {
    
    func miPushRequestSucc(withSelector selector: String!, data: [AnyHashable : Any]!)
    
    func miPushRequestErr(withSelector selector: String!, error: Int32, data: [AnyHashable : Any]!)
    
    func miPushReceiveNotification(_ data: [AnyHashable : Any]!)
}

class MipushHandler: NSObject, MiPushSDKDelegate {
    
    weak var delegate: MiPushDelegateHandlerProtocol?
    
     func miPushRequestSucc(withSelector selector: String!, data: [AnyHashable : Any]!) {
        // 请求成功，可在此处获取regId
        self.delegate?.miPushRequestSucc(withSelector: selector, data: data)
    }
    
     func miPushRequestErr(withSelector selector: String!, error: Int32, data: [AnyHashable : Any]!) {
        self.delegate?.miPushRequestErr(withSelector: selector, error: error, data: data)
    }
    
     func miPushReceiveNotification(_ data: [AnyHashable : Any]!) {
        self.delegate?.miPushReceiveNotification(data)

    }
}


extension MiPushAdapter {
    
    /// 处理启动时的推送消息
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) {
        guard let userInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any] else {
            return
        }
        MiPushSDK.handleReceiveRemoteNotification(userInfo)
        openAppNotify(userInfo: userInfo)
    }
    
    /// 上传deviceToken到小米服务器
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MiPushSDK.bindDeviceToken(deviceToken)
    }
    
    /// 接收到推送信息
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        MiPushSDK.handleReceiveRemoteNotification(userInfo)
        openAppNotify(userInfo: userInfo)
    }
}

extension MipushHandler: UNUserNotificationCenterDelegate {
    // 应用在前台收到通知
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        let userInfo = notification.request.content.userInfo
        if let trigger = notification.request.trigger,
            trigger.isKind(of: UNPushNotificationTrigger.self) {
            MiPushSDK.handleReceiveRemoteNotification(userInfo)
        }
        completionHandler([])
    }
    
    // 点击通知进入应用
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response:
        UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        let userInfo = response.notification.request.content.userInfo
        if let trigger = response.notification.request.trigger,
            trigger.isKind(of: UNPushNotificationTrigger.self) {
            MiPushSDK.handleReceiveRemoteNotification(userInfo)
            openAppNotify(userInfo: userInfo)
        }
        completionHandler()
    }
    
    private func openAppNotify(userInfo: [AnyHashable: Any]?) {
        if let messageId = userInfo?["_id_"] as? String {
            MiPushSDK.openAppNotify(messageId)
        }
    }
}

//extension MiPushAdapter: UNUserNotificationCenterDelegate {
//    // 应用在前台收到通知
//    @available(iOS 10.0, *)
//    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
//        let userInfo = notification.request.content.userInfo
//        if let trigger = notification.request.trigger,
//            trigger.isKind(of: UNPushNotificationTrigger.self) {
//            MiPushSDK.handleReceiveRemoteNotification(userInfo)
//        }
//        completionHandler([])
//    }
//
//    // 点击通知进入应用
//    @available(iOS 10.0, *)
//    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response:
//        UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
//        let userInfo = response.notification.request.content.userInfo
//        if let trigger = response.notification.request.trigger,
//            trigger.isKind(of: UNPushNotificationTrigger.self) {
//            MiPushSDK.handleReceiveRemoteNotification(userInfo)
//            openAppNotify(userInfo: userInfo)
//        }
//        completionHandler()
//    }
//}

extension MiPushAdapter: MiPushDelegateHandlerProtocol {

    public func miPushRequestSucc(withSelector selector: String!, data: [AnyHashable : Any]!) {
        // 请求成功，可在此处获取regId
        if selector == "bindDeviceToken:",
            let regId = data["regid"] as? String {
            delegate?.miPushAdapter(self, didGetRegId: regId)
        }
    }

    public func miPushRequestErr(withSelector selector: String!, error: Int32, data: [AnyHashable : Any]!) {
        if selector == "bindDeviceToken:" {
            print("MiPush bindDeviceToken failed")
        }
    }

    public func miPushReceiveNotification(_ data: [AnyHashable : Any]!) {
        guard let data = data else { return }
        let ops = data["aps"] as? [AnyHashable: Any]

        let badge = ops?["badge"] as? Int
        let alert = ops?["alert"] as? [String: Any]
        let title = alert?["title"] as? String
        let subtitle = alert?["subtitle"] as? String
        let body = alert?["body"] as! String
        let sound = ops?["sound"] as? String

        let aps = PushData.APS(badge: badge, sound: sound, alert: PushData.APS.Alert(title: title, subtitle: subtitle, body: body))
        let pushData = PushData(aps: aps, data: data)
        delegate?.miPushAdapter(self, didReceiveNotification: pushData)
    }
}

extension MiPushAdapter {
    
    private func handleReceiveRemoteNotification(userInfo: [AnyHashable : Any]) {
        MiPushSDK.handleReceiveRemoteNotification(userInfo)
        openAppNotify(userInfo: userInfo)
    }
    
    private func openAppNotify(userInfo: [AnyHashable: Any]?) {
        if let messageId = userInfo?["_id_"] as? String {
            MiPushSDK.openAppNotify(messageId)
        }
    }
}
