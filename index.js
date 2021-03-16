const express = require('express');
const bodyParser = require('body-parser');
const pg = require('pg');

const connectionString = 'postgres://combinedemo:combinedemo@db:5432/combinedemo';

const pool = new pg.Pool({
  connectionString,
});

const app = express();

app.use(bodyParser.json());

app.route("/users")
  .get(async (req, res) => {
    const { rows: users } = await pool.query(`SELECT id, name, email FROM users`);

    return res.json({ users })
  })
  .post(async (req, res) => {
    const { name, email, bio } = req.body;

    await pool.query(`INSERT INTO users (name, email, bio) VALUES ($1, $2, $3)`, [name, email, bio]);

    return res.json({ success: true });
  });

app.route("/users/:userId")
  .get(async (req, res) => {
    const { rows: users } = await pool.query(`SELECT * FROM users WHERE id=$1`, [req.params.userId])

    if (users.length > 0) {
      return res.json({ user: users[0] })
    }

    return res.status(404).json({ user: { }})
  })
  .put(async (req, res) => {
    const { userId: id } = req.params;
    const { name, email, bio } = req.body;

    await pool.query(`UPDATE users SET name=$1, email=$2, bio=$3 WHERE id=$4`, [name, email, bio, id]);

    return res.json({ success: true });
  })
  .delete(async (req, res) => {
    const { userId: id } = req.params;
    const result = await pool.query(`DELETE FROM users WHERE id=$1`, [id]);

    if (result.rowCount == 0) {
      return res.status(404).json({ success: false });
    }

    return res.json({ success: true });
  });

app.listen(8888, () => {
  console.log("Server listening on 8888...")
});
