class Dog
    attr_accessor :id, :name, :breed
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
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

    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(n)
        sql = "SELECT * FROM dogs WHERE id = ?"
        dog = DB[:conn].execute(sql, n)[0][0]
        self.new_from_db(dog)
    end

    def self.find_by_characteristics(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
        SQL
        DB[:conn].execute(sql, name, breed)
    end

    def self.find_or_create_by(name:, breed:)
        if !self.find_by_characteristics(name: name, breed: breed).empty?
            row = self.find_by_characteristics(name: name, breed: breed)[0]
            self.new_from_db(row)
        else
            self.create(name: name, breed: breed)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end