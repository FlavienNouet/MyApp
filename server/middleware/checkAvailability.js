// Middleware pour vérifier la disponibilité des séances
const db = require('../config/database');

const checkSeanceAvailability = async (req, res, next) => {
  const { seanceId } = req.params;
  
  try {
    // Vérifier si la séance a encore des places disponibles
    const [seanceCheck] = await db.execute(`
      SELECT v.*, 
             COALESCE(COUNT(r.id), 0) as places_reservees,
             (v.nombrePlaces - COALESCE(COUNT(r.id), 0)) as places_restantes
      FROM videos v
      LEFT JOIN reservations r ON v.id = r.seance_id
      WHERE v.id = ? AND v.dateFin >= CURDATE()
      GROUP BY v.id
    `, [seanceId]);
    
    if (seanceCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Séance non trouvée ou expirée'
      });
    }
    
    const seance = seanceCheck[0];
    
    if (seance.places_restantes <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Cette séance est complète'
      });
    }
    
    // Ajouter les informations de la séance à la requête
    req.seanceInfo = seance;
    next();
    
  } catch (error) {
    console.error('Erreur lors de la vérification de disponibilité:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur'
    });
  }
};

module.exports = { checkSeanceAvailability };