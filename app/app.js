const express = require('express');
const axios = require('axios');
const fs = require('fs');
const jwt = require('jsonwebtoken');
const app = express();

// Hardcoded secret
const SECRET = "AKIAIOSFODNN7EXAMPLE";

app.use(express.static('public'));

// SSRF 
app.get('/ssrf', async (req, res) => {
    const url = req.query.url;
    try {
        const response = await axios.get(url);
        res.send(response.data);
    } catch (err) {
        res.send("SSRF request failed");
    }
});

// Command Execution
app.get('/cmd', (req, res) => {
    const { exec } = require('child_process');
    exec(req.query.cmd, (err, stdout) => {
        res.send(stdout || "Error executing command");
    });
});

// Reflected XSS
app.get('/xss', (req, res) => {
    const name = req.query.name;
    res.send(`<h1>Hello ${name}</h1>`);
});

// Open Redirect
app.get('/redirect', (req, res) => {
    const next = req.query.next;
    res.redirect(next);
});

// Path Traversal
app.get('/read', (req, res) => {
    const file = req.query.file;
    fs.readFile(file, 'utf8', (err, data) => {
        if (err) return res.send("Error reading file");
        res.send(`<pre>${data}</pre>`);
    });
});

// Weak JWT
app.get('/token', (req, res) => {
    const token = jwt.sign({ role: "user" }, SECRET);
    res.send(`Weak token: ${token}`);
});

// Sensitive Data Exposure
app.get('/leak', (req, res) => {
    const secret = req.query.secret;
    console.log("Leaked secret:", secret); // Logging sensitive data
    res.send("Secret logged to server console");
});

app.listen(3000, () => console.log("Running"));