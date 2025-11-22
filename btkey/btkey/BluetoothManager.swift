//
//  BluetoothManager.swift
//  btkey
//
//  Created by Aaron Mandle on 11/10/25.
//

import Foundation
import IOBluetooth

class BluetoothManager: NSObject {
    static let shared = BluetoothManager()

    private override init() {
        super.init()
    }

    func connectToConfiguredDevice() {
        guard let deviceAddress = UserDefaults.standard.string(forKey: "bluetoothDeviceAddress") else {
            print("No Bluetooth device configured")
            OverlayWindowManager.shared.showOverlay(status: .noDevice, deviceName: "")
            return
        }

        let deviceName = UserDefaults.standard.string(forKey: "bluetoothDeviceName") ?? "Unknown Device"
        print("Attempting to connect to device: \(deviceAddress)")

        // Show connecting overlay
        OverlayWindowManager.shared.showOverlay(status: .connecting, deviceName: deviceName)

        // Convert address string to IOBluetoothDevice
        if let device = IOBluetoothDevice(addressString: deviceAddress) {
            connectToDevice(device)
        } else {
            print("Could not find device with address: \(deviceAddress)")
            OverlayWindowManager.shared.showOverlay(status: .failed, deviceName: deviceName)
        }
    }

    private func connectToDevice(_ device: IOBluetoothDevice) {
        let deviceName = device.name ?? "Unknown Device"

        if device.isConnected() {
            print("Device already connected: \(deviceName)")
            OverlayWindowManager.shared.showOverlay(status: .alreadyConnected, deviceName: deviceName)
            return
        }

        print("Connecting to device: \(deviceName)")

        let result = device.openConnection()
        if result == kIOReturnSuccess {
            print("Successfully connected to device")
            OverlayWindowManager.shared.showOverlay(status: .connected, deviceName: deviceName)
        } else {
            print("Failed to connect to device: \(result)")
            OverlayWindowManager.shared.showOverlay(status: .failed, deviceName: deviceName)
        }
    }

    func getPairedDevices() -> [IOBluetoothDevice] {
        return IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] ?? []
    }
}
