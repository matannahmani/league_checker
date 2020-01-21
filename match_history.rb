  # Time.at(1576756797323 / 1000) formula
require 'json'
require 'open-uri'
require 'date'
require "pry-byebug"
require "sinatra"
require "sinatra/reloader" if development?
require "better_errors"
configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

API_KEY = "RGAPI-03733fa1-c979-414d-a23a-ba454228f153"
API_SUMMONERID = "https://eun1.api.riotgames.com/lol/summoner/v4/summoners/by-name/"
API_MATCH_HISTORY = "https://eun1.api.riotgames.com/lol/match/v4/matchlists/by-account/"
API_MATCH_STATS = "https://eun1.api.riotgames.com/lol/match/v4/matches/"
#https://eun1.api.riotgames.com/lol/summoner/v4/summoners/by-name/vergo?api_key=RGAPI-b9f6f97e-3e38-4dc2-95b0-98279bae5b8c

get '/result' do
  erb :result
end

get '/search' do
  erb :search
end

post '/search' do
  summoner_name = params[:summoner_name]
  start_date = Time.parse(params[:start_date])
  end_date = Time.parse(params[:end_date])
  @results = get_match_history(get_userid(URI.escape(summoner_name)), start_date, end_date)
  erb :result
end


def match_stats(matches_hash, start_date, end_date,summoner_id,total_matches) # TO-DO calculate game time for each match | optional calculate death and minions
  stats = [0,0,0,0,0,0,0,0]
  matches_hash.each do |item|
    hash = open_url("#{API_MATCH_STATS}#{item['gameId']}?api_key=#{API_KEY}")
    my_new = hash['participantIdentities'].select { |item| item['player']['accountId'] == summoner_id }
      id = my_new[0]['participantId']
      #binding.pry
     stats[6] += hash['participants'][id-1]['stats']['kills']
     stats[5] += hash['participants'][id-1]['stats']['deaths']
     stats[4] += hash['participants'][id-1]['stats']['assists']
     stats[3] += hash['participants'][id-1]['stats']['deaths']
     hash['participants'][id-1]['stats']['win'] ? stats[2] += 1 : stats[7] += 1
     stats[1] += hash['participants'][id-1]['stats']['totalMinionsKilled']
   # binding.pry
    stats[0] += hash['gameDuration']
  end
  "You wasted : #{(stats[0] / 60.0 / 60).round} hours \n from #{start_date} till #{end_date} \n
  total matches : #{total_matches} \n
  kda : #{(stats[6]+stats[4])/stats[5]} \n
  kills : #{stats[6]} || deaths : #{stats[5]} || assists : #{stats[4]} \n
  wins : #{stats[2]} || losses : #{stats[7]} || winrate : #{(stats[2].to_f / total_matches) * 100.0} \n
  Minions killed : #{stats[1]}"
end


def get_userid(summoner_name) # gets user id
  user = open_url("#{API_SUMMONERID}#{summoner_name}?api_key=#{API_KEY}")
  user['accountId']
end
# 1601499600 1576712152490
def get_match_history(id,start_date,end_date) # gets match history array
  match_history = open_url("#{API_MATCH_HISTORY}#{id}?api_key=#{API_KEY}")
  match_history = match_history['matches']
  filtered = match_history.filter do |item|
    time = Time.at(item['timestamp'] / 1000)
    time.between?(start_date, end_date)
  end
  match_stats(filtered, start_date, end_date,id,filtered.count)
end

def open_url(url) # opens url
  user_serialized = open(url).read
  JSON.parse(user_serialized)
end
