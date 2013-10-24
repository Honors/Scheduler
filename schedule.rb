require 'rubygems'
require 'sinatra'

set :port, 3070

class Block
  attr_accessor :length, :flexible
  def initialize(length, flexible)
    @length = length
    @flexible = flexible
  end
end
def fit(blocks, time)
  fixed = blocks.reject(&:flexible).map(&:length).reduce(0) {|sum,x| sum + x }
  ratio = (time - fixed) / blocks.select(&:flexible).map(&:length).inject {|sum,x| sum + x }
  blocks.map do |block|
    if block.flexible
      block.length *= ratio      
      block
    else
      block
    end
  end
end
def periods(lunch)
  n = Block.new 42, true
  l = Block.new lunch, false
  b = Block.new 5, false
  a = Block.new 2, false  
  [Block.new(7, false), b, n.clone, b, n.clone, b, n.clone, b, n.clone, a, l, b, n.clone, b, n.clone, a, b, n.clone]
end
def fit_upto(blocks, start, finish)
  min_range = (finish - start)/60
  fit(blocks, min_range)
end
def get_period(num)
  { 0 => 0, 1 => 2, 2 => 4, 3 => 6, 4 => 8, 5 => 11, 6 => 13, 7 => 15, 8 => 18 }[num]
end
def fit_periods(a, b, lunch, finish, start=Time.now)
  slice = periods(lunch)[get_period(a)..get_period(b)]
  p slice.map(&:length)
  fit_upto(slice, start, finish)
end
def render_periods(ps, start)
  start = start.to_i
  max_length = ps.map(&:length).reduce(0) {|m,x| x>m ? x : m}
  time_format = "%H:%M:%S"
  stamps = ps.map(&:length).reduce([[0,0]]) {|a,x|
    a.concat([[a.last[0] + a.last[1], x]])
  }.select {|x|
    x[1] != 5
  }[1..-1].map {|x| 
    if x.last == max_length
      sub = max_length/3 * 60
      lstart = x.first*60 + start
      ends = [[lstart, sub], [lstart+sub, sub], [lstart+sub*2, sub]]      
      ["A " + Time.at(ends[0].first).strftime(time_format) + " - " + Time.at(ends[0].first+ends[0].last).strftime(time_format),
       "B " + Time.at(ends[1].first).strftime(time_format) + " - " + Time.at(ends[1].first+ends[1].last).strftime(time_format),
       "C " + Time.at(ends[2].first).strftime(time_format) + " - " + Time.at(ends[2].first+ends[2].last).strftime(time_format)].join('<br>')
    else
      Time.at(x.first*60 + start).strftime(time_format) + " - " + Time.at((x.first + x.last)*60 + start).strftime(time_format)
    end
  }.join "<br>"
end

get '/api/:start/:end/:from/:to/:lunch' do
  from = params[:from].split(":").map(&:to_i)
  to = params[:to].split(":").map(&:to_i)
  start = params[:start].to_i
  endd = params[:end].to_i
  lunch = params[:lunch].to_i
  startTime = Time.new(2013, 10, 23, from.first, from.last, 0)
  endTime = Time.new(2013, 10, 23, to.first, to.last, 0)
  render_periods(fit_periods(start, endd, lunch, endTime, startTime), startTime)
end

get '/' do
  File.read('index.html')
end
