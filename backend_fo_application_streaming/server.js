const express = require('express');
const app = express();
require('dotenv').config();
const cors = require('cors');

// Routes
const authRoutes = require('./routes/auth.routes');
const contentRoutes = require('./routes/content.routes');
const userDataRoutes = require('./routes/userData.routes');

// Middlewares
app.use(express.json());
app.use(cors());

// Routes principales
app.use('/api/auth', authRoutes);
app.use('/api/content', contentRoutes);     // 🔥 Toutes les données TMDB
app.use('/api/user', userDataRoutes);       // 🔥 Données utilisateur uniquement

// Route de santé
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Streaming API is running',
    timestamp: new Date().toISOString()
  });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📱 Content API: http://localhost:${PORT}/api/content`);
  console.log(`👤 User API: http://localhost:${PORT}/api/user`);
});