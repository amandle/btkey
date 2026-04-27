//
//  OverlayWindowManager.swift
//  btkey
//
//  Created by Aaron Mandle on 11/10/25.
//

import Cocoa
import Combine
import SwiftUI

final class OverlayViewModel: ObservableObject {
    @Published var status: ConnectionStatus = .connecting
    @Published var deviceName: String = ""
    @Published var battery: BatteryInfo?
}

class OverlayWindowManager {
    static let shared = OverlayWindowManager()

    private var overlayWindow: NSWindow?
    private var viewModel: OverlayViewModel?
    private var hideTimer: Timer?

    private init() {}

    func showOverlay(status: ConnectionStatus, deviceName: String) {
        DispatchQueue.main.async { [weak self] in
            self?.displayOverlay(status: status, deviceName: deviceName)
        }
    }

    func updateBattery(_ battery: BatteryInfo?) {
        DispatchQueue.main.async { [weak self] in
            guard let viewModel = self?.viewModel else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.battery = battery
            }
        }
    }

    private func displayOverlay(status: ConnectionStatus, deviceName: String) {
        hideTimer?.invalidate()

        if let window = overlayWindow, let viewModel = viewModel {
            // Update in place — no window rebuild
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.status = status
                viewModel.deviceName = deviceName
                // Stale battery from a previous device shouldn't leak into a new dialog.
                if status == .connecting || status == .noDevice || status == .failed {
                    viewModel.battery = nil
                }
            }
            window.alphaValue = 1
            window.orderFrontRegardless()
        } else {
            createWindow(status: status, deviceName: deviceName)
        }

        scheduleHide(for: status)
    }

    private func createWindow(status: ConnectionStatus, deviceName: String) {
        let viewModel = OverlayViewModel()
        viewModel.status = status
        viewModel.deviceName = deviceName

        let overlayView = OverlayView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: overlayView)
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = .clear

        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        let windowSize = NSSize(width: 280, height: 180)
        let windowOrigin = NSPoint(
            x: screenFrame.midX - windowSize.width / 2,
            y: screenFrame.midY - windowSize.height / 2
        )
        let windowFrame = NSRect(origin: windowOrigin, size: windowSize)

        let window = NSPanel(
            contentRect: windowFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        window.level = .statusBar
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentViewController = hostingController

        self.viewModel = viewModel
        self.overlayWindow = window
        window.makeKeyAndOrderFront(nil)
    }

    private func scheduleHide(for status: ConnectionStatus) {
        // Keep "connecting" visible until a terminal status arrives
        guard status != .connecting else { return }

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
                self?.viewModel = nil
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
