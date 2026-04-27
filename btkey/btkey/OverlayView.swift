//
//  OverlayView.swift
//  btkey
//
//  Created by Aaron Mandle on 11/10/25.
//

import SwiftUI

struct OverlayView: View {
    @ObservedObject var viewModel: OverlayViewModel

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.status.icon)
                .font(.system(size: 48))
                .foregroundColor(viewModel.status.color)
                .transition(.opacity)
                .id(viewModel.status)

            VStack(spacing: 4) {
                Text(viewModel.status.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                if !viewModel.deviceName.isEmpty {
                    Text(viewModel.deviceName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // Always reserve space so fading the battery line in
                // doesn't cause a layout shift.
                HStack(spacing: 4) {
                    Image(systemName: batteryIcon(for: viewModel.battery))
                        .font(.system(size: 11, weight: .medium))
                    Text(viewModel.battery.map { "\($0.percent)%" } ?? "")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .monospacedDigit()
                }
                .foregroundColor(viewModel.battery.map { batteryColor(for: $0.percent) } ?? .clear)
                .opacity(viewModel.battery == nil ? 0 : 1)
            }
        }
        .frame(width: 280, height: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.95))
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: viewModel.status)
        .animation(.easeInOut(duration: 0.2), value: viewModel.battery?.percent)
    }

    private func batteryIcon(for battery: BatteryInfo?) -> String {
        guard let battery = battery else { return "battery.100" }
        if battery.isCharging { return "battery.100.bolt" }
        switch battery.percent {
        case ...10: return "battery.0"
        case 11...35: return "battery.25"
        case 36...60: return "battery.50"
        case 61...85: return "battery.75"
        default: return "battery.100"
        }
    }

    private func batteryColor(for percent: Int) -> Color {
        switch percent {
        case ...20: return .red
        case 21...40: return .orange
        default: return .secondary
        }
    }
}

#Preview {
    let vm = OverlayViewModel()
    vm.status = .connected
    vm.deviceName = "AirPods Pro"
    return OverlayView(viewModel: vm)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.3))
}
