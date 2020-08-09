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
            DROP TABLE dogs;
        SQL

        DB[:conn].execute(sql)

        #or all the above in one line:
        #DB[:conn].execute("DROP TABLE dogs")
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

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end
    
    def self.new_from_db(row)
        new_dog = self.new(id: row[0], name: row[1], breed: row[2])        
    end
    
    def self.find_by_id(id_num)
        sql = "SELECT * FROM dogs WHERE id = ?"

        DB[:conn].execute(sql, id_num).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

        if dog.empty? 
            new_dog = self.create(name: name, breed: breed)
        else
            dog_info = dog[0] #dog is a nested array. This returns the array within the array.

            new_dog = self.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
        end
        new_dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end
end