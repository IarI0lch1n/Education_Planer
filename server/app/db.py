# SQLite setup. The database file is created automatically on first start.
#
# EduPlan adds two entities:
# - courses
# - assignments
#
# Both belong to the authenticated user.

import sqlite3
from datetime import datetime, timezone
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

_SCHEMA = """
CREATE TABLE IF NOT EXISTS users (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  email         TEXT    NOT NULL UNIQUE,
  password_hash TEXT    NOT NULL,
  name          TEXT    NOT NULL,
  created_at    TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS notes (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    INTEGER NOT NULL REFERENCES users (id),
  title      TEXT    NOT NULL,
  content    TEXT    NOT NULL DEFAULT '',
  created_at TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS courses (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    INTEGER NOT NULL REFERENCES users (id),
  name       TEXT    NOT NULL,
  teacher    TEXT    NOT NULL,
  room       TEXT    NOT NULL,
  weekday    TEXT    NOT NULL,
  start_time TEXT    NOT NULL,
  created_at TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS assignments (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    INTEGER NOT NULL REFERENCES users (id),
  course_id  INTEGER NOT NULL REFERENCES courses (id) ON DELETE CASCADE,
  title      TEXT    NOT NULL,
  deadline   TEXT    NOT NULL,
  status     TEXT    NOT NULL,
  priority   TEXT    NOT NULL,
  created_at TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS files (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    INTEGER NOT NULL REFERENCES users (id),
  name       TEXT    NOT NULL,
  mime_type  TEXT    NOT NULL,
  size       INTEGER NOT NULL,
  path       TEXT    NOT NULL,
  created_at TEXT    NOT NULL
);
"""

conn = sqlite3.connect(
    BASE_DIR / "app.db",
    check_same_thread=False,
    isolation_level=None,
)

conn.row_factory = sqlite3.Row

# Enable SQLite foreign keys so deleting a course can also remove
# its assignments through ON DELETE CASCADE.
conn.execute("PRAGMA foreign_keys = ON")

conn.executescript(_SCHEMA)


def now_iso():
    """Current UTC time in ISO-8601 format."""
    return (
        datetime.now(timezone.utc)
        .isoformat(timespec="milliseconds")
        .replace("+00:00", "Z")
    )