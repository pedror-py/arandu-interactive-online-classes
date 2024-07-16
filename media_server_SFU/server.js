import express from "express";
import { Server } from 'socket.io';
import path from 'path';
import http from 'http';
import fs from 'fs';

import { mediasoupServer } from './mediasoup/socket-mediasoup-server.js';

const app = express();

// Uncomment to enable mediasoup server debugging by logging
// process.env.DEBUG = "mediasoup*";

process.env.PORT = 8080;

const httpServer = app.listen(8080, () => {
    console.log("Server is listening at 8080...");
});

const io = new Server(httpServer, {
    cors: {
        origin: "http://localhost:5173",
        methods: ["GET", "POST"]    
    }
});

mediasoupServer(io);
