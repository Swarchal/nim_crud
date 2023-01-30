import std/[db_sqlite, strutils]

type
  Database* = ref object
    con: DbConn

  Contact* = object
    id*: int
    name*: string
    email*: string


proc createDb*(name="contacts.db"): Database =
  let db = open(name, "", "", "")
  db.exec(
    sql"""
    CREATE TABLE IF NOT EXISTS Contacts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR(128) NOT NULL UNIQUE,
      email VARCHAR(128)
    )
    """
  )
  return Database(con: db)


func parse(r: Row): Contact =
  return Contact(id: r[0].parseInt, name: r[1], email: r[2])


proc all*(db: Database): seq[Contact] =
  ## read all contacts
  for row in db.con.fastRows(sql"SELECT id, name, email FROM Contacts"):
    result.add(row.parse)


proc get*(db: Database, id: int): Contact =
  ## read single contact by id
  let row = db.con.getRow(sql"SELECT id, name, email FROM Contacts WHERE id = ?", $id)
  if row[0].len == 0:
    return Contact()
  return row.parse


proc create*(db: Database, c: Contact): bool =
  let id = db.con.tryInsertID(
    sql"INSERT INTO Contacts (name, email) VALUES (?, ?)", c.name, c.email
  )
  return id != -1


proc update*(db: Database, c: Contact): bool =
  return db.con.tryExec(
    sql"UPDATE Contacts SET name = ?, email = ? WHERE id = ?",
    c.name, c.email, $c.id
  )


proc delete*(db: Database, id: int): bool =
  return db.con.tryExec(sql"DELETE FROM Contacts WHERE id = ?", $id)
