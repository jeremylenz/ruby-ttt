require 'pry'
class Foo

  attr_accessor :rows

  def initialize(ary)
    @rows = Array.new(ary)
  end

  def spawn
    new_rows = Array.new(@rows)
    new_foo = Foo.new(new_rows)
    puts self.rows.inspect
    # new_foo.change
    puts new_foo.rows.inspect
    new_foo
  end

  # def change
  #   self.rows[0][0] = "J"
  # end


end

orig_foo = Foo.new [["X", "O", nil], ["X", "X", "O"], [nil, nil, "O"]]
new_foo = orig_foo.spawn

def compare(orig, newf)
  puts orig.rows.inspect
  puts newf.rows.inspect
end

binding.pry
