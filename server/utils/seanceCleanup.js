// Utilitaire pour nettoyer automatiquement les séances expirées
const db = require('../config/database');

// Fonction pour marquer les séances expirées comme non disponibles
const cleanupExpiredSeances = async () => {
  try {
    const query = `
      UPDATE videos 
      SET statut = 'expiree' 
      WHERE dateFin < CURDATE() 
      AND (statut IS NULL OR statut != 'expiree')
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
    // Marquer les séances complètes
    const queryComplete = `
      UPDATE videos v
      SET statut = 'complete'
      WHERE v.id IN (
        SELECT * FROM (
          SELECT v2.id
          FROM videos v2
          LEFT JOIN reservations r ON v2.id = r.seance_id
          WHERE v2.dateFin >= CURDATE()
          AND (v2.statut IS NULL OR v2.statut != 'complete')
          GROUP BY v2.id
          HAVING COALESCE(COUNT(r.id), 0) >= v2.nombrePlaces
        ) as complete_seances
      )
    `;
    
    const [result] = await db.execute(queryComplete);
    console.log(`${result.affectedRows} séances marquées comme complètes`);
    
    return result.affectedRows;
  } catch (error) {
    console.error('Erreur lors de la mise à jour des séances complètes:', error);
    throw error;
  }
};

// Fonction pour remettre en disponible les séances qui ont des places libres
const updateAvailableSeances = async () => {
  try {
    const query = `
      UPDATE videos v
      SET statut = 'disponible'
      WHERE v.id IN (
        SELECT * FROM (
          SELECT v2.id
          FROM videos v2
          LEFT JOIN reservations r ON v2.id = r.seance_id
          WHERE v2.dateFin >= CURDATE()
          AND v2.statut = 'complete'
          GROUP BY v2.id
          HAVING COALESCE(COUNT(r.id), 0) < v2.nombrePlaces
        ) as available_seances
      )
    `;
    
    const [result] = await db.execute(query);
    console.log(`${result.affectedRows} séances remises en disponible`);
    
    return result.affectedRows;
  } catch (error) {
    console.error('Erreur lors de la mise à jour des séances disponibles:', error);
    throw error;
  }
};

// Fonction pour exécuter le nettoyage complet
const performCleanup = async () => {
  try {
    console.log('🧹 Début du nettoyage des séances...');
    
    const expiredCount = await cleanupExpiredSeances();
    const completeCount = await updateCompleteSeances();
    const availableCount = await updateAvailableSeances();
    
    console.log(`✅ Nettoyage terminé: ${expiredCount} expirées, ${completeCount} complètes, ${availableCount} remises en disponible`);
    
    return {
      expired: expiredCount,
      complete: completeCount,
      available: availableCount
    };
  } catch (error) {
    console.error('❌ Erreur lors du nettoyage:', error);
    throw error;
  }
};

module.exports = {
  cleanupExpiredSeances,
  updateCompleteSeances,
  updateAvailableSeances,
  performCleanup
};