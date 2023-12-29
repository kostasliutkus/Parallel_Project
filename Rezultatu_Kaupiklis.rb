require_relative 'Spausdintojas'
def add_and_sort(results, item)
  index = 0
  while index < results.length && item.hourly <= results[index].hourly
    index += 1
  end
  results.insert(index, item)
end

def kaupiklis
  results=[]
  loop do
    # Priemą žinutę iš skirstytuvo
    message = Ractor.receive
    case message[:type]
    when :result
      data = message[:result]
      puts "kaupiklis received:"
      puts "Name: #{data.name}"
      puts "Hours: #{data.hours}"
      puts "Hourly: #{data.hourly}"
      add_and_sort(results,data)
      # print_darbuotojai(results,'testrez.txt')
    when :done
      puts "Received Done Kaupiklis"
      return results
    end

  end
end