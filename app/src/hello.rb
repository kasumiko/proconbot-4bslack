class Hello
  def answer(*query)
    return 'こん' if query[1] =~ /こん/
  end
end
