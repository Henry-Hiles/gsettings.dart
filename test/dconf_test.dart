import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:test/test.dart';
import 'package:dconf/dconf.dart';

class MockDConfServer extends DBusClient {
  MockDConfServer(DBusAddress clientAddress) : super(clientAddress);

  Future<void> start() async {
    await requestName('ca.desrt.dconf');
  }
}

void main() {
  test('FIXME', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var dconf = MockDConfServer(clientAddress);
    await dconf.start();

    var client = DConfClient(bus: DBusClient(clientAddress));

    Future<void> listDir(String dir) async {
      var names = await client.list(dir);
      for (var name in names) {
        var fullName = dir + name;
        if (name.endsWith('/')) {
          await listDir(fullName);
        } else {
          var value = await client.lookup(fullName);
          print('$fullName = $value');
        }
      }
    }

    await listDir('/');

    await client.close();
  });
}
