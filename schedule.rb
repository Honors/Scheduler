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
  [Block.new(7, false), b, n.clone, b, n.clone, b, n.clone, b, n.clone, a, b, l, b, n.clone, b, n.clone, a, b, n.clone]
end
def fit_upto(blocks, start, finish)
  min_range = (finish - start)/60
  fit(blocks, min_range)
end
def get_period(num)
  { 0 => 0, 1 => 2, 2 => 4, 3 => 6, 4 => 8, 5 => 11, 6 => 13, 7 => 15, 8 => 18 }[num]
end
def fit_periods(a, b, lunch, finish, start=Time.now)
  fit_upto(periods(lunch)[get_period(a)..get_period(b)], start, finish)
end
def render_periods(ps)
  start = Time.new(2013, 10, 23, 7, 55, 0).to_i
  stamps = ps.map(&:length).reduce([[0,0]]) {|a,x| a.concat([[a.last[0] + a.last[1], x]])}.select {|x|
    x[1] != 5
  }[1..-1].map {|x| 
    Time.at(x.first*60+start).strftime("%H:%M:%S") + " - " + Time.at((x.first+x.last)*60+start).strftime("%H:%M:%S")
  }
end

puts render_periods(fit_periods(0, 8, 77, Time.new(2013, 10, 23, 15, 13, 0), Time.new(2013, 10, 23, 7, 55, 0)))
