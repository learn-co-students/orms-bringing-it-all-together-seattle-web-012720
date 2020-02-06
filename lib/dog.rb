require 'pry'

class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize (id=nil, hash)
        # binding.pry
        @name = hash[:name]
        @breed = hash[:breed]
        @id = id
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def self.new_from_db(array)
        # binding.pry
        # new_dog = self.new(array)
        new_dog_id = array[0]
        new_dog_name = array[1]
        new_dog_breed = array[2]
        new_characteristics_hash = {name: new_dog_name,breed: new_dog_breed}
        # binding.pry
        new_dog = Dog.new(new_dog_id,new_characteristics_hash)
    end

    def self.find_by_id (id)
        sql = <<-SQL
                SELECT *
                FROM dogs
                WHERE id = ?
                LIMIT 1
                SQL
        DB[:conn].execute(sql, id).map do |array|
            self.new_from_db(array)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql,self.name,self.breed,self.id)
        self
    end

    def save
        if self.id
          self.update
        else
          sql = <<-SQL
              INSERT INTO dogs (name, breed)
              VALUES (?,?)
              SQL
              
        DB[:conn].execute(sql,self.name,self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
      end

    def self.create (hash)
        new_dog = self.new(hash)
        new_dog.save
    end

    def self.find_or_create_by(dog_hash)
        # binding.pry
        dog_array = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND BREED = ?", dog_hash[:name], dog_hash[:breed])
        if !dog_array.empty?
            # binding.pry
            dog_new = Dog.new_from_db(dog_array[0])
        else
            # binding.pry
            dog_new = Dog.new(dog_hash)
            dog_new.save
        end
        dog_new
    end

    def self.find_by_name (name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL
        DB[:conn].execute(sql, name).map do |array|
            self.new_from_db(array)
        end.first
    end
end