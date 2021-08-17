CREATE TABLE USERS(
  user_id        SERIAL PRIMARY KEY,
  status         CHAR(2),
  name           VARCHAR(20),
  password       VARCHAR(64)
);

CREATE TABLE USER_DETAILS(
  user_id        INTEGER,
  email          VARCHAR(100),
  address        VARCHAR(100)
);