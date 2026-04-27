//
//  BatteryReader.swift
//  btkey
//

import Foundation

struct BatteryInfo {
    let percent: Int
    let isCharging: Bool
}

enum BatteryReader {
    static func read(forDeviceNamed name: String) -> BatteryInfo? {
        guard let output = runPmset() else { return nil }

        for plist in splitConcatenatedPlists(output) {
            guard let dict = try? PropertyListSerialization.propertyList(
                from: plist, options: [], format: nil
            ) as? [String: Any] else { continue }

            guard let entryName = dict["Name"] as? String, entryName == name,
                  let capacity = dict["Current Capacity"] as? Int else { continue }

            let charging = (dict["Is Charging"] as? Int).map { $0 != 0 }
                ?? (dict["Is Charging"] as? Bool)
                ?? false
            return BatteryInfo(percent: capacity, isCharging: charging)
        }
        return nil
    }

    private static func runPmset() -> Data? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-g", "accps", "-xml"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }
        return try? pipe.fileHandleForReading.readToEnd()
    }

    // pmset -g accps -xml emits one <?xml...><plist>...</plist> per source,
    // concatenated. PropertyListSerialization needs them split.
    private static func splitConcatenatedPlists(_ data: Data) -> [Data] {
        let marker = Data("<?xml".utf8)
        var ranges: [Range<Data.Index>] = []
        var start = data.startIndex
        while let r = data.range(of: marker, in: start..<data.endIndex) {
            ranges.append(r)
            start = r.upperBound
        }
        guard !ranges.isEmpty else { return [] }
        var chunks: [Data] = []
        for i in 0..<ranges.count {
            let lower = ranges[i].lowerBound
            let upper = i + 1 < ranges.count ? ranges[i + 1].lowerBound : data.endIndex
            chunks.append(data.subdata(in: lower..<upper))
        }
        return chunks
    }
}
