// Routes pour la gestion des vidéos/séances
const express = require('express');
const router = express.Router();
const db = require('../config/database'); // Votre configuration de base de données

// Route pour récupérer toutes les séances disponibles (avec places restantes)
router.get('/getVideos', async (req, res) => {
  try {
    const query = `
      SELECT v.*, 
             COALESCE(COUNT(r.id), 0) as places_reservees,
             (v.nombrePlaces - COALESCE(COUNT(r.id), 0)) as places_restantes
      FROM videos v
      LEFT JOIN reservations r ON v.id = r.seance_id
      WHERE v.nombrePlaces > COALESCE(COUNT(r.id), 0)
      AND v.dateFin >= CURDATE()
      GROUP BY v.id
      HAVING places_restantes > 0
      ORDER BY v.dateDebut ASC
    `;
    
    const [results] = await db.execute(query);
    res.status(200).json(results);
  } catch (error) {
    console.error('Erreur lors de la récupération des séances:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Erreur serveur lors de la récupération des séances' 
    });
  }
});

// Route pour réserver une séance avec vérification des places
router.post('/bookSeance/:userId/:seanceId', async (req, res) => {
  const { userId, seanceId } = req.params;
  
  try {
    // Commencer une transaction pour éviter les conditions de course
    await db.beginTransaction();
    
    // Vérifier si l'utilisateur existe
    const [userCheck] = await db.execute(
      'SELECT id FROM users WHERE id = ?', 
      [userId]
    );
    
    if (userCheck.length === 0) {
      await db.rollback();
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé'
      });
    }
    
    // Vérifier si la séance existe et récupérer les informations
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
      await db.rollback();
      return res.status(404).json({
        success: false,
        message: 'Séance non trouvée ou expirée'
      });
    }
    
    const seance = seanceCheck[0];
    
    // Vérifier s'il reste des places disponibles
    if (seance.places_restantes <= 0) {
      await db.rollback();
      return res.status(400).json({
        success: false,
        message: 'Cette séance est complète, aucune place disponible'
      });
    }
    
    // Vérifier si l'utilisateur a déjà réservé cette séance
    const [existingReservation] = await db.execute(
      'SELECT id FROM reservations WHERE user_id = ? AND seance_id = ?',
      [userId, seanceId]
    );
    
    if (existingReservation.length > 0) {
      await db.rollback();
      return res.status(400).json({
        success: false,
        message: 'Vous avez déjà réservé cette séance'
      });
    }
    
    // Créer la réservation
    const [insertResult] = await db.execute(
      'INSERT INTO reservations (user_id, seance_id, date_reservation) VALUES (?, ?, NOW())',
      [userId, seanceId]
    );
    
    // Vérifier si la séance est maintenant complète
    const [updatedSeance] = await db.execute(`
      SELECT v.nombrePlaces,
             COALESCE(COUNT(r.id), 0) as places_reservees
      FROM videos v
      LEFT JOIN reservations r ON v.id = r.seance_id
      WHERE v.id = ?
      GROUP BY v.id
    `, [seanceId]);
    
    const isSeanceComplete = updatedSeance[0].places_reservees >= updatedSeance[0].nombrePlaces;
    
    // Optionnel : Marquer la séance comme complète dans la base de données
    if (isSeanceComplete) {
      await db.execute(
        'UPDATE videos SET statut = "complete" WHERE id = ?',
        [seanceId]
      );
    }
    
    // Valider la transaction
    await db.commit();
    
    res.status(201).json({
      success: true,
      message: 'Réservation effectuée avec succès',
      reservationId: insertResult.insertId,
      seanceComplete: isSeanceComplete,
      placesRestantes: updatedSeance[0].nombrePlaces - updatedSeance[0].places_reservees
    });
    
  } catch (error) {
    // Annuler la transaction en cas d'erreur
    await db.rollback();
    console.error('Erreur lors de la réservation:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur lors de la réservation'
    });
  }
});

// Route pour récupérer les séances réservées par un utilisateur
router.get('/getBookedSeances/:userId', async (req, res) => {
  const { userId } = req.params;
  
  try {
    const query = `
      SELECT v.*, r.date_reservation,
             COALESCE(COUNT(r2.id), 0) as places_reservees,
             (v.nombrePlaces - COALESCE(COUNT(r2.id), 0)) as places_restantes
      FROM reservations r
      JOIN videos v ON r.seance_id = v.id
      LEFT JOIN reservations r2 ON v.id = r2.seance_id
      WHERE r.user_id = ?
      GROUP BY v.id, r.date_reservation
      ORDER BY v.dateDebut ASC
    `;
    
    const [results] = await db.execute(query, [userId]);
    res.status(200).json(results);
  } catch (error) {
    console.error('Erreur lors de la récupération des réservations:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur lors de la récupération des réservations'
    });
  }
});

// Route pour supprimer une réservation
router.delete('/deleteReservation/:userId/:seanceId', async (req, res) => {
  const { userId, seanceId } = req.params;
  
  try {
    await db.beginTransaction();
    
    // Vérifier que la réservation existe
    const [reservationCheck] = await db.execute(
      'SELECT id FROM reservations WHERE user_id = ? AND seance_id = ?',
      [userId, seanceId]
    );
    
    if (reservationCheck.length === 0) {
      await db.rollback();
      return res.status(404).json({
        success: false,
        message: 'Réservation non trouvée'
      });
    }
    
    // Supprimer la réservation
    await db.execute(
      'DELETE FROM reservations WHERE user_id = ? AND seance_id = ?',
      [userId, seanceId]
    );
    
    // Remettre la séance comme disponible si elle était marquée comme complète
    await db.execute(
      'UPDATE videos SET statut = "disponible" WHERE id = ?',
      [seanceId]
    );
    
    await db.commit();
    
    res.status(200).json({
      success: true,
      message: 'Réservation supprimée avec succès'
    });
    
  } catch (error) {
    await db.rollback();
    console.error('Erreur lors de la suppression:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur lors de la suppression'
    });
  }
});

// Route pour obtenir les statistiques d'une séance
router.get('/getSeanceStats/:seanceId', async (req, res) => {
  const { seanceId } = req.params;
  
  try {
    const query = `
      SELECT v.*, 
             COALESCE(COUNT(r.id), 0) as places_reservees,
             (v.nombrePlaces - COALESCE(COUNT(r.id), 0)) as places_restantes,
             CASE 
               WHEN COALESCE(COUNT(r.id), 0) >= v.nombrePlaces THEN 'complete'
               WHEN COALESCE(COUNT(r.id), 0) > 0 THEN 'partiellement_reservee'
               ELSE 'disponible'
             END as statut_reservation
      FROM videos v
      LEFT JOIN reservations r ON v.id = r.seance_id
      WHERE v.id = ?
      GROUP BY v.id
    `;
    
    const [results] = await db.execute(query, [seanceId]);
    
    if (results.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Séance non trouvée'
      });
    }
    
    res.status(200).json({
      success: true,
      data: results[0]
    });
    
  } catch (error) {
    console.error('Erreur lors de la récupération des statistiques:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur'
    });
  }
});

module.exports = router;