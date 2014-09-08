import UIKit
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CBCentralManagerDelegate {
                            
    var window: UIWindow?
    var centralManager: CBCentralManager?
    var scanning = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        return true
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn && !scanning {
            centralManager!.scanForPeripheralsWithServices(nil, options: nil)
            println("Scanning")
            scanning = true
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        var proximityUUID: String?
        if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? NSData {
            println("Data size: \(data.length) bytes")
            proximityUUID = parseBeaconAdvertisement(data)
        }
        println("Found Beacon: \(peripheral.name), proximityUUID: \(proximityUUID), uuidstring: \(peripheral.identifier.UUIDString)")
    }
    
    func parseBeaconAdvertisement(data: NSData) -> String {
        if data.length != 25 {
            return "null"
        }
        
        var uuidBytes = [Character](count: 17, repeatedValue: "0")
        var uuidRange = NSMakeRange(4, 16)
        data.getBytes(&uuidBytes, range: uuidRange)
        var bytes = UnsafeMutablePointer<UInt8>(uuidBytes)
        var proximityUUID = NSUUID(UUIDBytes: bytes)
        return proximityUUID.UUIDString
    }
}

