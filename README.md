# Scheduler
The scheduler has been ported twice, first from Java to Scala, and then through
a rewrite from scratch to Ruby. The following is the primary logic for the
block adjustment:

```ruby
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
```

The site is served using sinatra like so:

```ruby
get '/' do
  File.read('index.html')
end
```

With a single API endpoint for querying schedule adjustments defined as follows.

```ruby
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
```

The primary logic for the rendering of a given schedule is then the following.

```ruby
def render_periods(ps, start)
  start = start.to_i
  stamps = ps.map(&:length).reduce([[0,0]]) {|a,x|
    a.concat([[a.last[0] + a.last[1], x]])
  }.select {|x|
    x[1] != 5
  }[1..-1].map {|x| 
    Time.at(x.first*60 + start).strftime("%H:%M:%S") + " - " + Time.at((x.first + x.last)*60 + start).strftime("%H:%M:%S")
  }.join "<br>"
end
```

The `Block` class is trivially defined:

```ruby
class Block
  attr_accessor :length, :flexible
  def initialize(length, flexible)
    @length = length
    @flexible = flexible
  end
end
```
