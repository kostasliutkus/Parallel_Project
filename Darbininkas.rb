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
    message = Ractor.receive
    case message[:type]
    when :data
      data = message[:data]
      # jei tenkina kriterijus siunčiama, kaip processed
      if check_criteria(data.hours, data.hourly)
        skirstytuvas_ractor.send({ type: :processed, processed: data ,sender: number})
      else
        skirstytuvas_ractor.send({type: :empty})
      end
    when :done
      # Darbininkas gavo pabaigos pranešimą
      return
    end
  end
end