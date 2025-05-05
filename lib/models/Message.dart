class Message {
  final String mensaje;
  final String fechaEnvio;
  final String estadoMensaje;
  final int remitenteId;
  final int destinatarioId;
  final bool leido;

  Message({
    required this.mensaje,
    required this.fechaEnvio,
    required this.estadoMensaje,
    required this.remitenteId,
    required this.destinatarioId,
    required this.leido,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      mensaje: json['mensaje'],
      fechaEnvio: json['fecha_envio'],
      estadoMensaje: json['estado_mensaje'],
      remitenteId: json['remitente_id'],
      destinatarioId: json['destinatario_id'],
      leido: json['leido'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mensaje': mensaje,
      'fecha_envio': fechaEnvio,
      'estado_mensaje': estadoMensaje,
      'remitente_id': remitenteId,
      'destinatario_id': destinatarioId,
      'leido': leido,
    };
  }
}
