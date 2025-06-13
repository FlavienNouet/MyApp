// Utilitaire pour nettoyer automatiquement les séances expirées
const db = require('../config/database');

// Fonction pour marquer les séances expirées comme non disponibles
const cleanupExpiredSeances = async () => {
  try {
    const query = `
      UPDATE videos 
      SET statut = 'expiree' 
      WHERE dateFin < CURDATE() 
      AND statut != 'expiree'
    `;
    
    const [result] = await db.execute(query);
    console.log(`${result.affectedRows} séances expirées mises à jour`);
    
    return result.affectedRows;
  } catch (error) {
    console.error('Erreur lors du nettoyage des séances expirées:', error);
    throw error;
  }
};

// Fonction pour vérifier et mettre à jour le statut des séances complètes
const updateCompleteSeances = async () => {
  try {
    const query = `
      UPDATE videos v
      SET statut = 'complete'
      WHERE v.id IN (
        SELECT seance_id 
        FROM (
          SELECT r.seance_id, COUNT(r.id) as reservations_count, v2.nombrePlaces
          FROM reservations r
          JOIN videos v2 ON r.seance_id = v2.id
          WHERE v2.statut != 'complete' AND v2.dateFin >= CURDATE()
          GROUP BY r.seance_id, v2.nombrePlaces
          HAVING reservations_count >= v2.nombrePlaces
        ) as complete_seances
      )
    `;
    
    const [result] = await db.execute(query);
    console.log(`${result.affectedRows} séances marquées comme complètes`);
    
    return result.affectedRows;
  } catch (error) {
    console.error('Erreur lors de la mise à jour des séances complètes:', error);
    throw error;
  }
};

// Fonction pour exécuter le nettoyage complet
const performCleanup = async () => {
  try {
    console.log('Début du nettoyage des séances...');
    
    const expiredCount = await cleanupExpiredSeances();
    const completeCount = await updateCompleteSeances();
    
    console.log(`Nettoyage terminé: ${expiredCount} expirées, ${completeCount} complètes`);
    
    return {
      expired: expiredCount,
      complete: completeCount
    };
  } catch (error) {
    console.error('Erreur lors du nettoyage:', error);
    throw error;
  }
};

module.exports = {
  cleanupExpiredSeances,
  updateCompleteSeances,
  performCleanup
};