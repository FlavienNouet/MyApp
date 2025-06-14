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
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// Routes
app.use('/video', videoRoutes);
app.use('/user', userRoutes);

// Route de test
app.get('/', (req, res) => {
  res.json({ 
    message: 'Serveur Dayliho démarré avec succès!',
    timestamp: new Date().toISOString()
  });
});

// Nettoyage automatique des séances toutes les 30 minutes
cron.schedule('*/30 * * * *', async () => {
  console.log('🔄 Exécution du nettoyage automatique des séances...');
  try {
    await performCleanup();
  } catch (error) {
    console.error('❌ Erreur lors du nettoyage automatique:', error);
  }
});

// Nettoyage au démarrage du serveur
console.log('🚀 Démarrage du serveur Dayliho...');
performCleanup()
  .then(() => {
    console.log('✅ Nettoyage initial terminé');
  })
  .catch(error => {
    console.error('❌ Erreur lors du nettoyage initial:', error);
  });

// Gestion des erreurs globales
app.use((err, req, res, next) => {
  console.error('Erreur serveur:', err);
  res.status(500).json({
    success: false,
    message: 'Erreur interne du serveur'
  });
});

// Gestion des routes non trouvées
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée'
  });
});

app.listen(PORT, () => {
  console.log(`🌟 Serveur Dayliho démarré sur le port ${PORT}`);
  console.log(`📱 Application accessible sur http://localhost:${PORT}`);
});

module.exports = app;