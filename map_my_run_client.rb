#!/usr/bin/env ruby

require 'typhoeus'
require 'json'

# Given my reported distance from the site, find my exact current position.
# Or, given a future estimate, find where that would roughly place me.
class MapMyRunClient
  def initialize
    @base_url = 'http://www.mapmyrun.com/leaderboard/challenge_ajEePE5X5L_overall/page/'
    @per_page = '/?per_page=50'
    @search_distance = 500
  end

  def find_by_distance(args)
    distance = args[0].to_f
    future = true if args.length > 1
    found  = false
    offset = 1
    num_checks = 0

    while found == false
      res = get_result(offset.to_s)
      min, max = get_range(res)
      puts "#{offset}: #{min} - #{max} [#{@search_distance}]"
      #print '.'
      if min < distance
        break if max > distance
        offset -= @search_distance
        @search_distance /= 2
        @search_distance = 1 if @search_distance == 0
      end

      offset += @search_distance
      sleep 0.1
      num_checks += 1
    end
    puts
    # puts "#{offset} / #{num_checks}"
    puts "#{num_checks} requests"

    find_me(offset.to_s, future)
  end

  def get_range(res)
    max = res['page'][0]['scores']['distance']['value'].to_f
    min = res['page'][-1]['scores']['distance']['value'].to_f
    return min, max
  end

  def get_match(res, distance, offset)
    max = res['page'][0]['scores']['distance']['value'].to_f
    min = res['page'][-1]['scores']['distance']['value'].to_f
    puts "#{offset}: #{min} / #{max}"
    if distance <= max && distance >= min
      puts 'Yay, match'
      return true
    end

    false
  end

  def get_max(res)
    person = res['page'].first
    person['scores']['distance']['value'].to_f
  end

  def find_me(offset, future)
    found = false

    while found == false
      res = get_result(offset)
      found = check(res)
      offset = (offset.to_i + 1).to_s
      break if future
      sleep 0.1
    end
  end

  def get_result(offset)
    url = @base_url + offset + @per_page
puts url
    response = Typhoeus.get(url, timeout: 5, connecttimeout: 5)
    unless response.code == 200
      puts 'Bah, exiting'
      exit
    end

    response = JSON.parse(response.body)
    response['result']
  end

  def check(res)
    status = false
    res['page'].each do |person|
      if person['display_name'] == 'Warren Pearson'
        status = true
        break
      end
    end
    display(res)
    status
  end

  def display(res)
    total_count = "Total count: #{res['count']}"
    puts total_count

    res['page'].each do |person|
      me = ''
      me = '<<<<<' if person['display_name'] == 'Warren Pearson'
      distance = person['scores']['distance']['value']
      distance = distance.to_f.round(2)
      workouts = person['scores']['workouts']['value']
      wks = workouts == 1 ? 'workout' : 'workouts'
      puts "#{person['rank']}. #{person['display_name']}: #{workouts} #{wks}, #{distance}km #{me}"
      break unless me == ''
    end
  end
end

MapMyRunClient.new.find_by_distance(ARGV)
