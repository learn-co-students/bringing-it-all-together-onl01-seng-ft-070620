require 'pry'

class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
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
        sql = <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
   
        dog = DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
        self.new(hash).save
    end

    def self.new_from_db(row)
        self.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * from DOGS
            WHERE id = ?
            LIMIT 1
        SQL

        dog = DB[:conn].execute(sql, id)[0]
        self.new_from_db(dog)
    end

    def self.find_or_create_by(hash)
            
            sql = <<-SQL
                SELECT * FROM dogs
                WHERE (name = ? AND breed = ?)
                LIMIT 1
            SQL

            dog = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
            
            if dog.length > 0
                self.find_by_id(dog[0])
            else
                self.create(hash)
            end      
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        dog = DB[:conn].execute(sql, name).flatten
        self.find_by_id(dog[0])
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
    end
end