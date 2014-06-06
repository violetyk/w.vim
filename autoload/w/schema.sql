BEGIN EXCLUSIVE;

DROP TABLE IF EXISTS "memos";
CREATE TABLE "memos" (
  "path" TEXT NOT NULL,
  "title" TEXT,
  "created" TIMESTAMP NOT NULL DEFAULT (DATETIME('now','localtime')),
  "modified" TIMESTAMP NOT NULL,
  PRIMARY KEY("path")
);

DROP TABLE IF EXISTS "memo_tags";
CREATE VIRTUAL TABLE memo_tags USING fts4(
  "memo_path" TEXT,
  "tags" TEXT,
  PRIMARY KEY("memo_path")
);

DROP TABLE IF EXISTS "tags";
CREATE TABLE "tags" (
  "name" TEXT NOT NULL,
  "memo_count" integer NOT NULL,
  "modified" TIMESTAMP NOT NULL DEFAULT (DATETIME('now','localtime')),
  PRIMARY KEY("name")
);

COMMIT;
