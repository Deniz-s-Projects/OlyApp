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
          socket.userId = msg.userId?.toString();
          broadcastPresence(socket.room, 'online', socket.userId, socket);
        }
      } catch (_) {
        // ignore parse errors
      }
    });

    socket.on('close', () => {
      if (socket.room && socket.userId) {
        broadcastPresence(socket.room, 'offline', socket.userId, socket);
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

function broadcastPresence(room, type, userId, exclude) {
  if (!wss || !room || !userId) return;
  const payload = JSON.stringify({ type, room, userId });
  wss.clients.forEach((client) => {
    if (
      client.readyState === WebSocket.OPEN &&
      client.room === room &&
      client !== exclude
    ) {
      client.send(payload);
    }
  });
}

module.exports = { init, broadcast };
