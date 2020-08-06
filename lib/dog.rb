class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create(attrs)
        new_dog = Dog.new(attrs)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        new_dog = self.create(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        new_dog = self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0])
    end

    def self.find_or_create_by(name:, breed:)
        db_dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?",name,breed)
        if db_dogs.empty?
            self.create(name: name, breed: breed)
        else
            self.new_from_db(db_dogs[0])
        end
    end

    def self.find_by_name(name)
        new_dog = self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0])
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        if self.id
            self.update
        else
            DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)", self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end

end