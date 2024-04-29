CREATE TABLE IF NOT EXISTS posts(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    genre TEXT,
    category TEXT,
    level INTEGER,
    answer TEXT,
    content TEXT,
    isChatGpt INTEGER,
    postTime TEXT
)