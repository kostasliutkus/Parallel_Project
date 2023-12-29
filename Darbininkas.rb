require_relative 'Spausdintojas'
require_relative 'Darbuotojas'

# tikrinimas kriterijaus
def check_criteria(hours,hourly)
  sleep(0.25)
  hourly * 4 * hours > 400
end

def darbininkas(number)
  # gaunama nuoroda į skirstytuvą
  skirstytuvas_ractor = Ractor.receive
  loop do
    # Priemą žinutę iš skirstytuvo
    message = Ractor.receive
    puts "Darbininkas - #{message[:type]}\n"
    case message[:type]
    when :data
      data = message[:data]
      # jei tenkina kriterijus siunčiama, kaip processed
      if check_criteria(data.hours, data.hourly)
        # printf("Darbininkas #{number} gavo #{data.name}\n")
        skirstytuvas_ractor.send({ type: :processed, processed: data })
      end
    when :done
      puts "Darbininkas #{number} gavo done"
      return
    end
  end
end