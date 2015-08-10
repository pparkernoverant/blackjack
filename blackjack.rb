
# Define a Deck object
class Deck
  @@suits = ['Spades', 'Hearts', 'Clubs', 'Diamonds']
  @@faces = ['Jack', 'Queen', 'King', 'Ace']
  (2..10).each {|x| @@faces << x.to_s}

  def initialize
    @cards = Array.new
    @@suits.each do |suit|
      @@faces.each do |face|
        @cards << Card.new(suit, face)
      end
    end
    @cards.shuffle!
  end

  def draw
    @cards.pop
  end
end

# Define a Card object
class Card
  attr_reader :suit, :face, :value
  
  def initialize(suit, face)
    @suit = suit
    @face = face

    if (2..10).include? face.to_i
      @value = face.to_i
    elsif ['Jack', 'Queen', 'King'].include? face
      @value = 10
    else
      @value = [1, 11]
    end
  end

  def to_s
    "#{face} of #{suit}"
  end
end

# Define a method for calculating possible scores given a set of cards
def possible_scores(cards)
  scores = [0]

  cards.each do |card|
    if card.face != 'Ace'
      scores.map! {|score| score + card.value} 
    else
      new_scores = Array.new
      scores.each do |score|
        new_scores << score + 1
        new_scores << score + 11
      end
      scores = new_scores
    end
  end

  return scores.uniq.select {|score| score < 22}
end
  

# Play Blackjack
play_again = true

while play_again
  deck = Deck.new

  # Player's turn
  puts "\nYour Turn:"
  player_stayed = false
  player_busted = false
  player_cards = Array.new
  player_cards << deck.draw

  until player_stayed || player_busted
    player_cards << deck.draw
    player_possible_scores = possible_scores(player_cards)

    if player_possible_scores.empty?
      player_busted = true
    else
      current_cards = 'Your current cards: '
      player_cards.each {|card| current_cards << card.to_s + ", "}
      puts current_cards.chop!.chop!

      player_score = 'Your score: '
      player_possible_scores.each {|score| player_score << score.to_s + " or "}
      puts player_score.chop!.chop!.chop!.chop!

      print "Hit or stay?: "
      user_input = gets.chomp.downcase
      until ['hit', 'stay'].include? user_input
        puts "Invalid input."
        print "Hit or stay?: "
        user_input = gets.chomp.downcase
      end

      player_stayed = true if user_input == 'stay'
    end
  end

  if player_busted
    puts "You drew #{player_cards[-1]} and busted! Dealer wins."
  else
    #Dealer's turn
    puts "\nDealer's Turn:"
    dealer_stayed = false
    dealer_busted = false
    dealer_cards = Array.new
    dealer_cards << deck.draw
    
    until dealer_stayed || dealer_busted
      dealer_cards << deck.draw
      dealer_possible_scores = possible_scores(dealer_cards)
      
      if dealer_possible_scores.empty?
        dealer_busted = true
      else
        current_cards = 'Dealer current cards: '
        dealer_cards.each {|card| current_cards << card.to_s + ", "}
        puts current_cards.chop!.chop!

        dealer_score = 'Dealer score: '
        dealer_possible_scores.each {|score| dealer_score << score.to_s + " or "}
        puts dealer_score.chop!.chop!.chop!.chop!

        dealer_stayed = true if !dealer_possible_scores.select {|score| score > 16 }.empty?
      end
    end

    if dealer_busted
      puts "The dealer drew #{dealer_cards[-1]} and busted. You win!"
    elsif dealer_stayed
      puts "\nFinal Scores:"
      player_high_score = player_possible_scores.max
      dealer_high_score = dealer_possible_scores.max
      puts "Your score: #{player_high_score}."
      puts "Dealer score: #{dealer_high_score}."

      if player_high_score > dealer_high_score
        puts "You win!"
      elsif dealer_high_score > player_high_score
        puts "Dealer wins!"
      else
        puts "Tie goes to the dealer. Dealer wins!"
      end
    end
  end

  puts "Play again? (Y/N)"
  play_again_input = gets.chomp
  play_again = false unless ['YES', 'Y'].include? play_again_input.upcase
end
