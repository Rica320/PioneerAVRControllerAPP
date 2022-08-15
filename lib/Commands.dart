import 'dart:io';

bool machinePowerStatus = false;

enum Command {
  Standby,
  On,
  AppleTV,
  Meo,
  VolUp,
  VolDown
}

enum StatusCommand {
  power
}

Future<void> sendCommand(Socket socket, Command cmd) async {
  print('Client: $cmd');
  switch (cmd) {
    case Command.Standby:
      socket.write('PF\r');
      break;
    case Command.On:
      socket.write('PO\r');
      break;
    case Command.AppleTV:
      socket.write('24FN\r');
      break;
    case Command.Meo:
      socket.write('06FN\r');
      break;
    case Command.VolUp:
      socket.write('VU\r');
      break;
    case Command.VolDown:
      socket.write('VD\r');
      break;
  }

  await Future.delayed(const Duration(milliseconds: 30));
}

Future<void> requestStatus(Socket socket, StatusCommand cmd) async {
  print('Client ask status: $cmd');
  switch (cmd) {
    case StatusCommand.power:
      socket.write('?P\r');
      break;
  }
  await Future.delayed(const Duration(milliseconds: 30));
}

void handleResponse(String res) {
  if (res == 'PWR1') {
    machinePowerStatus = false;
  }
  else if (res == 'PWR0') {
    machinePowerStatus = true;
  }
}
