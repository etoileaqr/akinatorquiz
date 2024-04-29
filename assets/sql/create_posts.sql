CREATE TABLE IF NOT EXISTS posts(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    genre TEXT,
    category TEXT,
    scope TEXT,
    answer TEXT,
    content TEXT,
    isChatGpt INTEGER,
    postTime TEXT
)