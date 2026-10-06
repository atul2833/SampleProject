//
//  MultipartRequest.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//
import Foundation
import UniformTypeIdentifiers
import MobileCoreServices

struct MultipartRequest {
    private var data = NSMutableData()

    private let boundary: String = UUID().uuidString
    private let separator: String = "\r\n"

    private var topBoundry: String {
        return "--\(boundary)"
    }

    private var endBoundry: String {
        return "--\(boundary)--"
    }

    private func contentDisposition(_ name: String, fileName: String?) -> String {
        var disposition = "form-data; name=\"\(name)\""
        if let fileName = fileName { disposition += "; filename=\"\(fileName)\"" }
        return "Content-Disposition: " + disposition
    }

    var headerValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    var httpBody: Data {
        let bodyData = data
        bodyData.append("--\(boundary)--")
        return bodyData as Data
    }

    var length: UInt64 {
        return UInt64(httpBody.count)
    }

    func append(fileData: Data, withName name: String, fileName: String?, mimeType: FileType?) {
        data.append(topBoundry)
        data.append(separator)
        data.append(contentDisposition(name, fileName: fileName))
        data.append(separator)
        if let mimeType = mimeType {
            data.append("Content-Type: \(mimeType.rawValue)" + separator)
        }
        data.append(separator)
        data.append(fileData)
        data.append(separator)
    }
    
    func append(parameters: [String: String],fileDatas: [Data], withName name: String, fileNames: [String], mimeType: FileType) {
        
            for (key, value) in parameters {
                data.append(topBoundry)
                data.append(separator)
                data.append("Content-Disposition: form-data; name=\"\(key)\"")
                data.append(separator)
                data.append(separator)
                data.append(value)
                data.append(separator)
            }
        
            guard fileDatas.count == fileNames.count else {
                return // Bail out if counts do not match
            }
            
            for (index, fileData) in fileDatas.enumerated() {
                let fileName = fileNames[index]
                
                data.append(topBoundry)
                data.append(separator)
                data.append(contentDisposition(name, fileName: fileName))
                data.append(separator)
                data.append("Content-Type: \(mimeType.rawValue)" + separator)
                
                data.append(separator)
                data.append(fileData)
                data.append(separator)
            }
        }
    
    func append(parameters: [String: String],parametersArray: [String: [String]],parametersObjects: [String: [String:String]],fileDatas: [Data], withName name: String, fileNames: [String], mimeTypes: [FileType]) {
        
            for (key, value) in parameters {
                data.append(topBoundry)
                data.append(separator)
                data.append("Content-Disposition: form-data; name=\"\(key)\"")
                data.append(separator)
                data.append(separator)
                data.append(value)
                data.append(separator)
            }
        
        // Append parameters with arrays of strings
            for (key, values) in parametersArray {
                for value in values {
                    data.append(topBoundry.data(using: .utf8)!)
                    data.append(separator.data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\(key)\"".data(using: .utf8)!)
                    data.append(separator.data(using: .utf8)!)
                    data.append(separator.data(using: .utf8)!)
                    data.append(value.data(using: .utf8)!)
                    data.append(separator.data(using: .utf8)!)
                }
            }

            // Append parameters with dictionaries of strings
        for (key, valueDict) in parametersObjects {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: valueDict, options: [])
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        data.append(topBoundry.data(using: .utf8)!)
                        data.append(separator)
                        data.append("Content-Disposition: form-data; name=\"\(key)\"")
                        data.append(separator)
                        data.append("Content-Type: application/json")
                        data.append(separator)
                        data.append(separator)
                        data.append(jsonString)
                        data.append(separator)
                    }
                } catch {
                    print("Error serializing JSON: \(error)")
                }
            }

        
            guard fileDatas.count == fileNames.count else {
                return // Bail out if counts do not match
            }
            
            for (index, fileData) in fileDatas.enumerated() {
                let fileName = fileNames[index]
                let mimeType = mimeTypes[index]

                data.append(topBoundry)
                data.append(separator)
                data.append(contentDisposition(name, fileName: fileName))
                data.append(separator)
                data.append("Content-Type: \(mimeType.rawValue)" + separator)
                
                data.append(separator)
                data.append(fileData)
                data.append(separator)
            }
        }
}

extension MultipartRequest {
    private func mimeType(for pathExtension: String) -> String {
        if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *) {
            return UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "application/octet-stream"
        } else {
            if
                let id = UTTypeCreatePreferredIdentifierForTag(
                    kUTTagClassFilenameExtension,
                    pathExtension as CFString,
                    nil
                )?.takeRetainedValue(),
                let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
            {
                return contentType as String
            }

            return "application/octet-stream"
        }
    }
}

enum FileType: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case gif = "image/gif"
    case tiff = "image/tiff"
    case bmp = "image/bmp"
    case quickTime = "video/quicktime"
    case mov = "video/mov"
    case mp4 = "video/mp4"
    case pdf = "application/pdf"
    case vnd = "application/vnd"
    case plainText = "text/plain"
    case anyBinary = "application/octet-stream"
}
