//
//  AppInitStepsProvider.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 17.01.25.
//

protocol AppInitStepsProvider {
    func getSteps() -> [AppInitStep]
}

final class AppInitStepsHardcodedProvider: AppInitStepsProvider {
    func getSteps() -> [AppInitStep] {
        hardcodedSteps
    }
    
    //5 actions with 0.6...1.0 seconds awaiting = 3-5 seconds
    private let hardcodedSteps: [AppInitStep] = [
        AppInitStep(name: "Analysing Dependencies...", action: createDefaultAction()),
        AppInitStep(name: "Downloading Dependencies...", action: createDefaultAction()),
        AppInitStep(name: "Initializing Dependencies...", action: createDefaultAction()),
        AppInitStep(name: "Check environment infrastracture...", action: createDefaultAction()),
        AppInitStep(name: "Getting things ready...", action: createDefaultAction())
    ]
    
    private static func createDefaultAction() -> () async -> Void {
        return {
            try! await Task.sleep(nanoseconds: Self.getDefaultRandomInterval())
        }
    }
    
    private static func getDefaultRandomInterval() -> UInt64 {
        let nanoMultiplier: Float = 1_000_000_000.0
        let randomInterval = Float.random(in: (0.6...1.0))
        return UInt64(randomInterval * nanoMultiplier)
    }
}
