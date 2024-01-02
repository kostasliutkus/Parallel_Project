require_relative 'Spausdintojas'
require_relative 'Darbuotojas'
def generate_random(batch_size)
  max_integer = 2**62 - 1
  integer_range = 1..max_integer
  batch_size.times do
    rand(integer_range)
  end
end

def cpu_intense_function

  batch_size = 25000

  (500000 /25000).times do
    generate_random(batch_size)
  end
end

# tikrinimas kriterijaus
def check_criteria(hours,hourly)
  cpu_intense_function
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
  if check_criteria(data.hours, data.hourly)
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