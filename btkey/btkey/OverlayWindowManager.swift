//
//  OverlayWindowManager.swift
//  btkey
//
//  Created by Aaron Mandle on 11/10/25.
//

import Cocoa
import SwiftUI

class OverlayWindowManager {
    static let shared = OverlayWindowManager()

    private var overlayWindow: NSWindow?
    private var hideTimer: Timer?

    private init() {}

    func showOverlay(status: ConnectionStatus, deviceName: String) {
        DispatchQueue.main.async { [weak self] in
            self?.displayOverlay(status: status, deviceName: deviceName)
        }
    }

    private func displayOverlay(status: ConnectionStatus, deviceName: String) {
        // Cancel any existing hide timer
        hideTimer?.invalidate()

        // Remove existing overlay if present
        overlayWindow?.close()

        // Create the overlay content
        let overlayView = OverlayView(status: status, deviceName: deviceName)
        let hostingController = NSHostingController(rootView: overlayView)

        // Get the main screen
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame

        // Calculate window size and position (centered on screen)
        let windowSize = NSSize(width: 280, height: 180)
        let windowOrigin = NSPoint(
            x: screenFrame.midX - windowSize.width / 2,
            y: screenFrame.midY - windowSize.height / 2
        )
        let windowFrame = NSRect(origin: windowOrigin, size: windowSize)

        // Create the overlay window
        let window = NSPanel(
            contentRect: windowFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        window.level = .statusBar
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentViewController = hostingController

        overlayWindow = window
        window.makeKeyAndOrderFront(nil)

        // Auto-hide after 2 seconds
        hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.hideOverlay()
        }
    }

    func hideOverlay() {
        DispatchQueue.main.async { [weak self] in
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                self?.overlayWindow?.animator().alphaValue = 0
            }, completionHandler: {
                self?.overlayWindow?.close()
                self?.overlayWindow = nil
            })
        }
    }
}

enum ConnectionStatus {
    case connecting
    case connected
    case failed
    case alreadyConnected
    case noDevice

    var icon: String {
        switch self {
        case .connecting:
            return "antenna.radiowaves.left.and.right"
        case .connected:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        case .alreadyConnected:
            return "checkmark.circle"
        case .noDevice:
            return "exclamationmark.triangle.fill"
        }
    }

    var title: String {
        switch self {
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .failed:
            return "Connection Failed"
        case .alreadyConnected:
            return "Already Connected"
        case .noDevice:
            return "No Device Configured"
        }
    }

    var color: Color {
        switch self {
        case .connecting:
            return .blue
        case .connected:
            return .green
        case .failed:
            return .red
        case .alreadyConnected:
            return .orange
        case .noDevice:
            return .yellow
        }
    }
}
