BEGIN EXCLUSIVE;

DROP TABLE IF EXISTS "notes";
CREATE TABLE "notes" (
  "path" TEXT NOT NULL,
  "title" TEXT,
  "created" TIMESTAMP NOT NULL DEFAULT (DATETIME('now','localtime')),
  "modified" TIMESTAMP NOT NULL,
  PRIMARY KEY("path")
);

DROP TABLE IF EXISTS "note_tags";
CREATE VIRTUAL TABLE note_tags USING fts4(
  "note_path" TEXT,
  "tags" TEXT,
  PRIMARY KEY("note_path")
);

DROP TABLE IF EXISTS "tags";
CREATE TABLE "tags" (
  "name" TEXT NOT NULL,
  "note_count" integer NOT NULL,
  "modified" TIMESTAMP NOT NULL DEFAULT (DATETIME('now','localtime')),
  PRIMARY KEY("name")
);

COMMIT;
