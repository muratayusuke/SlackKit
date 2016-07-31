//
//  Channel+Rx.swift
//  SlackKit
//
//  Created by 佑介 村田 on 2016/06/05.
//  Copyright © 2016年 Launch Software LLC. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Channel {

    public func rx_history(latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> Observable<History> {
        guard let id = id, client = client else { return Observable.never() }
        if isMPIM == true {
            return client.webAPI.rx_mpimHistory(id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        } else if isIM == true {
            return client.webAPI.rx_imHistory(id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        } else if isGroup == true {
            return client.webAPI.rx_groupHistory(id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        } else {
            return client.webAPI.rx_channelHistory(id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        }
    }

    public func rx_mark(timestamp: String = "\(NSDate().timeIntervalSince1970)") -> Observable<AnyObject> {
        guard let id = id, client = client else { return Observable.never() }
        if isMPIM == true {
            return client.webAPI.rx_markMPIM(id, timestamp: timestamp)
        } else if isIM == true {
            return client.webAPI.rx_markIM(id, timestamp: timestamp)
        } else if isGroup == true {
            return client.webAPI.rx_markGroup(id, timestamp: timestamp)
        } else {
            return client.webAPI.rx_markChannel(id, timestamp: timestamp)
        }
    }

}
