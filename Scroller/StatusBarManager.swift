//
//  StatusBarManager.swift
//  Scoller
//
//  Created by Marvin Kicha on 07.10.23.
//  https://github.com/marv-in-k/
//

import Cocoa

class StatusBarManager {
    var statusBarItem: NSStatusItem?

    func setupStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard (statusBarItem?.button) != nil else {
            print("Failed to create status bar item.")
            return
        }
        
        if let button = statusBarItem?.button {
            if let image = NSImage(named: "StatusIcon") {
                image.isTemplate = true // This is important
                button.image = image
            }
        }
        
        let statusBarMenu = NSMenu(title: "Menu")
        statusBarItem?.menu = statusBarMenu
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: "")
        settingsItem.target = self
        statusBarMenu.addItem(settingsItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self
        statusBarMenu.addItem(quitItem)
    }

    @objc func showSettings() {
       // (NSApplication.shared.delegate as? AppDelegate)?.showMainWindow()
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
