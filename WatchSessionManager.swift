import Foundation
import WatchConnectivity
import os
class WatchSessionManager : NSObject, WCSessionDelegate {
    static let sharedManager = WatchSessionManager()
    private let session : WCSession? = WCSession.isSupported() ? WCSession.default : nil
    private var items = [String]() {
        didSet {
            print(1)
            }
        }
    override init() {
        super.init()
    }
    var validSession: WCSession?{
        if let session = session, session.isPaired && session.isWatchAppInstalled{
            return session
        }
        return nil
    }
    func startSession(){
        session?.delegate = self
        session?.activate()
    }
    private func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    private func isReachable() -> Bool {
        return session!.isReachable
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    func sessionDidDeactivate(_ session: WCSession) {
    }
    func sessionWatchStateDidChange(_ session: WCSession) {
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["request"] as? String == "date" {
            replyHandler(["date" : "\(Date())"])
        }
    }
    func sessionReachabilityDidChange(_ session: WCSession) {
    }
    func sendMessageData(data: Data, replyHandler: ((Data) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        session?.activate()
        session?.sendMessageData(data, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    func sendMessage(message: [String : Any]) {
        if isReachable() {
            session?.sendMessage(message, replyHandler: nil, errorHandler: { (error) in
                print("Error sending message: %@", error)
            })
        } else {
            print("iPhone is not reachable!!")
        }
    }
    func sendTopPricesListToWatch(count: Int){
        let watchSessionManager = WatchSessionManager.sharedManager
        var returnMessage: [String : Any] = [ : ]
        let list = Statistics.shared.mostExpensiveItems(elementsCount: count)
        for inv in list{
            returnMessage[DataKey.MostExpensiveList + inv.inventoryName!] = String(inv.price) as Any
        }
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
    }
    func sendItemsByRoomListToWatch(){
        let watchSessionManager = WatchSessionManager.sharedManager
        var returnMessage: [String : Any] = [ : ]
        let list = Statistics.shared.countItemsByRoomDict()
        for (key, val) in list{
            returnMessage[DataKey.TopRooms + key] = Int(val) as Any
        }
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
    }
    func sendItemsByCategoryListToWatch(){
        let watchSessionManager = WatchSessionManager.sharedManager
        var returnMessage: [String : Any] = [ : ]
        let list = Statistics.shared.countItemsByCategoryDict()
        for (key, val) in list{
            returnMessage[DataKey.TopCategories + key] = Int(val) as Any
        }
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
    }
    func sendItemsByBrandListToWatch(){
        let watchSessionManager = WatchSessionManager.sharedManager
        var returnMessage: [String : Any] = [ : ]
        let list = Statistics.shared.countItemsByBrandDict()
        for (key, val) in list{
            returnMessage[DataKey.TopBrands + key] = Int(val) as Any
        }
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
    }
    func sendItemsByOwnerListToWatch(){
        let watchSessionManager = WatchSessionManager.sharedManager
        var returnMessage: [String : Any] = [ : ]
        let list = Statistics.shared.countItemsByBrandDict()
        for (key, val) in list{
            returnMessage[DataKey.TopOwners + key] = Int(val) as Any
        }
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
    }
}
extension WatchSessionManager{
    func updateApplicationContext(applicationContext: [String : Any]) throws {
        if let session = validSession{
            do{
                try session.updateApplicationContext(applicationContext)
            } catch let error{
                throw error
            }
        }
    }
    func transferUserInfo(userInfo: [String : Any]) -> WCSessionUserInfoTransfer? {
        return validSession?.transferUserInfo(userInfo)
    }
}
