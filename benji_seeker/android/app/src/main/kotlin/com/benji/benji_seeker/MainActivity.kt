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

    private var socket: Socket? = null
    var channel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        socket = IO.socket("https://app.benjilawn.com/")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "addUserForSocket" -> {
                    val token = call.argument<String>("token")
                    Log.e("MYTAG","ADD USer FOR SOCKET: $token")
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
                    Log.e("MYTAG","GOT THE TOKEN $processId");
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
                "connectSocket" -> {
                    connectSocket()
                    result.success(true);
                }
                "closeSocket" -> {
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
        if (socket?.connected()!!) {
            closeSocket()
            socket?.connect()
        }else{
            socket?.connect()
        }
    }

    private fun addUserForSocket(token: String) {
        if (socket!!.connected()) {
            Log.e("MYTAG","TOKEN IN NATIVE: $token")
            socket?.emit("add_user", token)
        }else {
            Log.e("MYTAG","SOCKET IS STILL NOT CONNECTED")
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
        Log.e("MYTAG", "ProcessId: $processId, toUserId: $toUserId, fromUserId: $fromUserId, messageBody: $messageBody");

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
        Log.e("MYTAG","NATIVE A JOB CHANGED")
        val event = "JOB_PAGE_$processId"
        socket?.on(event) { args ->
            Log.e("MYTAG","A JOB IS CHANGED")
            runOnUiThread {
                channel?.invokeMethod("updateTheJob", true)
            }
        }
    }

    private fun checkAccountStatusChange(){
        socket?.on("CHECK_STATUS_CHANGE") { args ->

        }
    }
}
