const WebSocket = require('ws');
const express = require('express');
const path = require('path');

const app = express();
const server = require('http').createServer(app);
const wss = new WebSocket.Server({ server });

// Сервирамо статичке фајлове из 'public' директоријума
app.use(express.static('public'));

// Рута за главну страницу
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Чувамо последње податке о анализи
let lastAnalysis = null;

wss.on('connection', (ws) => {
    console.log('Нова конекција успостављена');
    
    // Ако имамо претходне податке, одмах их шаљемо
    if (lastAnalysis) {
        ws.send(JSON.stringify(lastAnalysis));
    }
    
    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            lastAnalysis = data;
            
            // Прослеђујемо податке свим конектованим клијентима
            wss.clients.forEach((client) => {
                if (client !== ws && client.readyState === WebSocket.OPEN) {
                    client.send(JSON.stringify(data));
                }
            });
        } catch (error) {
            console.error('Грешка при обради поруке:', error);
        }
    });
});

const PORT = process.env.PORT || 8080;
server.listen(PORT, () => {
    console.log(`Сервер покренут на порту ${PORT}`);
}); 