CREATE TABLE IF NOT EXISTS other.authors (
  id          INT       GENERATED ALWAYS AS IDENTITY,
  name        TEXT      NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS other.books (
  id          INT       GENERATED ALWAYS AS IDENTITY,
  author_id   INT       NOT NULL,
  name        TEXT      NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT fk_authors FOREIGN KEY(author_id)
                        REFERENCES other.authors(id)
);
