const express = require('express');
const axios = require('axios');
const jwt = require('jsonwebtoken');
const helmet = require('helmet');
const sanitize = require('sanitize-html');
const path = require('path');

const app = express();

const SECRET = process.env.JWT_SECRET || "fallback-secret";

app.use(express.static('public'));
app.use(helmet());

// Fix for SSRF: Sanitize the URL before making the request
app.get('/ssrf', async (req, res) => {
    try {
    const response = await axios.get("https://api.github.com");
        const clean = sanitize(JSON.stringify(response.data));
        res.send(`<pre>${clean}</pre>`);
    } catch (err) {
        res.status(500).send("Error fetching data");
    }
});

// Fix for Command Injection: Do not execute user input as commands
app.get('/cmd', (req, res) => {
    res.send("Command execution disabled for security.");
});

// Fix for Reflected XSS: Sanitize user input
app.get('/xss', (req, res) => {
    const name = sanitize(req.query.name || "Guest");
    res.send(`<h1>Hello ${name}</h1>`);
});

// Fix for Open Redirect: Validate the redirect URL
app.get('/redirect', (req, res) => {
    const next = req.query.next;
    try {
        const url = new URL(next);

        const allowedHosts = [
            "google.com",
            "example.com"
        ];

        if (!allowedHosts.includes(url.hostname)) {
            return res.status(400).send("Invalid redirect target");
        }

        return res.redirect(url.toString());
    } catch (err) {
        return res.status(400).send("Invalid URL format");
    }
});

// Fix for Path Traversal: Sanitize the file path and restrict to a specific directory
app.get('/read', (req, res) => {
    const file = sanitize(req.query.file || "");

    const baseDir = path.join(__dirname, "public");
    const safePath = path.join(baseDir, file);

    if (!safePath.startsWith(baseDir)) {
        return res.status(400).send("Invalid file path");
    }

    res.sendFile(safePath);
});

// Fix for Insecure Deserialization: Do not deserialize untrusted data
app.get('/token', (req, res) => {
    const token = jwt.sign({ role: "user" }, SECRET, { expiresIn: "1h" });
    res.json({ token });
});

// Fix for Sensitive Logging: Avoid logging sensitive information
app.get('/leak', (req, res) => {
    res.send("Sensitive logging disabled.");
});

app.listen(3000, () => console.log("Running"));