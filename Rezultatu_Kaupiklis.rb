def kaupiklis
  loop do
    # Priemą žinutę iš skirstytuvo
    message = Ractor.receive
    break if message == :done
    puts "kaupiklis received:"
    puts "Name: #{message.name}"
    puts "Hours: #{message.hours}"
    puts "Hourly: #{message.hourly}"
  end
end