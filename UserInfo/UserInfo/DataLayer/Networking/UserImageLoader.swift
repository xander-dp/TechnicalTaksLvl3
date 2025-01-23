//
//  UserImageLoader.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 22.01.25.
//

import Foundation

final class UserImageLoader: ImageLoader {
    private enum LoaderStatus {
        case inProgress(Task<Data, Error>)
        case fetched(Data)
    }
    
    private let dataRequester: DataHTTPRequester
    private let requestBuilder: APIRequestBuilder
    private var loadedImages: [String: LoaderStatus] = [:]
    
    init(requestBuilder: APIRequestBuilder, dataRequester: DataHTTPRequester) {
        self.requestBuilder = requestBuilder
        self.dataRequester = dataRequester
    }
    
    func getImageData(absoluteURL: String) async throws -> Data {
        guard let urlRequest = requestBuilder.buildRequest(from: absoluteURL)
        else {
            throw APIRequestError.unableToProcessRequest(phase: .create)
        }
        
        if let status = loadedImages[absoluteURL] {
            switch status {
            case .fetched(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }

        let task: Task<Data, Error> = Task {
            try await self.dataRequester.executeRequest(urlRequest: urlRequest)
        }
        
        loadedImages[absoluteURL] = .inProgress(task)
        
        let imageData = try await task.value
        loadedImages[absoluteURL] = .fetched(imageData)
        
        return imageData
    }
}
