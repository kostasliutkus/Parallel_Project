def kaupiklis
  loop do
    # Priemą žinutę iš skirstytuvo
    message = Ractor.receive
    case message[:type]
    when :done
      break
    when :result
      data = message[:result]
      puts "kaupiklis received:"
      puts "Name: #{data.name}"
      puts "Hours: #{data.hours}"
      puts "Hourly: #{data.hourly}"
    end
  end
end