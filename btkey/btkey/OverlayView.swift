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
