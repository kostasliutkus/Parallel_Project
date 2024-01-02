require_relative 'Spausdintojas'
require_relative 'Darbuotojas'
def cpu_intense_function(name)
  hashed = name.hash
  5000000.times do
    hashed=hashed.hash
  end
end
# tikrinimas
def check_criteria(hours,hourly,name)
  cpu_intense_function(name)
  hourly * 4 * hours > 400
end

def darbininkas(number)
  # gaunama nuoroda į skirstytuvą
  skirstytuvas_ractor = Ractor.receive
  loop do
    message = Ractor.receive
    case message[:type]
    when :data
      # Apdorojama gauta žinutė
      received_data(message,skirstytuvas_ractor,number)
    when :done
      # Darbininkas gavo pabaigos pranešimą
      return
    end
  end
end
def received_data(message,skirstytuvas_ractor,number)
  data = message[:data]
  # jei tenkina kriterijus siunčiama, kaip processed
  if check_criteria(data.hours, data.hourly,data.name)
    #skirstytuvas_ractor.send({ type: :processed, processed: data ,sender: number})
    send_to_skirstytuvas_match(skirstytuvas_ractor,data,number)
  else
    #skirstytuvas_ractor.send({type: :empty})
    send_to_skirstytuvas_no_match(skirstytuvas_ractor)
  end
end
def send_to_skirstytuvas_match(skirstytuvas_ractor,data,number)
  skirstytuvas_ractor.send({ type: :processed, processed: data ,sender: number})
end
def send_to_skirstytuvas_no_match(skirstytuvas_ractor)
  skirstytuvas_ractor.send({type: :empty})
end