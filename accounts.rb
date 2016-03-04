module Bank
  class Owner
    attr_reader :name
    def initialize(options)
      @name    = options[:name]
      @address = options[:address]
      @pin     = options[:pin]
    end

    def self.bank_owned
      self.new(name: "BANK OWNED")
    end
  end

  class Account
    attr_reader :balance, :owner

    MIN_BALANCE = 0
    MESSAGES = {
      no_money: "This transaction cannot proceed. Account balance is too low."
    }

    def initialize(id, starting_balance, owner = Bank::Owner.bank_owned)
      raise ArgumentError, MESSAGES[:no_money] unless enough_money?(starting_balance)

      @id = id
      @balance = starting_balance
      @owner = owner
    end

    def withdraw(amount)
      if balance - amount < MIN_BALANCE
        puts MESSAGES[:no_money]
      else
        @balance = balance - amount
      end

      balance
    end

    def deposit(amount)
      @balance = balance + amount
    end

    private
    def enough_money?(monies = balance)
      monies >= MIN_BALANCE
    end

  end
end
