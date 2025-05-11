const express = require('express');
const app = express();
require('dotenv').config();
const authRoutes = require('./routes/auth.routes');
const cors = require('cors');

// Middlewares
app.use(express.json());
app.use(cors());

// Routes
app.use('/api/auth', authRoutes);



const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
