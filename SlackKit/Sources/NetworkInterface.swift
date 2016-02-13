//
//  NetworkInterface.swift
//  SlackKit
//
//  Created by Peter Zignego on 1/18/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation
import Starscream

enum SlackAPIEndpoint: String {
    case APITest = "api.test"
    case AuthTest = "auth.test"
    case ChannelsHistory = "channels.history"
    case ChannelsInfo = "channels.info"
    case ChannelsList = "channels.list"
    case ChannelsMark = "channels.mark"
    case ChannelsSetPurpose = "channels.setPurpose"
    case ChannelsSetTopic = "channels.setTopic"
    case ChatDelete = "chat.delete"
    case ChatPostMessage = "chat.postMessage"
    case ChatUpdate = "chat.update"
    case EmojiList = "emoji.list"
    case FilesDelete = "files.delete"
    case FilesUpload = "files.upload"
    case GroupsClose = "groups.close"
    case GroupsHistory = "groups.history"
    case GroupsInfo = "groups.info"
    case GroupsList = "groups.list"
    case GroupsMark = "groups.mark"
    case GroupsOpen = "groups.open"
    case GroupsSetPurpose = "groups.setPurpose"
    case GroupsSetTopic = "groups.setTopic"
    case IMClose = "im.close"
    case IMHistory = "im.history"
    case IMList = "im.list"
    case IMMark = "im.mark"
    case IMOpen = "im.open"
    case MPIMClose = "mpim.close"
    case MPIMHistory = "mpim.history"
    case MPIMList = "mpim.list"
    case MPIMMark = "mpim.mark"
    case MPIMOpen = "mpim.open"
    case PinsAdd = "pins.add"
    case PinsRemove = "pins.remove"
    case ReactionsAdd = "reactions.add"
    case ReactionsGet = "reactions.get"
    case ReactionsList = "reactions.list"
    case ReactionsRemove = "reactions.remove"
    case RTMStart = "rtm.start"
    case StarsAdd = "stars.add"
    case StarsRemove = "stars.remove"
    case TeamInfo = "team.info"
    case UsersGetPresence = "users.getPresence"
    case UsersInfo = "users.info"
    case UsersList = "users.list"
    case UsersSetActive = "users.setActive"
    case UsersSetPresence = "users.setPresence"
}

public struct NetworkInterface {
    let client: Client
    private let apiUrl = "https://slack.com/api/"
    
    internal func request(endpoint: SlackAPIEndpoint, parameters: [String: AnyObject]?, successClosure: ([String: AnyObject])->Void, errorClosure: (SlackError)->Void) {
        let token = client.token
        var requestString = "\(apiUrl)\(endpoint.rawValue)?token=\(token)"
        if let params = parameters {
            requestString = requestString + requestStringFromParameters(params)
        }
        let request = NSURLRequest(URL: NSURL(string: requestString)!)
        NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, internalError) -> Void in
            guard let data = data else {
                return
            }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
                if (result["ok"] as! Bool == true) {
                    successClosure(result)
                } else {
                    if let errorString = result["error"] as? String {
                        throw ErrorDispatcher.dispatch(errorString)
                    } else {
                        throw SlackError.UnknownError
                    }
                }
            } catch let error {
                if let slackError = error as? SlackError {
                    errorClosure(slackError)
                } else {
                    errorClosure(SlackError.UnknownError)
                }
            }
        }.resume()
    }
    
    private func requestStringFromParameters(parameters: [String: AnyObject]) -> String {
        var requestString = ""
        for key in parameters.keys {
            if let value = parameters[key] as? String {
                requestString = requestString + "&\(key)=\(value)"
            }
        }
        
        return requestString
    }
    
    //MARK: - Connection
    public func connect() {
        request(
            SlackAPIEndpoint.RTMStart,
            parameters: nil,
            successClosure: { (response) -> Void in
                self.client.initialSetup(response)
                if let socketURL = response["url"] as? String {
                    let url = NSURL(string: socketURL)
                    self.client.webSocket = WebSocket(url: url!)
                    self.client.webSocket?.delegate = self.client
                    self.client.webSocket?.connect()
                }
            }) { (SlackError) -> Void in }
    }
    
    //MARK: - IM
    public func imOpen(userID: String, completion: (imID: String?) -> Void) {
        request(
            SlackAPIEndpoint.IMOpen,
            parameters: ["user":userID],
            successClosure: { (response) -> Void in
                if let channel = response["channel"] as? [String: AnyObject], id = channel["id"] as? String {
                    let exists = self.client.channels.filter{$0.0 == id}.count > 0
                    if exists == true {
                        self.client.channels[id]?.isOpen = true
                    } else {
                        self.client.channels[id] = Channel(channel: channel)
                    }
                    completion(imID: id)
                    
                    if let delegate = self.client.groupEventsDelegate {
                        delegate.groupOpened(self.client.channels[id]!)
                    }
                }
            }) { (SlackError) -> Void in }
    }
    
    public func fetchChannelHistory(channelID: String, completion: (response: [String: AnyObject]) -> Void) {
        request(
            SlackAPIEndpoint.ChannelsHistory,
            parameters: ["channel": channelID],
            successClosure: { (response) -> Void in
                completion(response: response)
            }) { (SlackError) -> Void in }
    }
    
    public func fetchIMHistory(channelID: String, completion: (response: [String: AnyObject]) -> Void) {
        print(channelID)
        request(
            SlackAPIEndpoint.IMHistory,
            parameters: ["channel": channelID],
            successClosure: { (response) -> Void in
                completion(response: response)
            }) { (SlackError) -> Void in }
    }
}
