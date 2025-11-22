//
//  ContentView.swift
//  btkey
//
//  Created by Aaron Mandle on 11/10/25.
//

import SwiftUI
import IOBluetooth

struct ContentView: View {
    @State private var pairedDevices: [IOBluetoothDevice] = []
    @State private var selectedDevice: String = UserDefaults.standard.string(forKey: "bluetoothDeviceAddress") ?? ""
    @State private var selectedDeviceName: String = UserDefaults.standard.string(forKey: "bluetoothDeviceName") ?? ""
    @State private var hotkeyDisplay: String = "Cmd+Shift+H"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bluetooth Device Connector")
                .font(.headline)

            Divider()

            // Bluetooth Device Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Bluetooth Device:")
                    .font(.subheadline)

                if pairedDevices.isEmpty {
                    Text("No paired devices found")
                        .foregroundColor(.secondary)
                } else {
                    Picker("Device", selection: $selectedDevice) {
                        Text("Select a device...").tag("")
                        ForEach(pairedDevices, id: \.addressString) { device in
                            Text(device.name ?? "Unknown Device").tag(device.addressString ?? "")
                        }
                    }
                    .labelsHidden()
                    .onChange(of: selectedDevice) { oldValue, newValue in
                        if let device = pairedDevices.first(where: { $0.addressString == newValue }) {
                            selectedDeviceName = device.name ?? "Unknown"
                            UserDefaults.standard.set(newValue, forKey: "bluetoothDeviceAddress")
                            UserDefaults.standard.set(selectedDeviceName, forKey: "bluetoothDeviceName")
                        }
                    }
                }

                Button("Refresh Devices") {
                    loadPairedDevices()
                }
                .buttonStyle(.bordered)
            }

            Divider()

            // Hotkey Display
            VStack(alignment: .leading, spacing: 8) {
                Text("Keyboard Shortcut:")
                    .font(.subheadline)
                Text(hotkeyDisplay)
                    .padding(8)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
                Text("(Configurable shortcuts coming soon)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Test Connection Button
            HStack {
                Button("Test Connection") {
                    BluetoothManager.shared.connectToConfiguredDevice()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedDevice.isEmpty)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 300)
        .onAppear {
            loadPairedDevices()
        }
    }

    private func loadPairedDevices() {
        pairedDevices = BluetoothManager.shared.getPairedDevices()
    }
}

#Preview {
    ContentView()
}
