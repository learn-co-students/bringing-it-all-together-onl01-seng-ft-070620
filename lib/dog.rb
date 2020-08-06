class Dog
  attr_accessor :id, :name, :breed

# accepts key-value pairs as arguments to initialize
  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

# creates the dogs table in the database
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

# drops the dogs table from the database
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

# saves the instance's attributes to the database table
# assigns that new row's id as an attribute to the instance
# returns the instance
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
    self
  end
# creates a new Dog instance with passed in attributes, uses #save to save that dog to the database
# would be called like: Dog.create(name: "Dave", breed: "poodle")
# need to initialize Dog instances like: Dog.new(name: "Dave", breed: "poodle")
  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

# creates a new Dog instance given a row from the database table with its attributes
  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

# returns a new Dog instance given its id attribute
# query for the proper row, given this id number
# query will return an array within an array
# use the array within the array to create a new Dog instance
# return that new instance
  def self.find_by_id(id_number)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.id = ?
    SQL

    DB[:conn].execute(sql, id_number).map do |row|
      self.new_from_db(row)
    end.first
  end

# creates a new dog instance if there isn't already an instance with the same name and breed
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE dogs.name = ? AND dogs.breed = ?", name, breed)

    if !dog.empty? # if the record already exists...
      dog_data = dog[0] # dog local variable is an array nested in another array... we just want an array
      new_dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else # if the record doesn't already exist
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

# returns the Dog instance with a name attribute matching the argument
  def self.find_by_name(dog_name)
    sql = "SELECT * FROM dogs WHERE dogs.name = ? LIMIT 1"

    DB[:conn].execute(sql, dog_name).map do |row|
      self.new_from_db(row)
    end.first
  end

# updates the associated record with a given Dog instance's attributes
# unsure why using table_name.column_name syntax doesn't work here
# need to simply point to column_name for the test to pass
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
