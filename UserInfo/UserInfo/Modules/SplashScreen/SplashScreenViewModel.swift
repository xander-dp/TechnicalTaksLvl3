//
//  SplashScreenViewModel.swift
//  UserInfo
//
//  Created by Oleksandr Savchenko on 17.01.25.
//

import Foundation
import Combine

final class SplashScreenViewModel {
    struct Input {
        let viewReady: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let progress: AnyPublisher<Float, Never>
        let currentStepName: AnyPublisher<String, Never>
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    var initializationCompleted: ((Bool) -> Void)?
    
    private let currentStepNameSubject = PassthroughSubject<String, Never>()
    private let progressSubject = PassthroughSubject<Float, Never>()
    
    private let sessionKeeper: SessionKeeper
    private let steps: [AppInitStep]
    
    init(stepsProvider: AppInitStepsProvider, sessionKeeper: SessionKeeper) {
        self.steps = stepsProvider.getSteps()
        self.sessionKeeper = sessionKeeper
    }
    
    func transform(input: Input) -> Output {
        input.viewReady
            .sink { [weak self] _ in
                self?.performInitSteps()
            }
            .store(in: &cancellables)
        
        let progress = progressSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let stepName = currentStepNameSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let output = Output(
            progress: progress,
            currentStepName: stepName
        )
        
        return output
    }
    
    private func performInitSteps() {
        Task {
            var currentProgress: Float = 0.0
            let progressStep = 1.0 / Float(steps.count)
            for step in steps {
                self.currentStepNameSubject.send(step.name)
                currentProgress += progressStep
                self.progressSubject.send(currentProgress)
                await step.action()
            }
            
            await MainActor.run {
                let hasAliveSesssion = sessionKeeper.getSession() != nil
                self.initializationCompleted?(hasAliveSesssion)
            }
        }
    }
}
