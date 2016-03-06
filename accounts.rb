require 'CSV'

module Bank
  class Owner
    attr_reader :name, :id

    CSV_FILE = "./support/owners.csv"
    LINK_FILE = "./support/account_owners.csv"

    def initialize(options)
      @id      = options[:id].to_i
      @name    = options[:name]
      @address = options[:address]
      @city    = options[:city]
      @state   = options[:state]
    end

    def self.bank_owned
      self.new(name: "BANK OWNED", id: 666)
    end

    def accounts(datafile = LINK_FILE)
      raw_data = CSV.read(datafile, 'r')
      found = raw_data.collect do |row|
        row[1].to_i == id ? Bank::Account.find(row[0].to_i) : nil
      end

      found.compact
    end

    def self.all(datafile = CSV_FILE)
      raw_data = CSV.read(datafile, 'r')
      raw_data.collect do |row|
        self.new_from_csv(row)
      end
    end

    def self.find(id, datafile = CSV_FILE)
      raw_data = CSV.read(datafile, 'r')
      raw_data.each do |row|
        if row[0].to_i == id #short circuit when we match
          return self.new_from_csv(row)
        end
      end

      nil #no account found
    end

    private
    def self.new_from_csv(row)
      data = {
        id:      row[0],
        name:    "#{ row[2] } #{ row[1] }",
        address: row[3],
        city:    row[4],
        state:   row[5]
      }

      self.new(data)
    end

  end

  class Account
    attr_reader :balance, :owner, :id

    MIN_BALANCE = 0
    CSV_FILE = "./support/accounts.csv"
    LINK_FILE = "./support/account_owners.csv"
    MESSAGES = {
      no_money: "This transaction cannot proceed. Account balance is too low."
    }

    def initialize(data)
      raise ArgumentError, MESSAGES[:no_money] unless enough_money?(data[:starting_balance].to_i)

      @id      = data[:id].to_i
      @balance = data[:starting_balance].to_i
      @opened  = data[:opened]
      @owner   = data[:owner]# || Bank::Owner.bank_owned
    end

    def owner
      @owner || link_owner!
    end

    def withdraw(amount)
      if balance - amount < MIN_BALANCE
        puts MESSAGES[:no_money]
      else
        @balance = balance - amount
      end

      balance
    end

    def self.all(datafile = CSV_FILE)
      raw_data = CSV.read(datafile, 'r')
      raw_data.collect do |row|
        self.new_from_csv(row)
      end
    end

    def self.find(id, datafile = CSV_FILE)
      raw_data = CSV.read(datafile, 'r')
      raw_data.each do |row|
        if row[0].to_i == id #short circuit when we match
          return self.new_from_csv(row)
        end
      end

      nil #no account found
    end

    def deposit(amount)
      @balance = balance + amount
    end

    private
    def enough_money?(monies = balance)
      monies >= MIN_BALANCE
    end

    def self.new_from_csv(row)
      return self.new(id: row[0], starting_balance: row[1], opened: row[2])
    end

    def link_owner!(datafile = LINK_FILE)
      raw_data = CSV.read(datafile, 'r')
      found_id = raw_data.find do |row|
        row[0].to_i == id
      end

      found_id ? Bank::Owner.find(found_id[1].to_i) : Bank::Owner.bank_owned
    end
  end
end
