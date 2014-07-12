BEGIN EXCLUSIVE;

DROP TABLE IF EXISTS "notes";
CREATE TABLE "notes" (
  "path" TEXT NOT NULL,
  "title" TEXT,
  "context" TEXT,
  "created" TIMESTAMP NOT NULL DEFAULT (DATETIME('now','localtime')),
  "modified" TIMESTAMP NOT NULL DEFAULT (DATETIME('now','localtime')),
  PRIMARY KEY("path")
);

DROP TABLE IF EXISTS "tags";
CREATE TABLE "tags" (
  "name" TEXT NOT NULL,
  "note_count" integer NOT NULL,
  "modified" TIMESTAMP NOT NULL DEFAULT (DATETIME('now','localtime')),
  PRIMARY KEY("name")
);

DROP TABLE IF EXISTS "search_data";
CREATE VIRTUAL TABLE search_data USING fts4(
  "note_path" TEXT NOT NULL,
  "tags" TEXT,
  PRIMARY KEY("note_path")
);


COMMIT;
