/*
# Install dependencies:
npm install express http-proxy-middleware
# Start with the command:
node server.js
*/

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

app.use('/api', createProxyMiddleware({
  target: 'https://api.staging.galoy.io/graphql', // The target API endpoint
  changeOrigin: true,
  pathRewrite: {
    '^/api': '', // Rewrite the API path, if needed
  },
  onProxyRes: function (proxyRes, req, res) {
    // Add CORS headers to the response from the proxied server
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    if (req.method === 'OPTIONS') {
      // Preflight request, end it after setting headers
      res.sendStatus(200);
    }
  },
}));

const PORT = 3000; // The port your proxy server will listen on
app.listen(PORT, () => {
  console.log(`Proxy server is running on http://localhost:${PORT}`);
});
