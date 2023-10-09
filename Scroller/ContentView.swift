//
//  ContentView.swift
//  Scroller
//
//  Created by Marvin Kicha on 07.10.23.
//

import SwiftUI
import Cocoa

let artificialEventTag: Int64 = 0x7BCDABCDABCDABCD

func myCGEventCallback(tapProxy: CGEventTapProxy,
                       eventType: CGEventType,
                       event: CGEvent,
                       userInfo: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? 
{
    guard let userInfo = userInfo else { return Unmanaged.passRetained(event) }
    let interpolatorInstance = Unmanaged<ScrollInterpolator>.fromOpaque(userInfo).takeUnretainedValue()

    if event.getIntegerValueField(.eventSourceUserData) == artificialEventTag 
    {
        return Unmanaged.passRetained(event)
    }
    
    if eventType == .scrollWheel 
    {
        let rawScroll = Double(event.getIntegerValueField(.scrollWheelEventDeltaAxis1))
        let adjustedScroll = rawScroll * interpolatorInstance.scrollSensitivity
        
        _ = interpolatorInstance.interpolate(to: adjustedScroll)

        return nil
    }
    
    return Unmanaged.passRetained(event)
}

struct ContentView: View {
    @ObservedObject var controller = ScrollInterpolationController()
    @ObservedObject var interpolator = ScrollInterpolator()

    @State private var scrollSensitivity: Double = 1.0
    @State private var selectedEasingEffect = 0
    @State private var isFeedbackViewPresented = false
    
    let easingEffects = ["Quart", "Elastic", "Bounce"]
    
    init() {
        
        controller.interpolator = interpolator
        loadSettings()
    }
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        if let savedScrollSensitivity = defaults.value(forKey: "scrollSensitivity") as? Double {
            interpolator.scrollSensitivity = savedScrollSensitivity
        }
        
        if let savedDecelerationRate = defaults.value(forKey: "decelerationRate") as? Double {
            interpolator.decelerationRate = savedDecelerationRate
        }
        
        if let savedIsSmoothScrollingActive = defaults.value(forKey: "isSmoothScrollingActive") as? Bool {
            controller.isSmoothScrollingActive = savedIsSmoothScrollingActive
        }
    }

    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(interpolator.scrollSensitivity, forKey: "scrollSensitivity")
        defaults.set(interpolator.decelerationRate, forKey: "decelerationRate")
        defaults.set(controller.isSmoothScrollingActive, forKey: "isSmoothScrollingActive")
    }

    var body: some View {
        VStack(spacing: 15) {
            Toggle("Activate Smooth Scrolling", isOn: $controller.isSmoothScrollingActive)
                .padding(.top, 30)
                .padding()
                .onChange(of: controller.isSmoothScrollingActive) {
                    saveSettings()
                }

            Slider(value: $interpolator.decelerationRate, in: 0.05...1.0, step: 0.05) {
                Text("Deceleration Rate")
            }
            .padding(.horizontal)
            .accentColor(.blue)
            .onChange(of: interpolator.decelerationRate) {
                saveSettings()
            }

            Text("Deceleration Rate: \(interpolator.decelerationRate, specifier: "%.2f")")
                .font(.footnote)

            Slider(value: $interpolator.scrollSensitivity, in: 0.1...2.0, step: 0.1) {
                Text("Scroll Sensitivity")
            }
            .padding(.horizontal)
            .accentColor(.blue)
            .onChange(of: interpolator.scrollSensitivity) {
                saveSettings()
            }

            Text("Scroll Sensitivity: \(interpolator.scrollSensitivity, specifier: "%.2f")")
                .font(.footnote)

            Picker("Easing Effect", selection: $interpolator.selectedEaseModeName) {
                ForEach(interpolator.easeModeManager.easeModes, id: \.name) { easeMode in
                    Text(easeMode.name).tag(easeMode.name)
                }
            }
            .padding(.horizontal)
            .pickerStyle(SegmentedPickerStyle())

            Text("Test Area")
                .font(.title)
                .padding(.top)
            
            ScrollView {
                VStack {
                    ForEach(0..<50) { i in
                        Text("Item \(i)")
                            .frame(maxWidth: .infinity) // Add this line
                            .padding()
                            .background(Color.gray.opacity(0.4))
                            .cornerRadius(8)
                    }
                }
            }
            .frame(maxWidth: .infinity) // Add this line
            .frame(height: 200)
            .border(Color.gray, width: 1)
            
            Spacer()
            
            Button(action: {
                isFeedbackViewPresented.toggle()
            }) {
                Text("Provide Feedback")
                    .foregroundColor(.blue)
            }
            
            if isFeedbackViewPresented {
               FeedbackView()
                   .background(Color.white) // Optional: Add background color
                   .frame(maxWidth: .infinity, maxHeight: .infinity)
                   .transition(.move(edge: .bottom)) // Optional: Add transition animation
                   .zIndex(1) // Optional: Bring the view to the front
           }
        }
        .frame(width: 400)
        .padding()
        .overlay(
            HStack(spacing: 10) {
                   // Settings Button
                   Button(action: {
                       // Your settings action here
                       print("Settings tapped!")
                   }) {
                       Image(systemName: "gearshape")
                           .font(.system(size: 20.0))
                           .foregroundColor(.secondary) // or any other color you prefer
                   }
                   .buttonStyle(PlainButtonStyle())
                   
                   // Quit Button
                   Button(action: {
                       NSApplication.shared.terminate(nil)
                   }) {
                       Image(systemName: "xmark.circle")
                           .font(.system(size: 20.0))
                           .foregroundColor(Color("OrangeRed"))
                   }
                   .buttonStyle(PlainButtonStyle())
               }
               .padding(),
               alignment: .topTrailing
        )
    }
}

struct FeedbackView: View {
    @State private var feedbackText = ""
    
    var body: some View {
        VStack {
            Text("Feedback")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            TextEditor(text: $feedbackText)
                .border(Color.gray, width: 1)
                .padding()
            
            Button(action: {
                // Handle feedback submission
            }) {
                Text("Submit")
            }
            .padding()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
