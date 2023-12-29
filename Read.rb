require 'json'
require_relative 'Darbuotojas'
def read_darbuotojai(file_path)
  # Sukūriamas masyvas duomenų saugojimui
  darbuotojai = []

  # Skaitymas iš failo
  begin
    data = File.read(file_path)
    json_data  = JSON.parse(data)

    # Einama per JSON objektą ir kuriami darbuotojas_to_add pridėjimui
    json_data.each do |darbuotojas_data|
      darbuotojas_to_add = Darbuotojas.new(
        darbuotojas_data['name'],
        darbuotojas_data['hours'],
        darbuotojas_data['hourly']
      )
      # Pridedami darbuotojai į masyvą
      darbuotojai << darbuotojas_to_add
    end
    # Klaidos
  rescue JSON::ParserError => e
    puts "Error parsing JSON: #{e.message}"
  rescue Errno::ENOENT => e
    puts "Error reading file: #{e.message}"
  end
  darbuotojai
end