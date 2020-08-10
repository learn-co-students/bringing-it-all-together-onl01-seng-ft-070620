

class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    self.id = id
    self.name = name
    self.breed = breed
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.create(id: nil, name:, breed:)
    Dog.new(id: id, name: name, breed: breed).save
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    return self
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL

    DB[:conn].execute(sql, name).collect{|row| Dog.new_from_db(row)}.first
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL

    DB[:conn].execute(sql, id).collect{|row| Dog.new_from_db(row)}.first
  end

  def self.find_or_create_by(name:, breed:)
    if self.find_by_name(name).breed == breed
      sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
      SQL

      DB[:conn].execute(sql, name, breed).collect{|row| Dog.new_from_db(row)}.first
    else
      self.create(name: name, breed: breed)
    end
  end

end
