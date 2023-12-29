require_relative 'Read'
require_relative 'Spausdintojas'
require_relative 'Skirstytuvas'
require_relative 'Rezultatu_Kaupiklis'
require_relative 'Darbininkas'
require_relative 'Stopwatch'
main_ractor = Ractor.new do

  stopwatch = Stopwatch.new

  # Start the stopwatch
  stopwatch.start


  # Kelias iki duomenų failo
  # file_path = 'data/IF-11_LiutkusK_L1_dat_2.json'
  # file_path = 'data/IF-11_LiutkusK_L1_dat_3.json'
  file_path = 'data/IF-11_LiutkusK_L1_dat_1.json'

  # Kelias iki rezultatų failo
  result_file_path = 'rez.txt'

  # skaitymas duomenų
  darbuotojai = read_darbuotojai(file_path)

  # Rezultatų Kaupiklio aktoriaus sukūrimas
  kaupiklis_ractor = Ractor.new{kaupiklis}
  # Spausdintojo aktoriaus sukūrimas
  spausdintojas_ractor = Ractor.new{print_darbuotojai('rez.txt')}
  # Darbininkų aktorių kiekis
  worker_count = 1

  # Darbininkų aktorių kūrimas ir paleidimas
  darbininkas_ractors = (1..worker_count).map do |number|
    Ractor.new(number) do | n|
      darbininkas(n)
    end
  end
  # Skirstytuvo aktoriaus sukūrimas
  skirstytuvas_ractor = Ractor.new(darbininkas_ractors,kaupiklis_ractor,darbuotojai.length,spausdintojas_ractor) do |arg1,arg2,arg3,arg4|
    skirstytuvas(arg1,arg2,arg3,arg4)
  end

  # Siunčiami po vieną darbuotoją į skirstytuvą
  darbuotojai.each { |message| skirstytuvas_ractor.send({type: :data, data: message}) }


  # Laukiama kol pabaigs darbą darbininkai
  darbininkas_ractors.each(&:take)

  # Pabaigos žinutė, jog darbą galima baigti siunčiama skirstytuvui
  skirstytuvas_ractor.send({type: :done})

  # Laukiama kol pabaigs darbą likę aktoriai
  kaupiklis_ractor.take
  skirstytuvas_ractor.take

  # print_darbuotojai(darbuotojai,result_file_path)
  stopwatch.stop
end
# Laukiama main aktoriaus pabaigos
main_ractor.take