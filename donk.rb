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

def holding_premium_hand?
  big_pair?
end

Thread.new do
  client = TCPSocket.new 'localhost', 2000

  while line = client.gets
    json = JSON.parse(line)
    puts json
    case json["event"]
    when "hole"
      store_cards(json["cards"])
    when "choice"
      if holding_premium_hand?
        puts "raising"
        client.puts "RAISE"
      else
        puts "folding"
        client.puts "FOLD"
      end
    when "game_over"
      puts "WINNERS DECLARED"
      break
    when "get_name"
      client.puts "DonkJr"
    end
  end
end

3.times.map do |i|
  Thread.new do
    client = TCPSocket.new 'localhost', 2000

    while line = client.gets
      json = JSON.parse(line)
      case json["event"]
      when "choice"
        choice = %w(RAISE CALL FOLD).sample
        client.puts choice
      when "game_over"
        break
      when "get_name"
        client.puts "Rando #{i}"
      end
    end
  end
end.map(&:join)
