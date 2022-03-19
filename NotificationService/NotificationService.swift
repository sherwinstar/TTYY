//
//  NotificationService.swift
//  NotificationService
//
//  Created by Shaolin Zhou on 2021/11/9.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        
        bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent
        if let bestAttemptContent = bestAttemptContent {
            GeTuiExtSdk.handelNotificationServiceRequest(request, withAttachmentsComplete: { [weak self] (attachments: Array?, errors: Array?) in
              guard let handler = self?.contentHandler else { return }
              
              if let attachment = attachments as? [UNNotificationAttachment], !attachment.isEmpty {
                // 设置通知中的多媒体附件
                bestAttemptContent.attachments = attachment
              }
              // 展示推送的回调处理需要放到个推回执完成的回调中
                handler(bestAttemptContent)
            })
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        GeTuiExtSdk.destory()
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
          contentHandler(bestAttemptContent)
        }
    }

}
