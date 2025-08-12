CREATE DATABASE IF NOT EXISTS lolland DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE lolland;

DROP TABLE IF EXISTS auction_item;
CREATE TABLE auction_item (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  start_price INT NOT NULL
);

INSERT INTO auction_item (title, start_price) VALUES
('Bronze Sword', 1000),
('Silver Shield', 2000),
('Gold Staff', 3500);
