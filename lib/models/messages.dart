class Chats {
  Chats(
      {required this.msg,
      required this.toId,
      required this.read,
      required this.readTime,
      required this.sentTime,
      required this.type,
      required this.fromId,
      required this.time});
  late final String msg;
  late final String toId;
  late final bool read;
  late final String type;
  late final String fromId;
  late final String readTime;
  late final String sentTime;
  late final String time;

  Chats.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    toId = json['toId'].toString();
    read = json['read'];
    readTime = json['read_time'];
    sentTime = json['sent_time'];
    final typeString = json['type'].toString();
    type = (typeString == Type.image.toString())
        ? Type.image.name
        : Type.text.name;

    time = json['time'].toString();
    fromId = json['fromId'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['toId'] = toId;
    data['read'] = read;
    data['sent_time'] = sentTime;
    data['read_time'] = readTime;
    data['type'] = type;
    data['fromId'] = fromId;
    data['time'] = time;
    return data;
  }
}

enum Type { text, image }
