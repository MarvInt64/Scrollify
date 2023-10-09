//
//  ScrollerInterpolator.swift
//  Scoller
//
//  Created by Marvin Kicha on 07.10.23.
//  https://github.com/marv-in-k/
//

import SwiftUI

class ScrollInterpolator : ObservableObject {
    @Published var scrollSensitivity: Double = 0.8
    @Published var decelerationRate: Double = 0.15
    @Published var selectedEaseModeName: String = "Quart"
    let easeModeManager = EaseModeManager()
    private var currentScrollVelocity: Double = 0
    private var scrollTimer: Timer?

    
    private var targetScrollVelocity: Double = 0
    private var accumulatedVelocity: Double = 0.0
    private var isProcessingActualScrollEvent: Bool = false
    private var scrollProgress: Double = 0.0
    
    var selectedEaseMode: EaseMode? {
        return easeModeManager.easeModes.first(where: { $0.name == selectedEaseModeName })
    }
    
    init() {
        easeModeManager.register(easeMode: QuartEase())
        easeModeManager.register(easeMode: ElasticEase())
        easeModeManager.register(easeMode: EaseOutBounce())
    }
    
    func interpolate(to newTargetVelocity: Double) -> Double {
        isProcessingActualScrollEvent = true
        targetScrollVelocity = newTargetVelocity
        
        if scrollTimer == nil 
        {
            scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.002, repeats: true) { [weak self] _ in
                self?.applySmoothScrollingEffect()
            }
        }
        
        return targetScrollVelocity
    }

    private func resetScrollProgress() {
        scrollProgress = 0.0
    }
    
    private func applySmoothScrollingEffect() {
        if isProcessingActualScrollEvent {
            currentScrollVelocity = targetScrollVelocity
            resetScrollProgress()
            isProcessingActualScrollEvent = false
        } else {
            scrollProgress += 0.0016
 
            let easingFactor = selectedEaseMode?.easeFunction(x: scrollProgress) ?? 1.0
            let adjustedVelocity = currentScrollVelocity * easingFactor
            let differentialVelocity = adjustedVelocity * (decelerationRate * 8.0)
            
            currentScrollVelocity -= differentialVelocity
            accumulatedVelocity += currentScrollVelocity

            if abs(accumulatedVelocity) >= 1.0
            {
                postArtificialScrollEvent(with: accumulatedVelocity)
                accumulatedVelocity = 0.0
            }

            if abs(currentScrollVelocity) < 0.1
            {
                scrollTimer?.invalidate()
                scrollTimer = nil
                currentScrollVelocity = 0
            }
        }
    }
    
    private func postArtificialScrollEvent(with velocity: Double)
    {
        let clampedVelocity = max(min(velocity, Double(Int32.max)), Double(Int32.min))
        if let newEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: Int32(clampedVelocity), wheel2: 0, wheel3: 0)
        {
            newEvent.setIntegerValueField(.eventSourceUserData, value: artificialEventTag)
            newEvent.post(tap: .cghidEventTap)
        }
    }
}
