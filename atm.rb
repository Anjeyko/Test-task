require 'yaml'

config = YAML.load_file(ARGV.first || 'config.yml')


puts 'Please Enter Your Account Number:'
account = gets.chomp

puts 'Enter Your Password:'
password = gets.chomp

@accounts = config['accounts'][account.to_i]
@banknotes = config['banknotes']
money = @banknotes.inject(0) { |sum, (key, value)| sum + key * value }

if @accounts.nil?
  puts 'ERROR: WRONG ACCOUNT NUMBER'
  return
elsif password == @accounts['password']
  puts "Hello, #{@accounts['name']}\n"
else
  puts 'ERROR: ACCOUNT NUMBER AND PASSWORD DON\'T MATCH'
  return
end

def amount_validates(money_amount, reset)
  bills = Array(@banknotes.keys)
  values = Array(@banknotes.values)

  (@banknotes.keys.count).times do |c|
    money_in_atm = (money_amount - (money_amount % bills[c])) / bills[c]
    if money_in_atm <= values[c]
      money_amount -= bills[c] * money_in_atm
      @banknotes[bills[c]] -= money_in_atm
    else
      money_amount -= bills[c] * values[c]
    end
  end
  File.open("./config.yml", 'w') { |f| YAML.dump(reset, f) }
  money_amount == 0
end

loop do
  puts "\n\tPlease Choose From the Following Options:\n\t1. Display Balance\n\t2. Withdraw\n\t3. Log Out\n"
  atm_menu = gets.chomp.to_i
  unless (1..3).include?(atm_menu)
    puts "ERROR: PLEASE SELECT 1-3 MENU OPTIONS "
    end
  case atm_menu
    when 1
      puts "\nYour Current Balance is ₴#{@accounts['balance']}"
    when 2

      loop do
        puts "\nEnter Amount You Wish to Withdraw:\n"
        money_amount = gets.chomp.to_i

        if money_amount < 0
          puts "\nAMOUNT CAN\'T BE NEGATIVE\n"
          money_amount = 0
        elsif money_amount > money
          puts "\nTHE MAXIMUM AMOUNT AVALIBLE IN THIS ATM IS ₴#{money}. PLEASE ENTER A DIFFERENT AMOUNT:\n"
        elsif money_amount > @accounts['balance'].to_i
          puts "\nERROR: INSUFFICIENT FUNDS!! PLEASE ENTER A DIFFERENT AMOUNT:\n"
        elsif !amount_validates(money_amount, config)
          puts "\nERROR: THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. PLEASE ENTER A DIFFERENT AMOUNT:\n"
        else
          balance = @accounts['balance'].to_i - money_amount
          @accounts['balance'] = balance
          File.open("./config.yml", 'w') { |f| YAML.dump(config, f) }
          puts "\nYour New Balance is ₴#{balance}\n"
          break
        end
      end
    when 3
      puts "\n#{@accounts['name']}, Thank You For Using Our ATM. Good-Bye!"
      return
  end
end
