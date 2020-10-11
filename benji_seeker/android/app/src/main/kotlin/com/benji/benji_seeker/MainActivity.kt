package com.benji.benji_seeker

import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import com.github.nkzawa.socketio.client.IO
import com.github.nkzawa.socketio.client.Socket
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.lang.Exception

class MainActivity: FlutterActivity() {

    private val CHANNEL = "samples.flutter.dev/battery"

    val TAG = "MyNativeMethods";

    private var socket: Socket? = null
    var channel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        socket = IO.socket("https://development.benjilawn.com/")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "addUserForSocket" -> {
                    val token = call.argument<String>("token")
                    Log.e(TAG,"ADD USer FOR SOCKET: $token")
                    addUserForSocket(token!!)
                    result.success(true)
                }
                "isSocketConnected" -> {
                    isSocketConnected();
                    result.success(true)
                }
                "emitMessage" -> {
                    val processId = call.argument<String>("processId")
                    val toUserId = call.argument<String>("toUserId")
                    val fromUserId = call.argument<String>("fromUserId")
                    val messageBody = call.argument<String>("messageBody")

                    emitMessage(processId!!, toUserId!!, fromUserId!!, messageBody!!)
                    result.success(true)
                }
                "listenToMessages" -> {
                    val processId = call.argument<String>("processId")
                    Log.e(TAG,"GOT THE TOKEN $processId");
                    listenToMessages(processId!!)
                    result.success(true)
                }
                "leaveChatRoom" -> {
                    val processId = call.argument<String>("processId")
                    leaveChatRoom(processId!!);
                    result.success(true);
                }
                "checkNewLeads" -> {
                    checkNewLeads()
                    result.success(true)
                }
                "changeInCurrentJob" -> {
                    changeInCurrentJob()
                    result.success(true)
                }
                "startListeningToMessages" -> {
                    startListeningToMessages()
                    result.success(true)
                }
                "aJobChanged" -> {
                    val processId = call.argument<String>("processId")
                    aJobChanged(processId!!)
                    result.success(true)
                }
                "aJobBidChanged" -> {
                    val processId = call.argument<String>("processId")
                    aJobBidChanged(processId!!)
                    result.success(true)
                }
                "amount_refunded" -> {
                    amountRefunded()
                    result.success(true)
                }
                "connectSocket" -> {
                    connectSocket()
                    result.success(true);
                }
                "closeSocket" -> {
                    Log.e(TAG,"SOCKET CONNECTION CALLED")
                    closeSocket()
                    result.success(true);
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun connectSocket(){
        Log.e(TAG,"SOCKET CONNECTION")
        if (socket?.connected()!!) {
            closeSocket()
            socket?.connect()
        }else{
            socket?.connect()
        }
    }

    private fun addUserForSocket(token: String) {
        if (socket!!.connected()) {
            Log.e(TAG,"TOKEN IN NATIVE: $token")
            socket?.emit("add_user", token)
        }else {
            Log.e(TAG,"SOCKET IS STILL NOT CONNECTED")
        }
    }

    private fun startListeningToMessages(){
        try {
            runOnUiThread {
                channel?.invokeMethod("listenForMessages", true)
            }
        }catch (e: Exception) {
            Log.e("MYTAG","native Exception: $e")
        }
    }

    private fun isSocketConnected() {
        socket?.on("connect") {args ->
            Log.e("MYTAG","SOCKET IS CONNECTED")
            runOnUiThread {
                channel?.invokeMethod("socketConnected", true)
            }
        }
    }

    private fun emitMessage(processId: String, toUserId: String, fromUserId: String, messageBody: String) {
        Log.e(TAG, "ProcessId: $processId, toUserId: $toUserId, fromUserId: $fromUserId, messageBody: $messageBody");

        val jsonObject = JSONObject()
        jsonObject.put("process_id", processId)
        jsonObject.put("to_user_id", toUserId)
        jsonObject.put("from_user_id", fromUserId)
        jsonObject.put("message_body", messageBody)

        socket?.emit("sentMsg", jsonObject)
    }

    private fun listenToMessages(processId: String) {
//        Log.e("MYTAG","Listening for messages, ProcessID: $processId")
        val jsonObject = JSONObject()
        jsonObject.put("process_id", processId)
        socket?.emit("enter_chat_room", jsonObject)
        socket?.on("NEW_MESSAGE_${processId}") { args ->
            val obj = JSONArray(args)
            runOnUiThread(Runnable {
                channel?.invokeMethod("receiveMessage", obj.toString())
            })
        }
    }

    private fun checkNewLeads() {
        socket?.on("CHECK_NEW_LEADS") { args ->
            //No data on args
            runOnUiThread {
                channel?.invokeMethod("newLeadNotify", true)
            }
        }
    }

    private fun changeInCurrentJob() {
        Log.e("MYTAG","START LISTENING FOR JOB CHANGE")
        socket?.on("CHECK_CURRENT_JOBS") { args ->
            runOnUiThread {
                channel?.invokeMethod("updateAllJobs", true)
            }
        }
    }

    private fun amountRefunded(){
        socket?.on("amount_refunded") { args ->
            runOnUiThread{
                channel?.invokeMethod("amount_refunded_called", true)
            }
        }
    }

    private fun leaveChatRoom(processId: String){
        val jsonObject = JSONObject()
        jsonObject.put("process_id", processId)
        socket?.emit("leave_chat_room", jsonObject)
    }

    private fun closeSocket(){
        socket?.off()
        socket?.close()
        socket?.disconnect()
    }

    private fun checkNotifications(){

    }

    private fun aJobChanged(processId: String){
        val event = "JOB_PAGE_$processId"
        socket?.on(event) { args ->
            Log.e(TAG,"A JOB IS CHANGED")
            runOnUiThread {
                channel?.invokeMethod("updateTheJob", true)
            }
        }
    }

    private fun aJobBidChanged(processId: String){
        Log.e(TAG, "NATIVE A JOB BID CHANGE SOCKET STATUS: ${socket?.connected()} AND PROCESS ID IS: $processId")
        val event = "JOB_PAGE_${processId}_BIDS"
        Log.e(TAG, "EVEN IS: $event")
        socket?.on(event) { args ->
            Log.e(TAG,"A JOB BID IS CHANGED")
            runOnUiThread {
                channel?.invokeMethod("updateTheJobBid", true)
            }
        }
    }

    private fun checkAccountStatusChange(){
        socket?.on("CHECK_STATUS_CHANGE") { args ->

        }
    }
}
