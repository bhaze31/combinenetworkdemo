const express = require('express');
const bodyParser = require('body-parser');
const pg = require('pg');

const connectionString = 'postgres://combinedemo:combinedemo@db:5432/combinedemo';

const pool = new pg.Pool({
  connectionString,
});

const app = express();

const logRequests = (req, res, next) => {
  const start = Date.now();
  res.on("finish", () => {
    const diff = Date.now() - start;
    console.log(`[!!] ${req.method}: ${req.path} ${res.statusCode} - ${diff}ms`);
  });
  next();
};

app.use(bodyParser.json());

app.use(logRequests)

app.route("/users")
  .get(async (req, res) => {
    const { rows: users } = await pool.query(`SELECT id, name, email FROM users`);

    return res.json({ users })
  })
  .post(async (req, res) => {
    const { name, email, bio } = req.body;

    const { rows: users } = await pool.query(`INSERT INTO users (name, email, bio) VALUES ($1, $2, $3) RETURNING *`, [name, email, bio]);

    return res.json({ user: users[0] });
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

    if (id == 2) {
      return res.status(401).json({})
    }
    const { name, email, bio } = req.body;

    const { rows: users } = await pool.query(`UPDATE users SET name=$1, email=$2, bio=$3 WHERE id=$4 RETURNING *`, [name, email, bio, id]);

    if (users.length > 0) {
      return res.json({ user: users[0] })
    }

    return res.status(404).json({ user: { }})
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
