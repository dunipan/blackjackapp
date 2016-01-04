require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
	erb :user_name_form
end

post '/user_name_form' do
	if params[:user_name].empty?
		@error = "You need to enter a name"
		halt erb(:user_name_form)
	else
		session[:user_name] = params[:user_name]
		redirect '/user_betting'
	end
end

get '/user_betting' do
	session[:funds] = 500
	erb :user_betting
end


post '/user_betting' do 
	if params[:user_bet].empty? || params[:user_bet].to_i <1
		@error = "You need to place an appropriate bet"
		halt erb(:user_betting)
	elsif params[:user_bet].to_i > session[:funds]
		@error = "You do not have enough funds for this. Try again"
		halt erb(:user_betting)
	else
		session[:user_bet] = params[:user_bet]
		redirect '/game'
	end
end

post '/play_again' do
	erb :user_betting
end

before do
	@show_hit_or_stay_buttons =true	
	@show_dealer_move_button = false

end

get '/game' do
	#building deck
	suit = ["hearts", "diamonds", "spades", "clubs"]
	face = ["2","3","4","5","6","7","8","9","10","J", "Q", "K", "A"]
	session[:deck] = suit.product(face).shuffle!
	
	
	session[:dealer_hand] = []
	session[:player_hand] = []
	
	#adding initial cards
	session[:dealer_hand] << session[:deck].pop
	session[:player_hand] << session[:deck].pop
	session[:dealer_hand] << session[:deck].pop
	session[:player_hand] << session[:deck].pop

	@show_cover_card = true
	erb :game
end

post '/game/player/hit' do
	session[:player_hand] << session[:deck].pop
	@show_cover_card = true
	erb :game
end

post '/game/player/stay' do
	@show_hit_or_stay_buttons = false
	@info = "You decided to stay at #{score(session[:player_hand], session[:user_name])}" 
	@show_dealer_move_button = true
	@show_cover_card = false
	erb :game
end

post '/game/dealer/move' do
	if score(session[:dealer_hand], "Dealer") < 17
		session[:dealer_hand] << session[:deck].pop
		@show_dealer_move_button = true
		erb :game, layout: false
	else
		@show_dealer_move_button = false
		erb :game
	end
end

post '/game/winner_declare' do
	if score(session[:dealer_hand], "Dealer") > score(session[:player_hand], session[:user_name])
		session[:funds] -= session[:user_bet].to_i
		@error = "Sorry the Dealer beat you. You lost #{session[:user_bet]}"
	elsif score(session[:dealer_hand], "Dealer") < score(session[:player_hand], session[:user_name])
		session[:funds] += session[:user_bet].to_i
		@success = "Congrats you have won #{session[:user_bet]}."
	else
		@info = "It's a push, try again"
	end
	erb :game
end


				

helpers do 
	def score(cards, user_name)
		#calculating the score
		score = 0
		face_values = cards.map{|suit, value| value}

		face_values.each do |card|
			if card == "A" 
				score +=11
			else 
				score += (card.to_i == 0 ? 10 : card.to_i)
			end
		end

		face_values.select{|val| val =="A"}.count.times do
			break if score <= 21
			score  -=10
		end

		if score > 21 && user_name == session[:user_name]
			@error = "Sorry you busted. You lost #{session[:user_bet]}"
			@show_hit_or_stay_buttons = false
			session[:funds] -= session[:user_bet].to_i
		elsif score > 21 && user_name == "Dealer"
			@success = "Dealer busted!.  Congrats you have won #{session[:user_bet]}."
			session[:funds] += session[:user_bet].to_i
		end

		score
	end

	def card_image(card)
	
		value = card[1]

		if ['J', 'Q', 'K', 'A'].include?(value)
			value = case card[1]
				when 'J' then 'jack'
				when 'Q' then 'queen'
				when 'K' then 'king'
				when 'A' then 'ace'
			end
		end

		"<img src = '/images/cards/#{card[0]}_#{value}.jpg' class = 'card_image'>"
	end
end

