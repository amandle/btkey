//
//  BluetoothManager.swift
//  btkey
//

import Foundation
import IOBluetooth

class BluetoothManager: NSObject {
    static let shared = BluetoothManager()

    private let connectionQueue = DispatchQueue(label: "com.btkey.bluetooth", qos: .userInitiated)

    private override init() {
        super.init()
    }

    func connectToConfiguredDevice() {
        // Show the connecting overlay immediately, before any blocking work.
        let deviceName = UserDefaults.standard.string(forKey: "bluetoothDeviceName") ?? "Unknown Device"
        let deviceAddress = UserDefaults.standard.string(forKey: "bluetoothDeviceAddress")

        if deviceAddress == nil {
            print("No Bluetooth device configured")
            OverlayWindowManager.shared.showOverlay(status: .noDevice, deviceName: "")
            return
        }

        OverlayWindowManager.shared.showOverlay(status: .connecting, deviceName: deviceName)

        // openConnection() is synchronous and can take seconds — run off main.
        connectionQueue.async {
            guard let address = deviceAddress,
                  let device = IOBluetoothDevice(addressString: address) else {
                print("Could not find device with address: \(deviceAddress ?? "nil")")
                OverlayWindowManager.shared.showOverlay(status: .failed, deviceName: deviceName)
                return
            }

            let resolvedName = device.name ?? deviceName

            if device.isConnected() {
                print("Device already connected: \(resolvedName)")
                OverlayWindowManager.shared.showOverlay(status: .alreadyConnected, deviceName: resolvedName)
                self.fetchBattery(for: resolvedName)
                return
            }

            print("Connecting to device: \(resolvedName)")
            let result = device.openConnection()
            if result == kIOReturnSuccess {
                print("Successfully connected to device")
                OverlayWindowManager.shared.showOverlay(status: .connected, deviceName: resolvedName)
                self.fetchBattery(for: resolvedName)
            } else {
                print("Failed to connect to device: \(result)")
                OverlayWindowManager.shared.showOverlay(status: .failed, deviceName: resolvedName)
            }
        }
    }

    private func fetchBattery(for deviceName: String) {
        connectionQueue.async {
            let info = BatteryReader.read(forDeviceNamed: deviceName)
            OverlayWindowManager.shared.updateBattery(info)
        }
    }

    func getPairedDevices() -> [IOBluetoothDevice] {
        return IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] ?? []
    }
}
