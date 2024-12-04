import express from 'express';
import http from 'http';
import cors from 'cors';
import dotenv from 'dotenv';
import { WebSocket, WebSocketServer } from 'ws';



dotenv.config();
const app = express();
const server = http.createServer(app);
const wss = new WebSocketServer({server});

app.use(cors());
app.use(express.json());


wss.on('connection', (ws: WebSocket) => {  
    console.log('new client connection');

    ws.on('message', (message) => {
        console.log("message: " + message);
        wss.clients.forEach(client => {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send(message);
            }
        });
    });
    ws.on('close', () => {
        console.log('client disconnected');
    });
}); 


const port = process.env.PORT;
server.listen(port,() => {
    console.log(`server started on port ${port}`);
});
