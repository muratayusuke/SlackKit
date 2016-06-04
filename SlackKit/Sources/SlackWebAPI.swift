//
// SlackWebAPI.swift
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

internal enum SlackAPIEndpoint: String {
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
    case DNDInfo = "dnd.info"
    case DNDTeamInfo = "dnd.teamInfo"
    case EmojiList = "emoji.list"
    case FilesCommentsAdd = "files.comments.add"
    case FilesCommentsEdit = "files.comments.edit"
    case FilesCommentsDelete = "files.comments.delete"
    case FilesDelete = "files.delete"
    case FilesInfo = "files.info"
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

public class SlackWebAPI {

    public typealias FailureClosure = (error: SlackError) -> Void

    public enum InfoType: String {
        case Purpose = "purpose"
        case Topic = "topic"
    }

    public enum ParseMode: String {
        case Full = "full"
        case None = "none"
    }

    public enum Presence: String {
        case Auto = "auto"
        case Away = "away"
    }

    private enum ChannelType: String {
        case Channel = "channel"
        case Group = "group"
        case IM = "im"
    }

    private let networkInterface: NetworkInterface
    private let token: String

    init(networkInterface: NetworkInterface, token: String) {
        self.networkInterface = networkInterface
        self.token = token
    }

    convenience public init(client: Client) {
        self.init(networkInterface: client.api, token: client.token)
    }

    //MARK: - RTM
    public func rtmStartRequest(simpleLatest: Bool? = nil, noUnreads: Bool? = nil, mpimAware: Bool? = nil) -> NSURLRequest? {
        let parameters: [String: AnyObject?] = ["simple_latest": simpleLatest, "no_unreads": noUnreads, "mpim_aware": mpimAware]
        return networkInterface.requestFromEndpoint(.RTMStart, token: token, parameters: filterNilParameters(parameters))
    }

    public func rtmStart(simpleLatest: Bool? = nil, noUnreads: Bool? = nil, mpimAware: Bool? = nil, success: ((response: [String: AnyObject]) -> Void)?, failure: FailureClosure?) {
        let request = rtmStartRequest(simpleLatest, noUnreads: noUnreads, mpimAware: mpimAware)
        networkInterface.fireRequest(request, successClosure: {
                (response) -> Void in
                success?(response: response)
            }) {(error) -> Void in
                failure?(error: error)
            }
    }

    //MARK: - Auth Test
    public func authenticationTestRequest() -> NSURLRequest? {
        return networkInterface.requestFromEndpoint(.AuthTest, token: token, parameters: nil)
    }

    public func authenticationTest(success: ((authenticated: Bool) -> Void)?, failure: FailureClosure?) {
        let request = authenticationTestRequest()
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(authenticated: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Channels
    public func channelHistoryRequest(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> NSURLRequest? {
        return historyRequest(.ChannelsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
    }

    public func channelHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((history: History) -> Void)?, failure: FailureClosure?) {
        let request = channelHistoryRequest(id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        history(request, success: success, failure: failure)
    }

    public func channelInfoRequest(id: String) -> NSURLRequest? {
        return infoRequest(.ChannelsInfo, id: id)
    }

    public func channelInfo(id: String, success: ((channel: Channel) -> Void)?, failure: FailureClosure?) {
        let request = channelInfoRequest(id)
        info(request, type:ChannelType.Channel, success: {
            (channel) -> Void in
                success?(channel: channel)
            }) { (error) -> Void in
                failure?(error: error)
        }
    }

    public func channelsListRequest(excludeArchived: Bool = false) -> NSURLRequest? {
        return listRequest(.ChannelsList, excludeArchived: excludeArchived)
    }

    public func channelsList(excludeArchived: Bool = false, success: ((channels: [[String: AnyObject]]?) -> Void)?, failure: FailureClosure?) {
        let request = channelsListRequest(excludeArchived)
        list(request, type:ChannelType.Channel, success: {
            (channels) -> Void in
                success?(channels: channels)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func markChannelRequest(channel: String, timestamp: String) -> NSURLRequest? {
        return markRequest(.ChannelsMark, channel: channel, timestamp: timestamp)
    }

    public func markChannel(channel: String, timestamp: String, success: ((ts: String) -> Void)?, failure: FailureClosure?) {
        let request = markChannelRequest(channel, timestamp: timestamp)
        mark(request, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(ts:timestamp)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func setChannelPurposeRequest(channel: String, purpose: String) -> NSURLRequest? {
        return setInfoRequest(.ChannelsSetPurpose, type: .Purpose, channel: channel, text: purpose)
    }

    public func setChannelPurpose(channel: String, purpose: String, success: ((purposeSet: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setChannelPurposeRequest(channel, purpose: purpose)
        setInfo(request, success: {
            (purposeSet) -> Void in
                success?(purposeSet: purposeSet)
            }) { (error) -> Void in
                failure?(error: error)
        }
    }

    public func setChannelTopicRequest(channel: String, topic: String) -> NSURLRequest? {
        return setInfoRequest(.ChannelsSetTopic, type: .Topic, channel: channel, text: topic)
    }

    public func setChannelTopic(channel: String, topic: String, success: ((topicSet: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setChannelTopicRequest(channel, topic: topic)
        setInfo(request, success: {
            (topicSet) -> Void in
                success?(topicSet: topicSet)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Messaging
    public func deleteMessageRequest(channel: String, ts: String) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["channel": channel, "ts": ts]
        return networkInterface.requestFromEndpoint(.ChatDelete, token: token, parameters: parameters)
    }

    public func deleteMessage(channel: String, ts: String, success: ((deleted: Bool) -> Void)?, failure: FailureClosure?) {
        let request = deleteMessageRequest(channel, ts: ts)
        networkInterface.fireRequest(request, successClosure: { (response) -> Void in
                success?(deleted: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func sendMessageRequest(channel: String, text: String, username: String? = nil, asUser: Bool? = nil, parse: ParseMode? = nil, linkNames: Bool? = nil, attachments: [Attachment?]? = nil, unfurlLinks: Bool? = nil, unfurlMedia: Bool? = nil, iconURL: String? = nil, iconEmoji: String? = nil) -> NSURLRequest? {
        let parameters: [String: AnyObject?] = ["channel":channel, "text":text.slackFormatEscaping(), "as_user":asUser, "parse":parse?.rawValue, "link_names":linkNames, "unfurl_links":unfurlLinks, "unfurlMedia":unfurlMedia, "username":username, "attachments":encodeAttachments(attachments), "icon_url":iconURL, "icon_emoji":iconEmoji]
        return networkInterface.requestFromEndpoint(.ChatPostMessage, token: token, parameters: filterNilParameters(parameters))
    }

    public func sendMessage(channel: String, text: String, username: String? = nil, asUser: Bool? = nil, parse: ParseMode? = nil, linkNames: Bool? = nil, attachments: [Attachment?]? = nil, unfurlLinks: Bool? = nil, unfurlMedia: Bool? = nil, iconURL: String? = nil, iconEmoji: String? = nil, success: (((ts: String?, channel: String?)) -> Void)?, failure: FailureClosure?) {
        let request = sendMessageRequest(channel, text: text, username: username, asUser: asUser, parse: parse, linkNames: linkNames, attachments: attachments, unfurlLinks: unfurlLinks, unfurlMedia: unfurlMedia, iconURL: iconURL, iconEmoji: iconEmoji)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?((ts: response["ts"] as? String, response["channel"] as? String))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func updateMessageRequest(channel: String, ts: String, message: String, attachments: [Attachment?]? = nil, parse: ParseMode = .None, linkNames: Bool = false) -> NSURLRequest? {
        let parameters: [String: AnyObject?] = ["channel": channel, "ts": ts, "text": message.slackFormatEscaping(), "parse": parse.rawValue, "link_names": linkNames, "attachments":encodeAttachments(attachments)]
        return networkInterface.requestFromEndpoint(.ChatUpdate, token: token, parameters: filterNilParameters(parameters))
    }

    public func updateMessage(channel: String, ts: String, message: String, attachments: [Attachment?]? = nil, parse: ParseMode = .None, linkNames: Bool = false, success: ((updated: Bool) -> Void)?, failure: FailureClosure?) {
        let request = updateMessageRequest(channel, ts: ts, message: message, attachments: attachments, parse: parse, linkNames: linkNames)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(updated: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Do Not Disturb
    public func dndInfoRequest(user: String? = nil) -> NSURLRequest? {
        let parameters: [String: AnyObject?] = ["user": user]
        return networkInterface.requestFromEndpoint(.DNDInfo, token: token, parameters: filterNilParameters(parameters))
    }

    public func dndInfo(user: String? = nil, success: ((status: DoNotDisturbStatus) -> Void)?, failure: FailureClosure?) {
        let request = dndInfoRequest(user)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(status: DoNotDisturbStatus(status: response))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func dndTeamInfoRequest(users: [String]? = nil) -> NSURLRequest? {
        let parameters: [String: AnyObject?] = ["users":users?.joinWithSeparator(",")]
        return networkInterface.requestFromEndpoint(.DNDTeamInfo, token: token, parameters: filterNilParameters(parameters))
    }

    public func dndTeamInfo(users: [String]? = nil, success: ((statuses: [String: DoNotDisturbStatus]) -> Void)?, failure: FailureClosure?) {
        let request = dndTeamInfoRequest(users)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                guard let usersDictionary = response["users"] as? [String: AnyObject] else {
                    success?(statuses: [:])
                    return
                }
                success?(statuses: self.enumerateDNDStatuses(usersDictionary))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Emoji
    public func emojiListRequest() -> NSURLRequest? {
        return networkInterface.requestFromEndpoint(.EmojiList, token: token, parameters: nil)
    }

    public func emojiList(success: ((emojiList: [String: AnyObject]?) -> Void)?, failure: FailureClosure?) {
        let request = emojiListRequest()
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(emojiList: response["emoji"] as? [String: AnyObject])
            }) { (error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Files
    public func deleteFileRequest(fileID: String) -> NSURLRequest? {
        let parameters = ["file": fileID]
        return networkInterface.requestFromEndpoint(.FilesDelete, token: token, parameters: parameters)
    }

    public func deleteFile(fileID: String, success: ((deleted: Bool) -> Void)?, failure: FailureClosure?) {
        let request = deleteFileRequest(fileID)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(deleted: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func fileInfoRequest(fileID: String, commentCount: Int = 100, totalPages: Int = 1) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["file":fileID, "count": commentCount, "totalPages":totalPages]
        return networkInterface.requestFromEndpoint(.FilesInfo, token: token, parameters: parameters)
    }

    public func fileInfo(fileID: String, commentCount: Int = 100, totalPages: Int = 1, success: ((file: File) -> Void)?, failure: FailureClosure?) {
        let request = fileInfoRequest(fileID, commentCount: commentCount, totalPages: totalPages)
        networkInterface.fireRequest(request, successClosure: {
            (response) in
                var file = File(file: response["file"] as? [String: AnyObject])
                (response["comments"] as? [[String: AnyObject]])?.forEach { comment in
                    let comment = Comment(comment: comment)
                    if let id = comment.id {
                        file.comments[id] = comment
                    }
                }
                success?(file: file)
            }) {(error) in
                failure?(error: error)
        }
    }

    public func uploadFile(file: NSData, filename: String, filetype: String = "auto", title: String? = nil, initialComment: String? = nil, channels: [String]? = nil, success: ((file: File) -> Void)?, failure: FailureClosure?) {
        let parameters: [String: AnyObject?] = ["file":file, "filename": filename, "filetype":filetype, "title":title, "initial_comment":initialComment, "channels":channels?.joinWithSeparator(",")]
        networkInterface.uploadRequest(token, data: file, parameters: filterNilParameters(parameters), successClosure: {
            (response) -> Void in
                success?(file: File(file: response["file"] as? [String: AnyObject]))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - File Comments
    public func addFileCommentRequest(fileID: String, comment: String) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["file":fileID, "comment":comment.slackFormatEscaping()]
        return networkInterface.requestFromEndpoint(.FilesCommentsAdd, token: token, parameters: parameters)
    }

    public func addFileComment(fileID: String, comment: String, success: ((comment: Comment) -> Void)?, failure: FailureClosure?) {
        let request = addFileCommentRequest(fileID, comment: comment)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(comment: Comment(comment: response["comment"] as? [String: AnyObject]))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func editFileCommentRequest(fileID: String, commentID: String, comment: String) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["file":fileID, "id":commentID, "comment":comment.slackFormatEscaping()]
        return networkInterface.requestFromEndpoint(.FilesCommentsEdit, token: token, parameters: parameters)
    }

    public func editFileComment(fileID: String, commentID: String, comment: String, success: ((comment: Comment) -> Void)?, failure: FailureClosure?) {
        let request = editFileCommentRequest(fileID, commentID: commentID, comment: comment)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
            success?(comment: Comment(comment: response["comment"] as? [String: AnyObject]))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func deleteFileCommentRequest(fileID: String, commentID: String) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["file":fileID, "id": commentID]
        return networkInterface.requestFromEndpoint(.FilesCommentsDelete, token: token, parameters: parameters)
    }

    public func deleteFileComment(fileID: String, commentID: String, success: ((deleted: Bool?) -> Void)?, failure: FailureClosure?) {
        let request = deleteFileCommentRequest(fileID, commentID: commentID)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(deleted: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Groups
    public func closeGroupRequest(groupID: String) -> NSURLRequest? {
        return closeRequest(.GroupsClose, channelID: groupID)
    }

    public func closeGroup(groupID: String, success: ((closed: Bool) -> Void)?, failure: FailureClosure?) {
        let request = closeGroupRequest(groupID)
        close(request, success: {
            (closed) -> Void in
                success?(closed:closed)
            }) {(error) -> Void in
                failure?(error:error)
        }
    }

    public func groupHistoryRequest(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> NSURLRequest? {
        return historyRequest(.GroupsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
    }

    public func groupHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((history: History) -> Void)?, failure: FailureClosure?) {
        let request = groupHistoryRequest(id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        history(request, success: {
            (history) -> Void in
                success?(history: history)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func groupInfoRequest(id: String) -> NSURLRequest? {
        return infoRequest(.GroupsInfo, id: id)
    }

    public func groupInfo(id: String, success: ((channel: Channel) -> Void)?, failure: FailureClosure?) {
        let request = groupInfoRequest(id)
        info(request, type:ChannelType.Group, success: {
            (channel) -> Void in
                success?(channel: channel)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func groupsListRequest(excludeArchived: Bool = false) -> NSURLRequest? {
        return listRequest(.GroupsList, excludeArchived: excludeArchived)
    }

    public func groupsList(excludeArchived: Bool = false, success: ((channels: [[String: AnyObject]]?) -> Void)?, failure: FailureClosure?) {
        let request = groupsListRequest(excludeArchived)
        list(request, type:ChannelType.Group, success: {
            (channels) -> Void in
                success?(channels: channels)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func markGroupRequest(channel: String, timestamp: String) -> NSURLRequest? {
        return markRequest(.GroupsMark, channel: channel, timestamp: timestamp)
    }

    public func markGroup(channel: String, timestamp: String, success: ((ts: String) -> Void)?, failure: FailureClosure?) {
        let request = markGroupRequest(channel, timestamp: timestamp)
        mark(request, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(ts: timestamp)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func openGroupRequest(channel: String) -> NSURLRequest? {
        let parameters = ["channel":channel]
        return networkInterface.requestFromEndpoint(.GroupsOpen, token: token, parameters: parameters)
    }

    public func openGroup(channel: String, success: ((opened: Bool) -> Void)?, failure: FailureClosure?) {
        let request = openGroupRequest(channel)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(opened: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func setGroupPurposeRequest(channel: String, purpose: String) -> NSURLRequest? {
        return setInfoRequest(.GroupsSetPurpose, type: .Purpose, channel: channel, text: purpose)
    }

    public func setGroupPurpose(channel: String, purpose: String, success: ((purposeSet: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setGroupPurposeRequest(channel, purpose: purpose)
        setInfo(request, success: {
            (purposeSet) -> Void in
                success?(purposeSet: purposeSet)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func setGroupTopicRequest(channel: String, topic: String) -> NSURLRequest? {
        return setInfoRequest(.GroupsSetTopic, type: .Topic, channel: channel, text: topic)
    }

    public func setGroupTopic(channel: String, topic: String, success: ((topicSet: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setGroupTopicRequest(channel, topic: topic)
        setInfo(request, success: {
            (topicSet) -> Void in
                success?(topicSet: topicSet)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - IM
    public func closeIMRequest(channel: String) -> NSURLRequest? {
        return closeRequest(.IMClose, channelID: channel)
    }

    public func closeIM(channel: String, success: ((closed: Bool) -> Void)?, failure: FailureClosure?) {
        let request = closeIMRequest(channel)
        close(request, success: {
            (closed) -> Void in
                success?(closed: closed)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func imHistoryRequest(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> NSURLRequest? {
        return historyRequest(.IMHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
    }

    public func imHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((history: History) -> Void)?, failure: FailureClosure?) {
        let request = imHistoryRequest(id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        history(request, success: {
            (history) -> Void in
                success?(history: history)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func imsListRequest(excludeArchived: Bool = false) -> NSURLRequest? {
        return listRequest(.IMList, excludeArchived: excludeArchived)
    }

    public func imsList(excludeArchived: Bool = false, success: ((channels: [[String: AnyObject]]?) -> Void)?, failure: FailureClosure?) {
        let request = imsListRequest(excludeArchived)
        list(request, type:ChannelType.IM, success: {
            (channels) -> Void in
                success?(channels: channels)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func markIMRequest(channel: String, timestamp: String) -> NSURLRequest? {
        return markRequest(.IMMark, channel: channel, timestamp: timestamp)
    }

    public func markIM(channel: String, timestamp: String, success: ((ts: String) -> Void)?, failure: FailureClosure?) {
        let request = markIMRequest(channel, timestamp: timestamp)
        mark(request, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(ts: timestamp)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func openIMRequest(userID: String) -> NSURLRequest? {
        let parameters = ["user":userID]
        return networkInterface.requestFromEndpoint(.IMOpen, token: token, parameters: parameters)
    }

    public func openIM(userID: String, success: ((imID: String?) -> Void)?, failure: FailureClosure?) {
        let request = openIMRequest(userID)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                let group = response["channel"] as? [String: AnyObject]
                success?(imID: group?["id"] as? String)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - MPIM
    public func closeMPIMRequest(channel: String) -> NSURLRequest? {
        return closeRequest(.MPIMClose, channelID: channel)
    }

    public func closeMPIM(channel: String, success: ((closed: Bool) -> Void)?, failure: FailureClosure?) {
        let request = closeMPIMRequest(channel)
        close(request, success: {
            (closed) -> Void in
                success?(closed: closed)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func mpimHistoryRequest(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> NSURLRequest? {
        return historyRequest(.MPIMHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
    }

    public func mpimHistory(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((history: History) -> Void)?, failure: FailureClosure?) {
        let request = mpimHistoryRequest(id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads)
        history(request, success: {
            (history) -> Void in
                success?(history: history)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func mpimsListRequest(excludeArchived: Bool = false) -> NSURLRequest? {
        return listRequest(.MPIMList, excludeArchived: excludeArchived)
    }

    public func mpimsList(excludeArchived: Bool = false, success: ((channels: [[String: AnyObject]]?) -> Void)?, failure: FailureClosure?) {
        let request = mpimsListRequest(excludeArchived)
        list(request, type:ChannelType.Group, success: {
            (channels) -> Void in
                success?(channels: channels)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func markMPIMRequest(channel: String, timestamp: String) -> NSURLRequest? {
        return markRequest(.MPIMMark, channel: channel, timestamp: timestamp)
    }

    public func markMPIM(channel: String, timestamp: String, success: ((ts: String) -> Void)?, failure: FailureClosure?) {
        let request = markMPIMRequest(channel, timestamp: timestamp)
        mark(request, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(ts: timestamp)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func openMPIMRequest(userIDs: [String]) -> NSURLRequest? {
        let parameters = ["users":userIDs.joinWithSeparator(",")]
        return networkInterface.requestFromEndpoint(.MPIMOpen, token: token, parameters: parameters)
    }

    public func openMPIM(userIDs: [String], success: ((mpimID: String?) -> Void)?, failure: FailureClosure?) {
        let request = openMPIMRequest(userIDs)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                let group = response["group"] as? [String: AnyObject]
                success?(mpimID: group?["id"] as? String)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Pins
    public func pinItemRequest(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil) -> NSURLRequest? {
        return pinRequest(.PinsAdd, channel: channel, file: file, fileComment: fileComment, timestamp: timestamp)
    }

    public func pinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: ((pinned: Bool) -> Void)?, failure: FailureClosure?) {
        let request = pinItemRequest(channel, file: file, fileComment: fileComment, timestamp: timestamp)
        pin(request, success: {
            (ok) -> Void in
                success?(pinned: ok)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func unpinItemRequest(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil) -> NSURLRequest? {
        return pinRequest(.PinsRemove, channel: channel, file: file, fileComment: fileComment, timestamp: timestamp)
    }

    public func unpinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: ((unpinned: Bool) -> Void)?, failure: FailureClosure?) {
        let request = unpinItemRequest(channel, file: file, fileComment: fileComment, timestamp: timestamp)
        pin(request, success: {
            (ok) -> Void in
                success?(unpinned: ok)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    private func pinRequest(endpoint: SlackAPIEndpoint, channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil) -> NSURLRequest? {
        let parameters: [String: AnyObject?] = ["channel":channel, "file":file, "file_comment":fileComment, "timestamp":timestamp]
        return networkInterface.requestFromEndpoint(endpoint, token: token, parameters: filterNilParameters(parameters))
    }

    private func pin(request: NSURLRequest?, success: ((ok: Bool) -> Void)?, failure: FailureClosure?) {
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(ok: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Reactions
    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func addReactionRequest(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil) -> NSURLRequest? {
        return reactRequest(.ReactionsAdd, name: name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
    }

    public func addReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((reacted: Bool) -> Void)?, failure: FailureClosure?) {
        let request = addReactionRequest(name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
        react(request, success: {
            (ok) -> Void in
                success?(reacted: ok)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func removeReactionRequest(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil) -> NSURLRequest? {
        return reactRequest(.ReactionsRemove, name: name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
    }

    public func removeReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((unreacted: Bool) -> Void)?, failure: FailureClosure?) {
        let request = removeReactionRequest(name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
        react(request, success: {
            (ok) -> Void in
            success?(unreacted: ok)
        }) {(error) -> Void in
            failure?(error: error)
        }
    }

    private func reactRequest(endpoint: SlackAPIEndpoint, name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil) -> NSURLRequest? {
        let parameters: [String: AnyObject?] = ["name":name, "file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        return networkInterface.requestFromEndpoint(endpoint, token: token, parameters: filterNilParameters(parameters))
    }

    private func react(request: NSURLRequest?, success: ((ok: Bool) -> Void)?, failure: FailureClosure?) {
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(ok: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Stars
    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func addStarRequest(file: String? = nil, fileComment: String? = nil, channel: String?  = nil, timestamp: String? = nil) -> NSURLRequest? {
        return starRequest(.StarsAdd, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
    }

    public func addStar(file: String? = nil, fileComment: String? = nil, channel: String?  = nil, timestamp: String? = nil, success: ((starred: Bool) -> Void)?, failure: FailureClosure?) {
        let request = addStarRequest(file, fileComment: fileComment, channel: channel, timestamp: timestamp)
        star(request, success: {
            (ok) -> Void in
                success?(starred: ok)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func removeStarRequest(file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil) -> NSURLRequest? {
        return starRequest(.StarsRemove, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp)
    }

    public func removeStar(file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((unstarred: Bool) -> Void)?, failure: FailureClosure?) {
        let request = removeStarRequest(file, fileComment: fileComment, channel: channel, timestamp: timestamp)
        star(request, success: {
            (ok) -> Void in
                success?(unstarred: ok)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    private func starRequest(endpoint: SlackAPIEndpoint, file: String?, fileComment: String?, channel: String?, timestamp: String?) -> NSURLRequest? {
        let parameters: [String: AnyObject?] = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        return networkInterface.requestFromEndpoint(endpoint, token: token, parameters: filterNilParameters(parameters))
    }

    private func star(request: NSURLRequest?, success: ((ok: Bool) -> Void)?, failure: FailureClosure?) {
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(ok: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Team
    public func teamInfoRequest() -> NSURLRequest? {
        return networkInterface.requestFromEndpoint(.TeamInfo, token: token, parameters: nil)
    }

    public func teamInfo(success: ((info: [String: AnyObject]?) -> Void)?, failure: FailureClosure?) {
        let request = teamInfoRequest()
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(info: response["team"] as? [String: AnyObject])
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Users
    public func userPresenceRequest(user: String) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["user":user]
        return networkInterface.requestFromEndpoint(.UsersGetPresence, token: token, parameters: parameters)
    }

    public func userPresence(user: String, success: ((presence: String?) -> Void)?, failure: FailureClosure?) {
        let request = userPresenceRequest(user)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(presence: response["presence"] as? String)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func userInfoRequest(id: String) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["user":id]
        return networkInterface.requestFromEndpoint(.UsersInfo, token: token, parameters: parameters)
    }

    public func userInfo(id: String, success: ((user: User) -> Void)?, failure: FailureClosure?) {
        let request = userInfoRequest(id)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(user: User(user: response["user"] as? [String: AnyObject]))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func usersListRequest(includePresence: Bool = false) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["presence":includePresence]
        return networkInterface.requestFromEndpoint(.UsersList, token: token, parameters: parameters)
    }

    public func usersList(includePresence: Bool = false, success: ((userList: [[String: AnyObject]]?) -> Void)?, failure: FailureClosure?) {
        let request = usersListRequest(includePresence)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(userList: response["members"] as? [[String: AnyObject]])
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func setUserActiveRequest() -> NSURLRequest? {
        return networkInterface.requestFromEndpoint(.UsersSetActive, token: token, parameters: nil)
    }

    public func setUserActive(success: ((success: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setUserActiveRequest()
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(success: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    public func setUserPresenceRequest(presence: Presence) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["presence":presence.rawValue]
        return networkInterface.requestFromEndpoint(.UsersSetPresence, token: token, parameters: parameters)
    }

    public func setUserPresence(presence: Presence, success: ((success: Bool) -> Void)?, failure: FailureClosure?) {
        let request = setUserPresenceRequest(presence)
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(success:true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Channel Utilities
    private func closeRequest(endpoint: SlackAPIEndpoint, channelID: String) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["channel":channelID]
        return networkInterface.requestFromEndpoint(endpoint, token: token, parameters: parameters)
    }

    private func close(request: NSURLRequest?, success: ((closed: Bool) -> Void)?, failure: FailureClosure?) {
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(closed: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    private func historyRequest(endpoint: SlackAPIEndpoint, id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["channel": id, "latest": latest, "oldest": oldest, "inclusive":inclusive, "count":count, "unreads":unreads]
        return networkInterface.requestFromEndpoint(endpoint, token: token, parameters: parameters)
    }

    private func history(request: NSURLRequest?, success: ((history: History) -> Void)?, failure: FailureClosure?) {
        networkInterface.fireRequest(
            request, successClosure: { response in
                success?(history: History(history: response))
            }) { error in
                failure?(error: error)
        }
    }

    private func infoRequest(endpoint: SlackAPIEndpoint, id: String) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["channel": id]
        return networkInterface.requestFromEndpoint(endpoint, token: token, parameters: parameters)
    }

    private func info(request: NSURLRequest?, type: ChannelType, success: ((channel: Channel) -> Void)?, failure: FailureClosure?) {
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(channel: Channel(channel: response[type.rawValue] as? [String: AnyObject]))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    private func listRequest(endpoint: SlackAPIEndpoint, excludeArchived: Bool = false) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["exclude_archived": excludeArchived]
        return networkInterface.requestFromEndpoint(endpoint, token: token, parameters: parameters)
    }

    private func list(request: NSURLRequest?, type: ChannelType, success: ((channels: [[String: AnyObject]]?) -> Void)?, failure: FailureClosure?) {
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(channels: response[type.rawValue+"s"] as? [[String: AnyObject]])
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    private func markRequest(endpoint: SlackAPIEndpoint, channel: String, timestamp: String) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["channel": channel, "ts": timestamp]
        return networkInterface.requestFromEndpoint(endpoint, token: token, parameters: parameters)
    }

    private func mark(request: NSURLRequest?, timestamp: String, success: ((ts: String) -> Void)?, failure: FailureClosure?) {
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(ts: timestamp)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    private func setInfoRequest(endpoint: SlackAPIEndpoint, type: InfoType, channel: String, text: String) -> NSURLRequest? {
        let parameters: [String: AnyObject] = ["channel": channel, type.rawValue: text]
        return networkInterface.requestFromEndpoint(endpoint, token: token, parameters: parameters)
    }

    private func setInfo(request: NSURLRequest?, success: ((success: Bool) -> Void)?, failure: FailureClosure?) {
        networkInterface.fireRequest(request, successClosure: {
            (response) -> Void in
                success?(success: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Filter Nil Parameters
    private func filterNilParameters(parameters: [String: AnyObject?]) -> [String: AnyObject] {
        var finalParameters = [String: AnyObject]()
        for key in parameters.keys {
            if parameters[key] != nil {
                finalParameters[key] = parameters[key]!
            }
        }
        return finalParameters
    }

    //MARK: - Encode Attachments
    private func encodeAttachments(attachments: [Attachment?]?) -> NSString? {
        if let attachments = attachments {
            var attachmentArray: [[String: AnyObject]] = []
            for attachment in attachments {
                if let attachment = attachment {
                    attachmentArray.append(attachment.dictionary())
                }
            }
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(attachmentArray, options: [])
                let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                return string
            } catch _ {

            }
        }
        return nil
    }

    //MARK: - Enumerate Do Not Disturb Status
    private func enumerateDNDStatuses(statuses: [String: AnyObject]) -> [String: DoNotDisturbStatus] {
        var retVal = [String: DoNotDisturbStatus]()
        for key in statuses.keys {
            retVal[key] = DoNotDisturbStatus(status: statuses[key] as? [String: AnyObject])
        }
        return retVal
    }

}
