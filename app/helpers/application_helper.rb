module ApplicationHelper
  def category_color(color)
    if color == 'green'
      'rgba(127,169,150,1)'
    elsif color == 'green-blue'
      'rgba(133,184,139,1)'
    elsif color == 'blue'
      'rgba(121,167,207,1)'
    elsif color == 'pink'
      'rgba(209,163,164,1)'
    elsif color == 'red'
      'rgba(220,81,73,1)'
    elsif color == 'purple'
      'rgba(181,113,143,1)'
    elsif color == 'yellow'
      'rgba(229,200,0,1)'
    elsif color == 'brown'
      'rgba(160,82,45,1)'
    end
  end
end
