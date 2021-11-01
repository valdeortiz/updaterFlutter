import 'dart:io';
import 'dart:convert';

void main() {
  int port = 8082;

  // listen forever & send response
  RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((socket) {
    socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram dg = socket.receive();
        if (dg == null) return;
        final recvd = String.fromCharCodes(dg.data);

        /// send ack to anyone who sends ping
        if (recvd == "ping")
          socket.send(Utf8Codec().encode("ping ack"), dg.address, port);
        print("$recvd from ${dg.address.address}:${dg.port}");
      }
    });
  });
  print("udp listening on $port");

  // send single packet then close the socket
  RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((socket) {
    socket.send(Utf8Codec().encode("single send"),
        InternetAddress("192.168.0.38"), 8083);
    socket.listen((event) {
      if (event == RawSocketEvent.write) {
        socket.close();
        print("single closed");
      }
    });
  });
}
