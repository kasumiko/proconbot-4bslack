class Hello
  def answer(*query)
    return {as_user: true, channel: ENV['CHANNEL'], text: 'こん'} if query[1] =~ /こん/
  end
end
