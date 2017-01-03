//
// NetworkInterface.swift
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

internal struct NetworkInterface {
    
    private let apiUrl = "https://slack.com/api/"
    
    internal func request(endpoint: Endpoint, token: String? = nil, parameters: [String: Any]?) -> URLRequest? {
        var requestString = "\(apiUrl)\(endpoint.rawValue)?"
        if let token = token {
            requestString += "token=\(token)"
        }
        if let params = parameters {
            requestString += params.requestStringFromParameters
        }
        guard let url =  URL(string: requestString) else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    internal func fire(request: URLRequest?, successClosure: @escaping ([String: Any]) -> Void, errorClosure: @escaping (SlackError) -> Void) {
        guard let request = request else {
            errorClosure(SlackError.clientNetworkError)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, response, internalError) -> Void in
            do {
                successClosure(try self.handleResponse(data, response: response, internalError: internalError))
            } catch let error {
                errorClosure(error as? SlackError ?? SlackError.unknownError)
            }
        }.resume()
    }
    
    internal func customRequest(_ url: String, data: Data, success: @escaping (Bool)->Void, errorClosure: @escaping (SlackError)->Void) {
        guard let url =  URL(string: url.removePercentEncoding()) else {
            errorClosure(SlackError.clientNetworkError)
            return
        }
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        let contentType = "application/json"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) {
            (data, response, internalError) -> Void in
            if internalError == nil {
                success(true)
            } else {
                errorClosure(SlackError.clientNetworkError)
            }
        }.resume()
    }
    
    internal func uploadRequest(_ token: String, data: Data, parameters: [String: Any]?, successClosure: @escaping ([String: Any])->Void, errorClosure: @escaping (SlackError)->Void) {
        var requestString = "\(apiUrl)\(Endpoint.filesUpload.rawValue)?token=\(token)"
        if let params = parameters {
            requestString = requestString + params.requestStringFromParameters
        }
        guard let url =  URL(string: requestString) else {
            errorClosure(SlackError.clientNetworkError)
            return
        }
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        let boundaryConstant = randomBoundary()
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        let boundaryStart = "--\(boundaryConstant)\r\n"
        let boundaryEnd = "--\(boundaryConstant)--\r\n"
        let contentDispositionString = "Content-Disposition: form-data; name=\"file\"; filename=\"\(parameters!["filename"])\"\r\n"
        let contentTypeString = "Content-Type: \(parameters!["filetype"])\r\n\r\n"

        var requestBodyData: Data = Data()
        requestBodyData.append(boundaryStart.data(using: String.Encoding.utf8)!)
        requestBodyData.append(contentDispositionString.data(using: String.Encoding.utf8)!)
        requestBodyData.append(contentTypeString.data(using: String.Encoding.utf8)!)
        requestBodyData.append(data)
        requestBodyData.append("\r\n".data(using: String.Encoding.utf8)!)
        requestBodyData.append(boundaryEnd.data(using: String.Encoding.utf8)!)
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBodyData as Data

        URLSession.shared.dataTask(with: request) {
            (data, response, internalError) -> Void in
            do {
                successClosure(try self.handleResponse(data, response: response, internalError: internalError))
            } catch let error {
                errorClosure(error as? SlackError ?? SlackError.unknownError)
            }
        }.resume()
    }
    
    private func handleResponse(_ data: Data?, response:URLResponse?, internalError:Error?) throws -> [String: Any] {
        guard let data = data, let response = response as? HTTPURLResponse else {
            throw SlackError.clientNetworkError
        }
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                throw SlackError.clientJSONError
            }
            
            switch response.statusCode {
            case 200:
                if (json["ok"] as! Bool == true) {
                    return json
                } else {
                    if let errorString = json["error"] as? String {
                        throw SlackError(rawValue: errorString) ?? .unknownError
                    } else {
                        throw SlackError.unknownError
                    }
                }
            case 429:
                throw SlackError.tooManyRequests
            default:
                throw SlackError.clientNetworkError
            }
        } catch let error {
            if let slackError = error as? SlackError {
                throw slackError
            } else {
                throw SlackError.unknownError
            }
        }
    }
    
    private func randomBoundary() -> String {
        return String(format: "slackkit.boundary.%08x%08x", arc4random(), arc4random())
    }
}
