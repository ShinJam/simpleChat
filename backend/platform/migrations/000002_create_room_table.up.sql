-- Create room table
CREATE TABLE IF NOT EXISTS kuve.room (
  id VARCHAR(255) NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  private BOOLEAN NULL
);
