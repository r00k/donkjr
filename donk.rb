require "socket"
require "json"

def store_cards(cards)
  @cards = cards
end

def ranks
  @cards.map { |card| card[0] }
end

def big_pair?
  [%w(A A),
   %w(K K),
   %w(Q Q),
   %w(J J),
   %w(T T),
   %w(9 9),
   %w(8 8)].include?(ranks)
end

def high_cards?
  [%w(A K),
   %w(K Q),
   %w(Q J),
   %w(J T),
   %w(T 9),
   %w(A Q),
   %w(K J),
   %w(Q T),
   %w(J 9),
   %w(A J),
   %w(K T),
   %w(A T)].map(&:sort).include?(ranks.sort)
end

def holding_premium_hand?
  big_pair? ||
    high_cards?
end

client = TCPSocket.new 'mongeau.local', 2000

while line = client.gets
  json = JSON.parse(line)
  case json["event"]
  when "hole"
    store_cards(json["cards"])
  when "choice"
    if holding_premium_hand?
      puts "*** Donk has #{@cards} and is RAISING"
      client.puts "RAISE"
    else
      puts "*** Donk has #{@cards} and is FOLDING"
      client.puts "FOLD"
    end
  when "game_over"
    puts "Winner: #{json['winner']}, Won?: #{json['won']}"
    break
  when "get_name"
    client.puts "DonkJr"
  end
end
