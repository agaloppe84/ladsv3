class Breadcrumb
  attr_reader :name, :path, :count

  def initialize(name, path, count)
    @name = name
    @path = path
    @count = count
  end

  def link?
    @path.present?
  end

  def count?
    @count.present?
  end

end
