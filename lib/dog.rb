class Dog 
  
  attr_accessor :id , :name , :breed 
  
  def initialize(name: ,breed: ,id: nil)
    @id=id 
    @name=name 
    @breed=breed 
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
     sql = <<-SQL
     DROP TABLE IF EXISTS dogs;
     SQL
     DB[:conn].execute(sql)
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
        self
    end 
    
    def self.create(name:,breed:)
      dog=self.new(name: name ,breed: breed)
      dog.save
      dog
    end 
   
   def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end 
    
    def self.find_by_id(id)
      sql = <<-SQL
      SELECT *
      FROM dogs 
      WHERE id = ?
      LIMIT 1
      SQL
      DB[:conn].execute(sql, id).collect do |row|
            self.new_from_db(row)
        end.first
      end
      
      def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ? 
            LIMIT 1
        SQL

        dog_array = DB[:conn].execute(sql, name, breed)
        if !dog_array.empty?
            row = dog_array[0]
            dog = self.new(id: row[0], name: row[1], breed: row[2])
        else 
            dog = self.create(name: name, breed: breed)
        end
        dog
    end 
    
     def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"

        DB[:conn].execute(sql, name).collect do |row|
            self.new_from_db(row)
        end.first 
    end 

    def update 
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    
    
  
  
  
  
  
  
  
  
  
  
  
  
end 