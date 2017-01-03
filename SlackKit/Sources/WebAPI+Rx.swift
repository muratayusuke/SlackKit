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

extension WebAPI {
    
    //MARK: - Channels
    public func rx_channelHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> Observable<History> {
        guard let request = channelHistoryRequest(id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads) else {
            return Observable.empty()
        }
        return URLSession.shared.rx.json(request: request)
            .map { response in
                return History(history: response as? [String: Any])
        }
    }
    
    public func rx_markChannel(id: String, timestamp: String = "\(NSDate().timeIntervalSince1970)") -> Observable<Any> {
        guard let request = markChannelRequest(channel: id, timestamp: timestamp) else {
            return Observable.empty()
        }
        return URLSession.shared.rx.json(request: request)
    }
    
    //MARK: - Messaging
    public func rx_sendMessage(channel: String, text: String, username: String? = nil, asUser: Bool? = nil, parse: ParseMode? = nil, linkNames: Bool? = nil, attachments: [Attachment?]? = nil, unfurlLinks: Bool? = nil, unfurlMedia: Bool? = nil, iconURL: String? = nil, iconEmoji: String? = nil) -> Observable<Any> {
        guard let request = sendMessageRequest(channel: channel, text: text, username: username, asUser: asUser, parse: parse, linkNames: linkNames, attachments: attachments, unfurlLinks: unfurlLinks, unfurlMedia: unfurlMedia, iconURL: iconURL, iconEmoji: iconEmoji) else {
            return Observable.empty()
        }
        return URLSession.shared.rx.json(request: request)
    }
    
    //MARK: - Groups
    public func rx_groupHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> Observable<History> {
        guard let request = groupHistoryRequest(id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads) else {
            return Observable.empty()
        }
        return URLSession.shared.rx.json(request: request)
            .map { response in
                return History(history: response as? [String: Any])
        }
    }
    
    public func rx_markGroup(id: String, timestamp: String = "\(NSDate().timeIntervalSince1970)") -> Observable<Any> {
        guard let request = markGroupRequest(channel: id, timestamp: timestamp) else {
            return Observable.empty()
        }
        return URLSession.shared.rx.json(request: request)
    }
    
    //MARK: - IM
    public func rx_imHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> Observable<History> {
        guard let request = imHistoryRequest(id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads) else {
            return Observable.empty()
        }
        return URLSession.shared.rx.json(request: request)
            .map { response in
                return History(history: response as? [String: Any])
        }
    }
    
    public func rx_markIM(id: String, timestamp: String = "\(NSDate().timeIntervalSince1970)") -> Observable<Any> {
        guard let request = markIMRequest(channel: id, timestamp: timestamp) else {
            return Observable.empty()
        }
        return URLSession.shared.rx.json(request: request)
    }
    
    //MARK: - MPIM
    public func rx_mpimHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> Observable<History> {
        guard let request = mpimHistoryRequest(id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads) else {
            return Observable.empty()
        }
        return URLSession.shared.rx.json(request: request)
            .map { response in
                return History(history: response as? [String: Any])
        }
    }
    
    public func rx_markMPIM(id: String, timestamp: String = "\(NSDate().timeIntervalSince1970)") -> Observable<Any> {
        guard let request = markMPIMRequest(channel: id, timestamp: timestamp) else {
            return Observable.empty()
        }
        return URLSession.shared.rx.json(request: request)
    }
    
}
