//
//  OverlayView.swift
//  btkey
//
//  Created by Aaron Mandle on 11/10/25.
//

import SwiftUI

struct OverlayView: View {
    let status: ConnectionStatus
    let deviceName: String

    var body: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: status.icon)
                .font(.system(size: 48))
                .foregroundColor(status.color)
                .symbolRenderingMode(.hierarchical)

            // Status text
            VStack(spacing: 4) {
                Text(status.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                if !deviceName.isEmpty {
                    Text(deviceName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(width: 280, height: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        OverlayView(status: .connecting, deviceName: "AirPods Pro")
        OverlayView(status: .connected, deviceName: "Sony WH-1000XM4")
        OverlayView(status: .failed, deviceName: "Bose QuietComfort")
        OverlayView(status: .alreadyConnected, deviceName: "AirPods Max")
        OverlayView(status: .noDevice, deviceName: "")
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray.opacity(0.3))
}
