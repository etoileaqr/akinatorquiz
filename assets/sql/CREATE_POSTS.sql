CREATE TABLE IF NOT EXISTS posts(
    postId INTEGER PRIMARY KEY AUTOINCREMENT,
    cityId INTEGER,
    city TEXT,
    post TEXT,
    isChatGpt INTEGER,
    FOREIGN KEY (cityId) REFERENCES cities(id),
    FOREIGN KEY (city) REFERENCES cities(city)
)