require_relative 'Spausdintojas'
require_relative 'darbuotojas'

# tikrinimas kriterijaus
def CheckCriteria(hours,hourly)
  sleep(0.25)
  hourly * 4 * hours > 400
end

def darbininkas(number)
  skirstytuvas_ractor = Ractor.receive
  loop do
    # Priemą žinutę iš skirstytuvo
    message = Ractor.receive
    case message[:type]
    when :data
      data = message[:data]
      # jei tenkina kriterijus siunčiama, kaip processed
      if CheckCriteria(data.hours, data.hourly)
        printf("Darbininkas #{number} gavo #{data.name}\n")
        skirstytuvas_ractor.send({ type: :processed, processed: data })
      end
    when :done
      return
    end
  end
end