require_relative 'Read'
require_relative 'Spausdintojas'
require_relative 'Skirstytuvas'
require_relative 'Rezultatu_Kaupiklis'
require_relative 'Darbininkas'
require_relative 'Stopwatch'
require_relative 'Zurnalas'
# su 6 darbininkais 1.857 sekundės naudojant sleep
# su 1 darbininku 10.22 sekundės naudojant sleep

# su 1 darbininku 10.23 sekundės
# su 6 darbininkais 12.68 sekundės
# main_ractor = Ractor.new do
  #laikmatis
  stopwatch = Stopwatch.new
  stopwatch.start


  # Kelias iki duomenų failo
  # file_path = 'data/IF-11_LiutkusK_EGZ_dat_2.json'
  #file_path = 'data/IF-11_LiutkusK_EGZ_dat_3.json'
  file_path = 'data/IF-11_LiutkusK_EGZ_dat_1.json'

  # skaitymas duomenų
  darbuotojai = read_darbuotojai(file_path)

  # Žurnalo aktoriaus paleidiams
  zurnalas_ractor =Ractor.new{zurnalas('Zurnalas.txt')}

  # Rezultatų Kaupiklio aktoriaus sukūrimas
  kaupiklis_ractor = Ractor.new{kaupiklis}

  # Spausdintojo aktoriaus sukūrimas
  spausdintojas_ractor = Ractor.new{print_darbuotojai('rez.txt')}

  # Darbininkų aktorių kiekis
  worker_count = 1

  # Darbininkų aktorių kūrimas ir paleidimas
  darbininkas_ractors = (1..worker_count).map do |number|
    Ractor.new(number) do | num|
      darbininkas(num)
    end
  end
  
  # Skirstytuvo aktoriaus sukūrimas
  skirstytuvas_ractor = Ractor.new(darbininkas_ractors,kaupiklis_ractor,darbuotojai.length,spausdintojas_ractor,zurnalas_ractor) do |dr,kr,dc,sr,zr|
    skirstytuvas(dr,kr,dc,sr,zr)
  end

  def send_data(data,skirstytuvas_ractor)
    # Send the data to the distributor via Ractor message
    skirstytuvas_ractor.send({ type: :data, data: data })
  end
  
  # Siunčiami po vieną darbuotoją į skirstytuvą
  darbuotojai.each { |message| skirstytuvas_ractor.send({type: :data, data: message}) }
  # darbuotojai.each_with_index do |message, index|
  #   send_data(message, skirstytuvas_ractor)
  # end

  # Laukiama kol pabaigs darbą darbininkai
  darbininkas_ractors.each(&:take)

  # Pabaigos žinutė, jog darbą galima baigti siunčiama skirstytuvui
  skirstytuvas_ractor.send({type: :done})

  # Laukiama kol pabaigs darbą likę aktoriai
  kaupiklis_ractor.take
  skirstytuvas_ractor.take
  zurnalas_ractor.take

  #laikmačio stabdymas
  stopwatch.stop
  
# end
# # Laukiama main aktoriaus pabaigos
# main_ractor.take
