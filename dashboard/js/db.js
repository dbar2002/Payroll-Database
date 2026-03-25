let db;

function query(sql) {
  try {
    const result = db.exec(sql);
    if (!result.length) return { columns: [], rows: [] };
    return { columns: result[0].columns, rows: result[0].values };
  } catch (e) {
    return { error: e.message };
  }
}

async function initDB() {
  const SQL = await initSqlJs({
    locateFile: f => `https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.11.0/${f}`
  });

  const [schema, seed, views] = await Promise.all([
    fetch('../sql/01_schema.sql').then(r => r.text()),
    fetch('../sql/02_seed_data.sql').then(r => r.text()),
    fetch('../sql/04_views_triggers.sql').then(r => r.text()),
  ]);

  db = new SQL.Database();
  db.run("PRAGMA foreign_keys = ON;");
  db.run(schema);
  db.run(seed);
  db.run(views);

  return db;
}
