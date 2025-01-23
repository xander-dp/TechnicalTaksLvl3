//
//  Logger+Subsystems.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 23.01.25.
//

import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let session = Logger(subsystem: subsystem, category: "session")
    static let dataStorage = Logger(subsystem: subsystem, category: "dataStorage")
    static let dataLoading = Logger(subsystem: subsystem, category: "dataLoading")
}
