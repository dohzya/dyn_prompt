class Pathname
  def /(where)
    self + "#{where}"
  end
end
class Object
  def blank?
    empty?
  end
end
class NilClass
  def blank?
    true
  end
end
class String
  # ruby 1.8.6 compatibility
  unless instance_method(:each_line)
    alias :each :each_line
  end
end

