import UIKit
class DeviceInfo: NSObject {
    static func getOSVersion() -> String
    {
        return UIDevice.current.systemVersion
    }
    static func getbatteryLevel() -> Float
    {
        return UIDevice.current.batteryLevel
    }
    static func getDeviceName() -> String
    {
        return UIDevice.current.name
    }
    static func getDeviceUUID() -> UUID
    {
        return UIDevice.current.identifierForVendor!
    }
}
