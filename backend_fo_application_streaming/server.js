const express = require('express');
const app = express();
require('dotenv').config();
const authRoutes = require('./routes/auth.routes');
const movieRoutes = require('./routes/movie.routes');
const seriesRoutes = require('./routes/series.routes');
const userContentRoutes = require('./routes/user-content.routes');
const categoryRoutes = require('./routes/category.routes');
const cors = require('cors');

// Middlewares
app.use(express.json());
app.use(cors());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/movies', movieRoutes);
app.use('/api/series', seriesRoutes);
app.use('/api/user', userContentRoutes);
app.use('/api', categoryRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));