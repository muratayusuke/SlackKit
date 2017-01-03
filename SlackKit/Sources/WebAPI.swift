//
// WebAPI.swift
//
// Copyright © 2016 Peter Zignego. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

internal enum Endpoint: String {
    
    case apiTest = "api.test"
    case authRevoke = "auth.revoke"
    case authTest = "auth.test"
    case channelsHistory = "channels.history"
    case channelsInfo = "channels.info"
    case channelsList = "channels.list"
    case channelsMark = "channels.mark"
    case channelsSetPurpose = "channels.setPurpose"
    case channelsSetTopic = "channels.setTopic"
    case chatDelete = "chat.delete"
    case chatPostMessage = "chat.postMessage"
    case chatMeMessage = "chat.meMessage"
    case chatUpdate = "chat.update"
    case dndInfo = "dnd.info"
    case dndTeamInfo = "dnd.teamInfo"
    case emojiList = "emoji.list"
    case filesCommentsAdd = "files.comments.add"
    case filesCommentsEdit = "files.comments.edit"
    case filesCommentsDelete = "files.comments.delete"
    case filesDelete = "files.delete"
    case filesInfo = "files.info"
    case filesUpload = "files.upload"
    case groupsClose = "groups.close"
    case groupsHistory = "groups.history"
    case groupsInfo = "groups.info"
    case groupsList = "groups.list"
    case groupsMark = "groups.mark"
    case groupsOpen = "groups.open"
    case groupsSetPurpose = "groups.setPurpose"
    case groupsSetTopic = "groups.setTopic"
    case imClose = "im.close"
    case imHistory = "im.history"
    case imList = "im.list"
    case imMark = "im.mark"
    case imOpen = "im.open"
    case mpimClose = "mpim.close"
    case mpimHistory = "mpim.history"
    case mpimList = "mpim.list"
    case mpimMark = "mpim.mark"
    case mpimOpen = "mpim.open"
    case oauthAccess = "oauth.access"
    case pinsAdd = "pins.add"
    case pinsRemove = "pins.remove"
    case reactionsAdd = "reactions.add"
    case reactionsGet = "reactions.get"
    case reactionsList = "reactions.list"
    case reactionsRemove = "reactions.remove"
    case rtmStart = "rtm.start"
    case starsAdd = "stars.add"
    case starsRemove = "stars.remove"
    case teamInfo = "team.info"
    case usersGetPresence = "users.getPresence"
    case usersInfo = "users.info"
    case usersList = "users.list"
    case usersSetActive = "users.setActive"
    case usersSetPresence = "users.setPresence"
}

public final class WebAPI {
    
    public typealias FailureClosure = (_ error: SlackError)->Void
    
    public enum InfoType: String {
        case purpose = "purpose"
        case topic = "topic"
    }
    
    public enum ParseMode: String {
        case full = "full"
        case none = "none"
    }
    
    public enum Presence: String {
        case auto = "auto"
        case away = "away"
    }
    
    fileprivate enum ChannelType: String {
        case channel = "channel"
        case group = "group"
        case im = "im"
    }
    
    fileprivate let networkInterface: NetworkInterface
    fileprivate let token: String

    public init(token: String) {
        self.networkInterface = NetworkInterface()
        self.token = token
    }
    
    //MARK: - RTM
    public func rtmStartRequest(simpleLatest: Bool? = nil, noUnreads: Bool? = nil, mpimAware: Bool? = nil) -> URLRequest? {
        let parameters: [String: Any?] = ["simple_latest": simpleLatest, "no_unreads": noUnreads, "mpim_aware": mpimAware]
        return networkInterface.request(endpoint: .rtmStart, token: token, parameters: WebAPI.filterNilParameters(parameters))
    }
    
    public func rtmStart(simpleLatest: Bool? = nil, noUnreads: Bool? = nil, mpimAware: Bool? = nil, success: ((_ response: [String: Any]) -> Void)?, failure: FailureClosure?) {
        let request = rtmStartRequest(simpleLatest: simpleLatest, noUnreads: noUnreads, mpimAware: mpimAware)
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(response)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Auth
    public func authenticationTestRequest() -> URLRequest? {
        return networkInterface.request(endpoint: .authTest, token: token, parameters: nil)
    }
    
    public func authenticationTest(success: ((_ authenticated: Bool) -> Void)?, failure: FailureClosure?) {
        let request = authenticationTestRequest()
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public static func oauthAccessRequest(clientID: String, clientSecret: String, code: String, redirectURI: String? = nil) -> URLRequest? {
        let parameters: [String: Any?] = ["client_id": clientID, "client_secret": clientSecret, "code": code, "redirect_uri": redirectURI]
        return NetworkInterface().request(endpoint: .oauthAccess, parameters: WebAPI.filterNilParameters(parameters))
    }
    
    public static func oauthAccess(clientID: String, clientSecret: String, code: String, redirectURI: String? = nil, success: ((_ response: [String: Any])->Void)?, failure: ((SlackError)->Void)?) {
        let request = oauthAccessRequest(clientID: clientID, clientSecret: clientSecret, code: code, redirectURI: redirectURI)
        NetworkInterface().fire(request: request, successClosure: {
            (response) -> Void in
            success?(response)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public static func oauthRevokeRequest(token: String, test: Bool? = nil) -> URLRequest? {
        let parameters: [String: Any?] = ["token": token, "test": test]
        return NetworkInterface().request(endpoint: .authRevoke, parameters: WebAPI.filterNilParameters(parameters))
    }
    
    public static func oauthRevoke(token: String, test: Bool? = nil, success: ((_ revoked:Bool)->Void)?, failure: ((SlackError)->Void)?) {
        let request = oauthRevokeRequest(token: token, test: test)
        NetworkInterface().fire(request: request, successClosure: {
            (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Channels
    public func channelHistoryRequest(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> URLRequest? {
        return historyRequest(endpoint: .channelsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
    }
    
    public func channelHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((_ history: History) -> Void)?, failure: FailureClosure?) {
        let request = channelHistoryRequest(id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        history(request: request, success: success, failure: failure)
    }
    
    public func channelInfoRequest(id: String) -> URLRequest? {
        return infoRequest(endpoint: .channelsInfo, id: id)
    }
    
    public func channelInfo(id: String, success: ((_ channel: Channel) -> Void)?, failure: FailureClosure?) {
        let request = channelInfoRequest(id: id)
        info(request: request, type:ChannelType.channel, success: { (channel) -> Void in
            success?(channel)
        }) { (error) -> Void in
            failure?(error)
        }
    }
    
    public func channelsListRequest(excludeArchived: Bool = false) -> URLRequest? {
        return listRequest(endpoint: .channelsList, excludeArchived: excludeArchived)
    }
    
    public func channelsList(excludeArchived: Bool = false, success: ((_ channels: [[String: Any]]?) -> Void)?, failure: FailureClosure?) {
        let request = channelsListRequest(excludeArchived: excludeArchived)
        list(request: request, type: .channel, success: { (channels) -> Void in
            success?(channels)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func markChannelRequest(channel: String, timestamp: String) -> URLRequest? {
        return markRequest(endpoint: .channelsMark, channel: channel, timestamp: timestamp)
    }
    
    public func markChannel(channel: String, timestamp: String, success: ((_ ts: String) -> Void)?, failure: FailureClosure?) {
        let request = markChannelRequest(channel: channel, timestamp: timestamp)
        mark(request: request, timestamp: timestamp, success: { (ts) -> Void in
            success?(timestamp)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func setChannelPurposeRequest(channel: String, purpose: String) -> URLRequest? {
        return setInfoRequest(endpoint: .channelsSetPurpose, type: .purpose, channel: channel, text: purpose)
    }
    
    public func setChannelPurpose(channel: String, purpose: String, success: ((_ purposeSet: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setChannelPurposeRequest(channel: channel, purpose: purpose)
        setInfo(request: request, success: { (purposeSet) -> Void in
            success?(purposeSet)
        }) { (error) -> Void in
            failure?(error)
        }
    }
    
    public func setChannelTopicRequest(channel: String, topic: String) -> URLRequest? {
        return setInfoRequest(endpoint: .channelsSetTopic, type: .topic, channel: channel, text: topic)
    }
    
    public func setChannelTopic(channel: String, topic: String, success: ((_ topicSet: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setChannelTopicRequest(channel: channel, topic: topic)
        setInfo(request: request, success: { (topicSet) -> Void in
            success?(topicSet)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Messaging
    public func deleteMessageRequest(channel: String, ts: String) -> URLRequest? {
        let parameters: [String: Any] = ["channel": channel, "ts": ts]
        return networkInterface.request(endpoint: .chatDelete, token: token, parameters: parameters)
    }
    
    public func deleteMessage(channel: String, ts: String, success: ((_ deleted: Bool) -> Void)?, failure: FailureClosure?) {
        let request = deleteMessageRequest(channel: channel, ts: ts)
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func sendMessageRequest(channel: String, text: String, username: String? = nil, asUser: Bool? = nil, parse: ParseMode? = nil, linkNames: Bool? = nil, attachments: [Attachment?]? = nil, unfurlLinks: Bool? = nil, unfurlMedia: Bool? = nil, iconURL: String? = nil, iconEmoji: String? = nil) -> URLRequest? {
        let parameters: [String: Any?] = ["channel": channel, "text": text.slackFormatEscaping, "as_user": asUser, "parse": parse?.rawValue, "link_names": linkNames, "unfurl_links": unfurlLinks, "unfurlMedia": unfurlMedia, "username": username, "attachments": encodeAttachments(attachments), "icon_url": iconURL, "icon_emoji": iconEmoji]
        return networkInterface.request(endpoint: .chatPostMessage, token: token, parameters: WebAPI.filterNilParameters(parameters))
    }
    
    public func sendMessage(channel: String, text: String, username: String? = nil, asUser: Bool? = nil, parse: ParseMode? = nil, linkNames: Bool? = nil, attachments: [Attachment?]? = nil, unfurlLinks: Bool? = nil, unfurlMedia: Bool? = nil, iconURL: String? = nil, iconEmoji: String? = nil, success: (((ts: String?, channel: String?)) -> Void)?, failure: FailureClosure?) {
        let request = sendMessageRequest(channel: channel, text: text, username: username, asUser: asUser, parse: parse, linkNames: linkNames, attachments: attachments, unfurlLinks: unfurlLinks, unfurlMedia: unfurlMedia, iconURL: iconURL, iconEmoji: iconEmoji)
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?((ts: response["ts"] as? String, response["channel"] as? String))
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func updateMessageRequest(channel: String, ts: String, message: String, attachments: [Attachment?]? = nil, parse: ParseMode = .none, linkNames: Bool = false) -> URLRequest? {
        let parameters: [String: Any?] = ["channel": channel, "ts": ts, "text": message.slackFormatEscaping, "parse": parse.rawValue, "link_names": linkNames, "attachments":encodeAttachments(attachments)]
        return networkInterface.request(endpoint: .chatUpdate, token: token, parameters: WebAPI.filterNilParameters(parameters))
    }
    
    public func updateMessage(channel: String, ts: String, message: String, attachments: [Attachment?]? = nil, parse: ParseMode = .none, linkNames: Bool = false, success: ((_ updated: Bool) -> Void)?, failure: FailureClosure?) {
        let request = updateMessageRequest(channel: channel, ts: ts, message: message, attachments: attachments, parse: parse, linkNames: linkNames)
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Do Not Disturb
    public func dndInfoRequest(user: String? = nil) -> URLRequest? {
        let parameters: [String: Any?] = ["user": user]
        return networkInterface.request(endpoint: .dndInfo, token: token, parameters: WebAPI.filterNilParameters(parameters))
    }
    
    public func dndInfo(user: String? = nil, success: ((_ status: DoNotDisturbStatus) -> Void)?, failure: FailureClosure?) {
        let request = dndInfoRequest(user: user)
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(DoNotDisturbStatus(status: response))
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func dndTeamInfoRequest(users: [String]? = nil) -> URLRequest? {
        let parameters: [String: Any?] = ["users":users?.joined(separator: ",")]
        return networkInterface.request(endpoint: .dndTeamInfo, token: token, parameters: WebAPI.filterNilParameters(parameters))
    }
    
    public func dndTeamInfo(users: [String]? = nil, success: ((_ statuses: [String: DoNotDisturbStatus]) -> Void)?, failure: FailureClosure?) {
        let request = dndTeamInfoRequest(users: users)
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            guard let usersDictionary = response["users"] as? [String: Any] else {
                success?([:])
                return
            }
            success?(self.enumerateDNDStatuses(usersDictionary))
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Emoji
    public func emojiListRequest() -> URLRequest? {
        return networkInterface.request(endpoint: .emojiList, token: token, parameters: nil)
    }
    
    public func emojiList(success: ((_ emojiList: [String: Any]?) -> Void)?, failure: FailureClosure?) {
        let request = emojiListRequest()
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(response["emoji"] as? [String: Any])
        }) { (error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Files
    public func deleteFileRequest(fileID: String) -> URLRequest? {
        let parameters = ["file": fileID]
        return networkInterface.request(endpoint: .filesDelete, token: token, parameters: parameters)
    }
    
    public func deleteFile(fileID: String, success: ((_ deleted: Bool) -> Void)?, failure: FailureClosure?) {
        let request = deleteFileRequest(fileID: fileID)
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func fileInfoRequest(fileID: String, commentCount: Int = 100, totalPages: Int = 1) -> URLRequest? {
        let parameters: [String: Any] = ["file":fileID, "count": commentCount, "totalPages":totalPages]
        return networkInterface.request(endpoint: .filesInfo, token: token, parameters: parameters)
    }
    
    public func fileInfo(fileID: String, commentCount: Int = 100, totalPages: Int = 1, success: ((_ file: File) -> Void)?, failure: FailureClosure?) {
        let request = fileInfoRequest(fileID: fileID, commentCount: commentCount, totalPages: totalPages)
        networkInterface.fire(request: request, successClosure: { (response) in
            var file = File(file: response["file"] as? [String: Any])
            (response["comments"] as? [[String: Any]])?.forEach { comment in
                let comment = Comment(comment: comment)
                if let id = comment.id {
                    file.comments[id] = comment
                }
            }
            success?(file)
        }) {(error) in
            failure?(error)
        }
    }
    
    public func uploadFile(_ file: Data, filename: String, filetype: String = "auto", title: String? = nil, initialComment: String? = nil, channels: [String]? = nil, success: ((_ file: File)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["filename": filename, "filetype": filetype, "title": title, "initial_comment": initialComment, "channels": channels?.joined(separator: ",")]
        networkInterface.uploadRequest(token, data: file, parameters: WebAPI.filterNilParameters(parameters), successClosure: {
            (response) -> Void in
                success?(File(file: response["file"] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error)
        }
    }
    
    //MARK: - File Comments
    public func addFileCommentRequest(fileID: String, comment: String) -> URLRequest? {
        let parameters: [String: Any] = ["file":fileID, "comment":comment.slackFormatEscaping]
        return networkInterface.request(endpoint: .filesCommentsAdd, token: token, parameters: parameters)
    }
    
    public func addFileComment(fileID: String, comment: String, success: ((_ comment: Comment) -> Void)?, failure: FailureClosure?) {
        let request = addFileCommentRequest(fileID: fileID, comment: comment)
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(Comment(comment: response["comment"] as? [String: Any]))
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func editFileCommentRequest(fileID: String, commentID: String, comment: String) -> URLRequest? {
        let parameters: [String: Any] = ["file":fileID, "id":commentID, "comment":comment.slackFormatEscaping]
        return networkInterface.request(endpoint: .filesCommentsEdit, token: token, parameters: parameters)
    }
    
    public func editFileComment(fileID: String, commentID: String, comment: String, success: ((_ comment: Comment) -> Void)?, failure: FailureClosure?) {
        let request = editFileCommentRequest(fileID: fileID, commentID: commentID, comment: comment)
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(Comment(comment: response["comment"] as? [String: Any]))
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func deleteFileCommentRequest(fileID: String, commentID: String) -> URLRequest? {
        let parameters: [String: Any] = ["file":fileID, "id": commentID]
        return networkInterface.request(endpoint: .filesCommentsDelete, token: token, parameters: parameters)
    }
    
    public func deleteFileComment(fileID: String, commentID: String, success: ((_ deleted: Bool?) -> Void)?, failure: FailureClosure?) {
        let request = deleteFileCommentRequest(fileID: fileID, commentID: commentID)
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Groups
    public func closeGroupRequest(groupID: String) -> URLRequest? {
        return closeRequest(endpoint: .groupsClose, channelID: groupID)
    }
    
    public func closeGroup(groupID: String, success: ((_ closed: Bool) -> Void)?, failure: FailureClosure?) {
        let request = closeGroupRequest(groupID: groupID)
        close(request: request, success: { (closed) -> Void in
            success?(closed)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func groupHistoryRequest(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> URLRequest? {
        return historyRequest(endpoint: .groupsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
    }
    
    public func groupHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((_ history: History) -> Void)?, failure: FailureClosure?) {
        let request = groupHistoryRequest(id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        history(request: request, success: { (history) -> Void in
            success?(history)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func groupInfoRequest(id: String) -> URLRequest? {
        return infoRequest(endpoint: .groupsInfo, id: id)
    }
    
    public func groupInfo(id: String, success: ((_ channel: Channel) -> Void)?, failure: FailureClosure?) {
        let request = groupInfoRequest(id: id)
        info(request: request, type:ChannelType.group, success: { (channel) -> Void in
            success?(channel)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func groupsListRequest(excludeArchived: Bool = false) -> URLRequest? {
        return listRequest(endpoint: .groupsList, excludeArchived: excludeArchived)
    }
    
    public func groupsList(excludeArchived: Bool = false, success: ((_ channels: [[String: Any]]?) -> Void)?, failure: FailureClosure?) {
        let request = groupsListRequest(excludeArchived: excludeArchived)
        list(request: request, type:ChannelType.group, success: { (channels) -> Void in
            success?(channels)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func markGroupRequest(channel: String, timestamp: String) -> URLRequest? {
        return markRequest(endpoint: .groupsMark, channel: channel, timestamp: timestamp)
    }
    
    public func markGroup(channel: String, timestamp: String, success: ((_ ts: String) -> Void)?, failure: FailureClosure?) {
        let request = markGroupRequest(channel: channel, timestamp: timestamp)
        mark(request: request, timestamp: timestamp, success: { (ts) -> Void in
            success?(timestamp)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func openGroupRequest(channel: String) -> URLRequest? {
        let parameters = ["channel":channel]
        return networkInterface.request(endpoint: .groupsOpen, token: token, parameters: parameters)
    }
    
    public func openGroup(channel: String, success: ((_ opened: Bool) -> Void)?, failure: FailureClosure?) {
        let request = openGroupRequest(channel: channel)
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func setGroupPurposeRequest(channel: String, purpose: String) -> URLRequest? {
        return setInfoRequest(endpoint: .groupsSetPurpose, type: .purpose, channel: channel, text: purpose)
    }
    
    public func setGroupPurpose(channel: String, purpose: String, success: ((_ purposeSet: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setGroupPurposeRequest(channel: channel, purpose: purpose)
        setInfo(request: request, success: {
            (purposeSet) -> Void in
            success?(purposeSet)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func setGroupTopicRequest(channel: String, topic: String) -> URLRequest? {
        return setInfoRequest(endpoint: .groupsSetTopic, type: .topic, channel: channel, text: topic)
    }
    
    public func setGroupTopic(channel: String, topic: String, success: ((_ topicSet: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setGroupTopicRequest(channel: channel, topic: topic)
        setInfo(request: request, success: {
            (topicSet) -> Void in
            success?(topicSet)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - IM
    public func closeIMRequest(channel: String) -> URLRequest? {
        return closeRequest(endpoint: .imClose, channelID: channel)
    }
    
    public func closeIM(channel: String, success: ((_ closed: Bool) -> Void)?, failure: FailureClosure?) {
        let request = closeIMRequest(channel: channel)
        close(request: request, success: {
            (closed) -> Void in
            success?(closed)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func imHistoryRequest(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> URLRequest? {
        return historyRequest(endpoint: .imHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
    }
    
    public func imHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((_ history: History) -> Void)?, failure: FailureClosure?) {
        let request = imHistoryRequest(id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        history(request: request, success: {
            (history) -> Void in
            success?(history)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func imsListRequest(excludeArchived: Bool = false) -> URLRequest? {
        return listRequest(endpoint: .imList, excludeArchived: excludeArchived)
    }
    
    public func imsList(excludeArchived: Bool = false, success: ((_ channels: [[String: Any]]?) -> Void)?, failure: FailureClosure?) {
        let request = imsListRequest(excludeArchived: excludeArchived)
        list(request: request, type: .im, success: {
            (channels) -> Void in
            success?(channels)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func markIMRequest(channel: String, timestamp: String) -> URLRequest? {
        return markRequest(endpoint: .imMark, channel: channel, timestamp: timestamp)
    }
    
    public func markIM(channel: String, timestamp: String, success: ((_ ts: String) -> Void)?, failure: FailureClosure?) {
        let request = markIMRequest(channel: channel, timestamp: timestamp)
        mark(request: request, timestamp: timestamp, success: {
            (ts) -> Void in
            success?(timestamp)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func openIMRequest(userID: String) -> URLRequest? {
        let parameters = ["user":userID]
        return networkInterface.request(endpoint: .imOpen, token: token, parameters: parameters)
    }
    
    public func openIM(userID: String, success: ((_ imID: String?) -> Void)?, failure: FailureClosure?) {
        let request = openIMRequest(userID: userID)
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            let group = response["channel"] as? [String: Any]
            success?(group?["id"] as? String)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - MPIM
    public func closeMPIMRequest(channel: String) -> URLRequest? {
        return closeRequest(endpoint: .mpimClose, channelID: channel)
    }
    
    public func closeMPIM(channel: String, success: ((_ closed: Bool) -> Void)?, failure: FailureClosure?) {
        let request = closeMPIMRequest(channel: channel)
        close(request: request, success: {
            (closed) -> Void in
            success?(closed)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func mpimHistoryRequest(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> URLRequest? {
        return historyRequest(endpoint: .mpimHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
    }
    
    public func mpimHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((_ history: History) -> Void)?, failure: FailureClosure?) {
        let request = mpimHistoryRequest(id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        history(request: request, success: {
            (history) -> Void in
            success?(history)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func mpimsListRequest(excludeArchived: Bool = false) -> URLRequest? {
        return listRequest(endpoint: .mpimList, excludeArchived: excludeArchived)
    }
    
    public func mpimsList(excludeArchived: Bool = false, success: ((_ channels: [[String: Any]]?) -> Void)?, failure: FailureClosure?) {
        let request = mpimsListRequest(excludeArchived: excludeArchived)
        list(request: request, type:ChannelType.group, success: {
            (channels) -> Void in
            success?(channels)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func markMPIMRequest(channel: String, timestamp: String) -> URLRequest? {
        return markRequest(endpoint: .mpimMark, channel: channel, timestamp: timestamp)
    }
    
    public func markMPIM(channel: String, timestamp: String, success: ((_ ts: String) -> Void)?, failure: FailureClosure?) {
        let request = markMPIMRequest(channel: channel, timestamp: timestamp)
        mark(request: request, timestamp: timestamp, success: {
            (ts) -> Void in
            success?(timestamp)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func openMPIMRequest(userIDs: [String]) -> URLRequest? {
        let parameters = ["users":userIDs.joined(separator: ",")]
        return networkInterface.request(endpoint: .mpimOpen, token: token, parameters: parameters)
    }
    
    public func openMPIM(userIDs: [String], success: ((_ mpimID: String?) -> Void)?, failure: FailureClosure?) {
        let request = openMPIMRequest(userIDs: userIDs)
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            let group = response["group"] as? [String: Any]
            success?(group?["id"] as? String)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Pins
    public func pinItemRequest(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil) -> URLRequest? {
        return pinRequest(endpoint: .pinsAdd, channel: channel, file: file, fileComment: fileComment, timestamp: timestamp)
    }
    
    public func pinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: ((_ pinned: Bool) -> Void)?, failure: FailureClosure?) {
        let request = pinItemRequest(channel: channel, file: file, fileComment: fileComment, timestamp: timestamp)
        pin(request: request, success: {
            (ok) -> Void in
            success?(ok)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func unpinItemRequest(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil) -> URLRequest? {
        return pinRequest(endpoint: .pinsRemove, channel: channel, file: file, fileComment: fileComment, timestamp: timestamp)
    }
    
    public func unpinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: ((_ unpinned: Bool) -> Void)?, failure: FailureClosure?) {
        let request = unpinItemRequest(channel: channel, file: file, fileComment: fileComment, timestamp: timestamp)
        pin(request: request, success: {
            (ok) -> Void in
            success?(ok)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    private func pinRequest(endpoint: Endpoint, channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil) -> URLRequest? {
        let parameters: [String: Any?] = ["channel":channel, "file":file, "file_comment":fileComment, "timestamp":timestamp]
        return networkInterface.request(endpoint: endpoint, token: token, parameters: WebAPI.filterNilParameters(parameters))
    }
    
    private func pin(request: URLRequest?, success: ((_ ok: Bool) -> Void)?, failure: FailureClosure?) {
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Reactions
    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func addReactionRequest(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil) -> URLRequest? {
        return reactRequest(endpoint: .reactionsAdd, name: name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
    }
    
    public func addReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((_ reacted: Bool) -> Void)?, failure: FailureClosure?) {
        let request = addReactionRequest(name: name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
        react(request: request, success: {
            (ok) -> Void in
            success?(ok)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func removeReactionRequest(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil) -> URLRequest? {
        return reactRequest(endpoint: .reactionsRemove, name: name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
    }
    
    public func removeReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((_ unreacted: Bool) -> Void)?, failure: FailureClosure?) {
        let request = removeReactionRequest(name: name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
        react(request: request, success: {
            (ok) -> Void in
            success?(ok)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    private func reactRequest(endpoint: Endpoint, name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil) -> URLRequest? {
        let parameters: [String: Any?] = ["name":name, "file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        return networkInterface.request(endpoint: endpoint, token: token, parameters: WebAPI.filterNilParameters(parameters))
    }
    
    private func react(request: URLRequest?, success: ((_ ok: Bool) -> Void)?, failure: FailureClosure?) {
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Stars
    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func addStarRequest(file: String? = nil, fileComment: String? = nil, channel: String?  = nil, timestamp: String? = nil) -> URLRequest? {
        return starRequest(endpoint: .starsAdd, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
    }
    
    public func addStar(file: String? = nil, fileComment: String? = nil, channel: String?  = nil, timestamp: String? = nil, success: ((_ starred: Bool) -> Void)?, failure: FailureClosure?) {
        let request = addStarRequest(file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
        star(request: request, success: {
            (ok) -> Void in
            success?(ok)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func removeStarRequest(file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil) -> URLRequest? {
        return starRequest(endpoint: .starsRemove, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
    }
    
    public func removeStar(file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((_ unstarred: Bool) -> Void)?, failure: FailureClosure?) {
        let request = removeStarRequest(file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
        star(request: request, success: {
            (ok) -> Void in
            success?(ok)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    private func starRequest(endpoint: Endpoint, file: String?, fileComment: String?, channel: String?, timestamp: String?) -> URLRequest? {
        let parameters: [String: Any?] = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        return networkInterface.request(endpoint: endpoint, token: token, parameters: WebAPI.filterNilParameters(parameters))
    }
    
    private func star(request: URLRequest?, success: ((_ ok: Bool) -> Void)?, failure: FailureClosure?) {
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }

    
    //MARK: - Team
    public func teamInfoRequest() -> URLRequest? {
        return networkInterface.request(endpoint: .teamInfo, token: token, parameters: nil)
    }
    
    public func teamInfo(success: ((_ info: [String: Any]?) -> Void)?, failure: FailureClosure?) {
        let request = teamInfoRequest()
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(response["team"] as? [String: Any])
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Users
    public func userPresenceRequest(user: String) -> URLRequest? {
        let parameters: [String: Any] = ["user":user]
        return networkInterface.request(endpoint: .usersGetPresence, token: token, parameters: parameters)
    }
    
    public func userPresence(user: String, success: ((_ presence: String?) -> Void)?, failure: FailureClosure?) {
        let request = userPresenceRequest(user: user)
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(response["presence"] as? String)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func userInfoRequest(id: String) -> URLRequest? {
        let parameters: [String: Any] = ["user":id]
        return networkInterface.request(endpoint: .usersInfo, token: token, parameters: parameters)
    }
    
    public func userInfo(id: String, success: ((_ user: User) -> Void)?, failure: FailureClosure?) {
        let request = userInfoRequest(id: id)
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(User(user: response["user"] as? [String: Any]))
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func usersListRequest(includePresence: Bool = false) -> URLRequest? {
        let parameters: [String: Any] = ["presence":includePresence]
        return networkInterface.request(endpoint: .usersList, token: token, parameters: parameters)
    }
    
    public func usersList(includePresence: Bool = false, success: ((_ userList: [[String: Any]]?) -> Void)?, failure: FailureClosure?) {
        let request = usersListRequest(includePresence: includePresence)
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(response["members"] as? [[String: Any]])
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func setUserActiveRequest() -> URLRequest? {
        return networkInterface.request(endpoint: .usersSetActive, token: token, parameters: nil)
    }
    
    public func setUserActive(success: ((_ success: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setUserActiveRequest()
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    public func setUserPresenceRequest(presence: Presence) -> URLRequest? {
        let parameters: [String: Any] = ["presence":presence.rawValue]
        return networkInterface.request(endpoint: .usersSetPresence, token: token, parameters: parameters)
    }
    
    public func setUserPresence(presence: Presence, success: ((_ success: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setUserPresenceRequest(presence: presence)
        networkInterface.fire(request: request, successClosure: {
            (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Channel Utilities
    private func closeRequest(endpoint: Endpoint, channelID: String) -> URLRequest? {
        let parameters: [String: Any] = ["channel":channelID]
        return networkInterface.request(endpoint: endpoint, token: token, parameters: parameters)
    }
    
    private func close(request: URLRequest?, success: ((_ closed: Bool) -> Void)?, failure: FailureClosure?) {
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    fileprivate func historyRequest(endpoint: Endpoint, id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> URLRequest? {
        let parameters: [String: Any] = ["channel": id, "latest": latest, "oldest": oldest, "inclusive":inclusive, "count":count, "unreads":unreads]
        return networkInterface.request(endpoint: endpoint, token: token, parameters: parameters)
    }
    
    fileprivate func history(request: URLRequest?, success: ((_ history: History) -> Void)?, failure: FailureClosure?) {
        networkInterface.fire(request: request, successClosure: { response in
            success?(History(history: response))
        }) { error in
            failure?(error)
        }
    }
    
    fileprivate func infoRequest(endpoint: Endpoint, id: String) -> URLRequest? {
        let parameters: [String: Any] = ["channel": id]
        return networkInterface.request(endpoint: endpoint, token: token, parameters: parameters)
    }
    
    fileprivate func info(request: URLRequest?, type: ChannelType, success: ((_ channel: Channel) -> Void)?, failure: FailureClosure?) {
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(Channel(channel: response[type.rawValue] as? [String: Any]))
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    fileprivate func listRequest(endpoint: Endpoint, excludeArchived: Bool = false) -> URLRequest? {
        let parameters: [String: Any] = ["exclude_archived": excludeArchived]
        return networkInterface.request(endpoint: endpoint, token: token, parameters: parameters)
    }
    
    fileprivate func list(request: URLRequest?, type: ChannelType, success: ((_ channels: [[String: Any]]?) -> Void)?, failure: FailureClosure?) {
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(response[type.rawValue+"s"] as? [[String: Any]])
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    fileprivate func markRequest(endpoint: Endpoint, channel: String, timestamp: String) -> URLRequest? {
        let parameters: [String: Any] = ["channel": channel, "ts": timestamp]
        return networkInterface.request(endpoint: endpoint, token: token, parameters: parameters)
    }
    
    fileprivate func mark(request: URLRequest?, timestamp: String, success: ((_ ts: String) -> Void)?, failure: FailureClosure?) {
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(timestamp)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    fileprivate func setInfoRequest(endpoint: Endpoint, type: InfoType, channel: String, text: String) -> URLRequest? {
        let parameters: [String: Any] = ["channel": channel, type.rawValue: text]
        return networkInterface.request(endpoint: endpoint, token: token, parameters: parameters)
    }
    
    fileprivate func setInfo(request: URLRequest?, success: ((_ success: Bool) -> Void)?, failure: FailureClosure?) {
        networkInterface.fire(request: request, successClosure: { (response) -> Void in
            success?(true)
        }) {(error) -> Void in
            failure?(error)
        }
    }
    
    //MARK: - Encode Attachments
    fileprivate func encodeAttachments(_ attachments: [Attachment?]?) -> String? {
        if let attachments = attachments {
            var attachmentArray: [[String: Any]] = []
            for attachment in attachments {
                if let attachment = attachment {
                    attachmentArray.append(attachment.dictionary)
                }
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: attachmentArray, options: [])
                return String(data: data, encoding: String.Encoding.utf8)
            } catch _ {
                
            }
        }
        return nil
    }
    
    //MARK: - Filter Nil Parameters
    internal static func filterNilParameters(_ parameters: [String: Any?]) -> [String: Any] {
        var finalParameters = [String: Any]()
        for (key, value) in parameters {
            if let unwrapped = value {
                finalParameters[key] = unwrapped
            }
        }
        return finalParameters
    }
    
    //MARK: - Enumerate Do Not Disturb Status
    fileprivate func enumerateDNDStatuses(_ statuses: [String: Any]) -> [String: DoNotDisturbStatus] {
        var retVal = [String: DoNotDisturbStatus]()
        for key in statuses.keys {
            retVal[key] = DoNotDisturbStatus(status: statuses[key] as? [String: Any])
        }
        return retVal
    }
}
