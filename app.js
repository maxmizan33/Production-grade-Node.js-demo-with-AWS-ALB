const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.send(`
        <h1>MyApp Production-Grade Demo</h1>
        <p>Served by EC2 instance: ${require('os').hostname()}</p>
    `);
});

app.listen(port, () => console.log(`Server running on port ${port}`));
