require 'open-uri'
require'json'

class GamesController < ApplicationController

  def generate_grid(grid_size)
  Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def new
    @letters = generate_grid(9)
  end

  def score
    @score = run_game(params[:word],params[:letters], Time.now, Time.now)
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "#{attempt.upcase }is not an english word"]
      end
    else
      [0, "#{attempt.upcase } is not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end
end
