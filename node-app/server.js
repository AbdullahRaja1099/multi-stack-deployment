const express = require("express");
const app = express();

app.get("/", (req, res) =>
  res.send("<h1>Node.js (Express) App</h1><p>Fronted by Nginx</p>")
);

app.get("/health", (req, res) => res.json({ status: "ok", stack: "node" }));

app.listen(3000, "127.0.0.1", () => console.log("Node app listening on 3000"));
