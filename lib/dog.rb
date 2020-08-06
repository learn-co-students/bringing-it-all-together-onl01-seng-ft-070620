class Dog

    attr_accessor :id, :name, :breed

    def initialize (hash)
        hash.each {|k,v| self.send("#{k}=",v) }
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
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

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) 
            VALUES ( ?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first 
        self
    end

    def self.create(hash)
        dog = self.new(hash)
        dog.save
    end

    def self.new_from_db(row)
        dog_hash = {}
        dog_hash[:id] = row[0]
        dog_hash[:name] = row[1]
        dog_hash[:breed] = row[2]
        self.new(dog_hash)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        row = DB[:conn].execute(sql, id).flatten
        self.new_from_db(row)
    end

    def self.find_or_create_by(hash)
        name = hash[:name]
        breed = hash[:breed]
        sql = <<-SQL 
            SELECT * FROM dogs 
            WHERE name = ?
            AND breed = ?
        SQL
                
        row = DB[:conn].execute(sql, name, breed).flatten
        if row.empty?
            self.create(hash)
        else
            self.find_by_id(row.first)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        row = DB[:conn].execute(sql, name).flatten
        self.new_from_db(row)
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
        self
    end
end


