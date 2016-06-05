//
//  SlackWebAPI+Rx.swift
//  SlackKit
//
//  Created by 佑介 村田 on 2016/06/05.
//  Copyright © 2016年 Launch Software LLC. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension SlackWebAPI {

    public func rx_sendMessage(channel: String, text: String, username: String? = nil, asUser: Bool? = nil, parse: ParseMode? = nil, linkNames: Bool? = nil, attachments: [Attachment?]? = nil, unfurlLinks: Bool? = nil, unfurlMedia: Bool? = nil, iconURL: String? = nil, iconEmoji: String? = nil) -> Observable<AnyObject> {
        guard let request = sendMessageRequest(channel, text: text, username: username, asUser: asUser, parse: parse, linkNames: linkNames, attachments: attachments, unfurlLinks: unfurlLinks, unfurlMedia: unfurlMedia, iconURL: iconURL, iconEmoji: iconEmoji) else {
            return Observable.empty()
        }
        return NSURLSession.sharedSession().rx_JSON(request)
    }

}
