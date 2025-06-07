const { WebSocketServer, WebSocket } = require('ws');

let wss;

function init(server) {
  wss = new WebSocketServer({ server });
  wss.on('connection', (socket) => {
    socket.on('message', (data) => {
      try {
        const msg = JSON.parse(data);
        if (msg.type === 'join' && msg.room) {
          socket.room = msg.room.toString();
        }
      } catch (_) {
        // ignore parse errors
      }
    });
  });
}

function broadcast(room, message) {
  if (!wss) return;
  const payload = JSON.stringify({ type: 'message', room, data: message });
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN && client.room === room) {
      client.send(payload);
    }
  });
}

module.exports = { init, broadcast };
