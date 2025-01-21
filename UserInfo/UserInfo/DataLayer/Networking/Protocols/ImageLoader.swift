//
//  ImageLoader.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 21.01.25.
//

import Foundation

protocol ImageLoader {
    func getImageData(absoluteURL: String) async throws -> Data
}
