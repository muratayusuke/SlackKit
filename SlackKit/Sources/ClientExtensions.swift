//
//  ClientExtensions.swift
//  SlackKit
//
//  Created by Peter Zignego on 1/18/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation

extension Client {
    
    //MARK: - User & Channel
    public func getChannelOrUserIdByName(name: String) -> String? {
        if (name[name.startIndex] == "@") {
            return getUserIdByName(name)
        } else if (name[name.startIndex] == "C") {
            return getChannelIDByName(name)
        }
        return nil
    }
    
    public func getChannelIDByName(name: String) -> String? {
        return channels.filter{$0.1.name == stripString(name)}.first?.0
    }
    
    public func getUserIdByName(name: String) -> String? {
        return users.filter{$0.1.name == stripString(name)}.first?.0
    }
    
    public func getImIDForUserWithID(id: String, completion: (imID: String?) -> Void) {
        let ims = channels.filter{$0.1.isIM == true}
        let channel = ims.filter{$0.1.user == id}.first
        if let channel = channel {
            completion(imID: channel.0)
        } else {
            api.imOpen(id, completion: completion)
        }
    }
    
    public func getChannelHistory(channelID: String, completion: (messages: [Message]) -> Void) {
        api.fetchChannelHistory(channelID) { (response) -> Void in
            print(response)
            if let messages = response["messages"] as? [[String: AnyObject]] {
                let messageObjects: [Message] = messages.map({ (m) -> Message in
                    return Message.init(message: m)!
                })
                completion(messages: messageObjects)
            }
        }
    }
    
    public func getIMHistory(channelID: String, completion: (messages: [Message]) -> Void) {
        api.fetchIMHistory(channelID) { (response) -> Void in
            print(response)
            if let messages = response["messages"] as? [[String: AnyObject]] {
                let messageObjects: [Message] = messages.map({ (m) -> Message in
                    return Message.init(message: m)!
                })
                completion(messages: messageObjects)
            }
        }
    }
    
    //MARK: - Utilities
    internal func stripString(var string: String) -> String {
        if string[string.startIndex] == "@" {
            string = string.substringFromIndex(string.startIndex.advancedBy(1))
        } else if string[string.startIndex] == "#" {
            string = string.substringFromIndex(string.startIndex.advancedBy(1))
        }
        return string
    }
    
}
