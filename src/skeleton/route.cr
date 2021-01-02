# Description
module Genuary00 # Change this to the day number!
  # Constants go here
end

# Change this to the day number!
get "/00" do |env|
  env.redirect "/00/0" # Change this to the day number!
end

# Change this to the day number!
get "/00/:seed" do |env|
  integer_seed = 0
  begin
    integer_seed = (env.params.url["seed"].to_i % Int32::MAX).to_i32
  rescue
    integer_seed = ((env.params.url["seed"].hash.to_i128 &- Int64::MAX) % Int32::MAX).to_i32
  end

  svg = Celestine.draw do |ctx|
    # Celestine code goes here
  end

  render_layout("view")
end
