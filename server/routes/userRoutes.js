// Routes pour la gestion des utilisateurs avec modification de mot de passe
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

const JWT_SECRET = 'your_jwt_secret_key'; // À changer en production

// Route pour vérifier un utilisateur (connexion)
router.post('/checkUser', async (req, res) => {
  const { email, mot_de_passe } = req.body;
  
  try {
    // Rechercher l'utilisateur par email
    const [users] = await db.execute(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );
    
    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Email ou mot de passe incorrect'
      });
    }
    
    const user = users[0];
    
    // Vérifier le mot de passe
    const isPasswordValid = await bcrypt.compare(mot_de_passe, user.mot_de_passe);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Email ou mot de passe incorrect'
      });
    }
    
    // Générer un token JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    res.status(200).json({
      success: true,
      message: 'Connexion réussie',
      token: token,
      userId: user.id,
      user: {
        id: user.id,
        nom: user.nom,
        prenom: user.prenom,
        email: user.email,
        role: user.role
      }
    });
    
  } catch (error) {
    console.error('Erreur lors de la vérification de l\'utilisateur:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur'
    });
  }
});

// Route pour récupérer un utilisateur par ID
router.get('/getUserById', async (req, res) => {
  const { id } = req.query;
  
  try {
    const [users] = await db.execute(
      'SELECT id, nom, prenom, email, role, created_at FROM users WHERE id = ?',
      [id]
    );
    
    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé'
      });
    }
    
    res.status(200).json(users[0]);
    
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'utilisateur:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur'
    });
  }
});

// Route pour modifier le mot de passe
router.put('/changePassword', async (req, res) => {
  const { userId, currentPassword, newPassword } = req.body;
  
  try {
    // Vérifier que tous les champs sont fournis
    if (!userId || !currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Tous les champs sont requis'
      });
    }
    
    // Vérifier que le nouveau mot de passe est différent de l'ancien
    if (currentPassword === newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Le nouveau mot de passe doit être différent de l\'ancien'
      });
    }
    
    // Récupérer l'utilisateur
    const [users] = await db.execute(
      'SELECT * FROM users WHERE id = ?',
      [userId]
    );
    
    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé'
      });
    }
    
    const user = users[0];
    
    // Vérifier le mot de passe actuel
    const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.mot_de_passe);
    
    if (!isCurrentPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Mot de passe actuel incorrect'
      });
    }
    
    // Hasher le nouveau mot de passe
    const saltRounds = 10;
    const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);
    
    // Mettre à jour le mot de passe dans la base de données
    await db.execute(
      'UPDATE users SET mot_de_passe = ?, updated_at = NOW() WHERE id = ?',
      [hashedNewPassword, userId]
    );
    
    res.status(200).json({
      success: true,
      message: 'Mot de passe modifié avec succès'
    });
    
  } catch (error) {
    console.error('Erreur lors de la modification du mot de passe:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur lors de la modification du mot de passe'
    });
  }
});

// Route pour créer un nouvel utilisateur (inscription)
router.post('/createUser', async (req, res) => {
  const { nom, prenom, email, mot_de_passe, role = 'user' } = req.body;
  
  try {
    // Vérifier que tous les champs requis sont fournis
    if (!nom || !prenom || !email || !mot_de_passe) {
      return res.status(400).json({
        success: false,
        message: 'Tous les champs sont requis'
      });
    }
    
    // Vérifier si l'email existe déjà
    const [existingUsers] = await db.execute(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );
    
    if (existingUsers.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Un utilisateur avec cet email existe déjà'
      });
    }
    
    // Hasher le mot de passe
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(mot_de_passe, saltRounds);
    
    // Créer l'utilisateur
    const [result] = await db.execute(
      'INSERT INTO users (nom, prenom, email, mot_de_passe, role, created_at) VALUES (?, ?, ?, ?, ?, NOW())',
      [nom, prenom, email, hashedPassword, role]
    );
    
    // Générer un token JWT
    const token = jwt.sign(
      { userId: result.insertId, email: email },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    res.status(201).json({
      success: true,
      message: 'Utilisateur créé avec succès',
      token: token,
      userId: result.insertId
    });
    
  } catch (error) {
    console.error('Erreur lors de la création de l\'utilisateur:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur lors de la création de l\'utilisateur'
    });
  }
});

// Middleware pour vérifier le token JWT
const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Token d\'authentification requis'
    });
  }
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Token invalide'
    });
  }
};

// Route protégée pour mettre à jour le profil utilisateur
router.put('/updateProfile', verifyToken, async (req, res) => {
  const { nom, prenom, email } = req.body;
  const userId = req.user.userId;
  
  try {
    // Vérifier si l'email existe déjà pour un autre utilisateur
    if (email) {
      const [existingUsers] = await db.execute(
        'SELECT id FROM users WHERE email = ? AND id != ?',
        [email, userId]
      );
      
      if (existingUsers.length > 0) {
        return res.status(409).json({
          success: false,
          message: 'Un autre utilisateur utilise déjà cet email'
        });
      }
    }
    
    // Construire la requête de mise à jour dynamiquement
    const updates = [];
    const values = [];
    
    if (nom) {
      updates.push('nom = ?');
      values.push(nom);
    }
    if (prenom) {
      updates.push('prenom = ?');
      values.push(prenom);
    }
    if (email) {
      updates.push('email = ?');
      values.push(email);
    }
    
    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Aucune donnée à mettre à jour'
      });
    }
    
    updates.push('updated_at = NOW()');
    values.push(userId);
    
    const query = `UPDATE users SET ${updates.join(', ')} WHERE id = ?`;
    
    await db.execute(query, values);
    
    res.status(200).json({
      success: true,
      message: 'Profil mis à jour avec succès'
    });
    
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur lors de la mise à jour du profil'
    });
  }
});

module.exports = router;