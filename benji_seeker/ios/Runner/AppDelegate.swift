import UIKit
import Flutter
import SocketIO

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var socket: SocketIOClient?
    let manager = SocketManager(socketURL: URL(string: "https://development.benjilawn.com/")!, config: [.log(false), .compress])
    var channel: FlutterMethodChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        channel = FlutterMethodChannel(name: "samples.flutter.dev/battery",
                                       binaryMessenger: controller.binaryMessenger)
        
        
        socket = manager.defaultSocket
        
        
        channel!.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            switch call.method {
            case "addUserForSocket":
                let args = call.arguments as? Dictionary<String, Any>
                let token: String = args!["token"] as! String
                self.addUserForSocket(token: token)
                result(true)
            case "isSocketConnected":
                self.isSocketConnected()
                result(true)
            case "emitMessage":
                let args = call.arguments as? Dictionary<String, Any>
                let processId = args!["processId"] as! String
                let toUserId = args!["toUserId"] as! String
                let fromUserId = args!["fromUserId"] as! String
                let messageBody = args!["messageBody"] as! String
                
                self.emitMessage(processId, toUserId, fromUserId, messageBody)
                result(true)
            case "listenToMessages":
                let args = call.arguments as? Dictionary<String, Any>
                let processId = args!["processId"] as! String
                
                self.listenToMessages(processId)
                result(true)
            case "leaveChatRoom":
                let args = call.arguments as? Dictionary<String, Any>
                let processId = args!["processId"] as! String
                
                self.leaveChatRoom(processId)
                result(true)
            case "startListeningToMessages":
                print("iOS start Listening for messages")
                self.startListeningToMessages()
                result(true)
            case "aJobChanged":
                let args = call.arguments as? Dictionary<String, Any>
                let processId = args!["processId"] as! String
                
                self.aJobChanged(processId)
                result(true)
            case "aJobBidChanged":
                let args = call.arguments as? Dictionary<String, Any>
                let processId = args!["processId"] as! String
                self.aJobBidChanged(processId)
                result(true)
            case "connectSocket":
                self.connectSocket()
                result(true)
            case "closeSocket":
                self.closeSocket()
                result(true)
                
            default:
                print("UnImplemented method called from flutter: \(call.method)")
            }
        })
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func connectSocket(){
        print("IOS SOCKET CONNECTED")
        if socket!.status == SocketIOStatus.connected{
            socket!.disconnect()
            socket!.connect()
            
        }else {
            socket!.connect()
        }
    }
    
    private func addUserForSocket(token: String){
        print("IOS ADD USER FOR SOCKET")
        if socket!.status == SocketIOStatus.connected{
            socket!.emit("add_user", token)
        }
    }
    
    private func startListeningToMessages(){
        print("IOS START LISTENING FOR MESSAGES")
        DispatchQueue.main.async {
            self.channel!.invokeMethod("listenForMessages", arguments: true)
        }
    }
    
    private func isSocketConnected(){
        print("IOS IS SOCKET CONNECTED")
        socket!.on("connect") { (args, SocketAckEmitter) in
            DispatchQueue.main.async {
                print("IOS SOCKET CONNECTED CALL DART")
                self.channel!.invokeMethod("socketConnected", arguments: true)
            }
        }
    }
    
    private func emitMessage(_ processId: String,_ toUserId: String,_ fromUserId: String,_ messageBody: String){
        
        let jsonObject: [String: Any] = [
            "process_id": processId,
            "to_user_id": toUserId,
            "from_user_id": fromUserId,
            "message_body": messageBody
        ]
        
        socket!.emit("sentMsg", jsonObject)
    }
    
    private func listenToMessages(_ processId: String){
        print("IOS LISTEN FOR MESSAGES")
        let jsonObject: [String: Any] = [
            "process_id": processId
        ]
        
        socket!.emit("enter_chat_room", jsonObject)
        
        socket!.on("NEW_MESSAGE_\(processId)") { (args, SocketAckEmitter) in
            //            let obj = JSON(arrayLiteral: args)
            //            let decoder = JSONDecoder()
            //            let followers = try decoder.decode([NSObject].self, from: data)
            print("iOS NEW_MESSAGE: \(args)")
            DispatchQueue.main.async {
                self.channel!.invokeMethod("receiveMessage", arguments: args)
            }
        }
    }
    
    private func leaveChatRoom(_ processId: String){
        let jsonObject: [String: Any] = [
            "process_id": processId
        ]
        socket!.emit("leave_chat_room", jsonObject)
    }
    
    private func closeSocket(){
        socket!.disconnect()
    }
    
    private func aJobChanged(_ processId: String){
        let event = "JOB_PAGE_\(processId)"
        
        socket!.on(event) { (args, SocketAckEmitter) in
            DispatchQueue.main.async {
                self.channel!.invokeMethod("updateTheJob", arguments: true)
            }
        }
    }
    
    private func aJobBidChanged(_ processId: String){
        let event = "JOB_PAGE_\(processId)_BIDS"
        
        socket!.on(event) { (args, SocketAckEmitter) in
            DispatchQueue.main.async {
                self.channel!.invokeMethod("updateTheJobBid", arguments: true)
            }
        }
    }
}
