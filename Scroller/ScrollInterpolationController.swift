//
//  ScrollerController.swift
//  Scoller
//
//  Created by Marvin K on 07.10.23.
//  https://github.com/marv-in-k/
//

import SwiftUI

class ScrollInterpolationController: ObservableObject {
    var interpolator: ScrollInterpolator!
    private var eventMonitor: Any?
    private var eventTap: CFMachPort?
    
    @Published var isSmoothScrollingActive: Bool = false
    {
        didSet
        {
            isSmoothScrollingActive ? start() : stop()
        }
    }

    private func start()
    {
        let scrollEventMask = CGEventMask(1 << CGEventType.scrollWheel.rawValue)
        eventTap = CGEvent.tapCreate(tap: .cghidEventTap,
                                     place: .headInsertEventTap,
                                     options: .defaultTap,
                                     eventsOfInterest: scrollEventMask,
                                     callback: myCGEventCallback,
                                     userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(interpolator).toOpaque()))
        guard let tap = eventTap else { return }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
    }
}
