// Configuration de la base de données avec support des transactions
const mysql = require('mysql2/promise');

const dbConfig = {
  host: 'localhost',
  user: 'your_username',
  password: 'your_password',
  database: 'your_database',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

// Créer un pool de connexions
const pool = mysql.createPool(dbConfig);

// Fonction pour commencer une transaction
const beginTransaction = async () => {
  const connection = await pool.getConnection();
  await connection.beginTransaction();
  return connection;
};

// Fonction pour valider une transaction
const commit = async (connection) => {
  await connection.commit();
  connection.release();
};

// Fonction pour annuler une transaction
const rollback = async (connection) => {
  await connection.rollback();
  connection.release();
};

// Exporter le pool et les fonctions de transaction
module.exports = {
  execute: (query, params) => pool.execute(query, params),
  beginTransaction,
  commit,
  rollback,
  pool
};