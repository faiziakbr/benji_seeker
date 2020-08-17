import 'dart:convert';

ChatModel responseFromChatJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return ChatModel.fromJson(jsonData);
}

class ChatModel {
  bool status;
  List<ItemChatModel> itemChatModel;


  ChatModel();

  ChatModel.fromJson(Map<String, dynamic> parsedJson) {
    status = parsedJson["status"];

    List<ItemChatModel> _temp = [];

    var key = parsedJson['chat_messages'];
    if (key != null && key.length > 0) {
      for (int i = 0; i < key.length; i++) {
        var messages = ItemChatModel.fromJson(key[i]);
        _temp.add(messages);
      }
    }
    itemChatModel = _temp;
  }
}

class ItemChatModel {
  String id;
  String sender;
  String createdAt;
  String processId;
  String messageBody;
  String seenAt;


  ItemChatModel({this.id, this.sender, this.createdAt, this.processId,
    this.messageBody, this.seenAt});

  ItemChatModel.fromJson(Map<String, dynamic> json){
    id = json["_id"];
    sender = json['sender'];
    seenAt = json['seen_at'];
    createdAt = json["created_at"];
    processId = json["process_id"];
    messageBody = json["message_body"];
  }
}