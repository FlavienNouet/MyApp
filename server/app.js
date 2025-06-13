// Application principale avec nettoyage automatique
const express = require('express');
const cors = require('cors');
const cron = require('node-cron');
const videoRoutes = require('./routes/videoRoutes');
const userRoutes = require('./routes/userRoutes');
const { performCleanup } = require('./utils/seanceCleanup');

const app = express();
const PORT = process.env.PORT || 1234;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/video', videoRoutes);
app.use('/user', userRoutes);

// Nettoyage automatique des séances toutes les heures
cron.schedule('0 * * * *', async () => {
  console.log('Exécution du nettoyage automatique des séances...');
  try {
    await performCleanup();
  } catch (error) {
    console.error('Erreur lors du nettoyage automatique:', error);
  }
});

// Nettoyage au démarrage du serveur
performCleanup().catch(console.error);

app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
});

module.exports = app;