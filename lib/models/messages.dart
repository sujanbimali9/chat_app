class Chats {
  Chats(
      {required this.msg,
      required this.toId,
      required this.read,
      required this.type,
      required this.fromId,
      required this.sent,
      required this.time});
  late final String msg;
  late final String toId;
  late final String read;
  late final String type;
  late final String fromId;
  late final String sent;
  late final String time;

  Chats.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    toId = json['toId'].toString();
    read = json['read'].toString();
    final typeString = json['type'].toString();
    type = (typeString == Type.image.toString())
        ? Type.image.name
        : Type.text.name;

    time = json['time'].toString();
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['toId'] = toId;
    data['read'] = read;
    data['type'] = type;
    data['fromId'] = fromId;
    data['sent'] = sent;
    data['time'] = time;
    return data;
  }
}

enum Type { text, image }
