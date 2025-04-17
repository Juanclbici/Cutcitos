class Message {
  final int id;
  final int emisorId;
  final int receptorId;
  final String contenido;
  final DateTime fecha;

  Message({
    required this.id,
    required this.emisorId,
    required this.receptorId,
    required this.contenido,
    required this.fecha,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['message_id'],
      emisorId: json['emisor_id'],
      receptorId: json['receptor_id'],
      contenido: json['contenido'] ?? '',
      fecha: DateTime.tryParse(json['createdAt']) ?? DateTime.now(),
    );
  }
}
