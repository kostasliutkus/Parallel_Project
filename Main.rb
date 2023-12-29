require_relative 'Read'
require_relative 'Spausdintojas'
require_relative 'Skirstytuvas'
require_relative 'Rezultatu_Kaupiklis'
require_relative 'Darbininkas'

main_ractor = Ractor.new do

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

  # Darbininkų aktorių kiekis
  worker_count = 5

  # Darbininkų aktorių kūrimas ir paleidimas
  darbininkas_ractors = (1..worker_count).map do |number|
    Ractor.new(number) do | n|
      darbininkas(n)
    end
  end

  # Skirstytuvo aktoriaus sukūrimas
  skirstytuvas_ractor = Ractor.new(darbininkas_ractors,kaupiklis_ractor) do |arg1,arg2|
    skirstytuvas(arg1,arg2)
  end

  # Siunčiami po vieną darbuotoją į skirstytuvą
  darbuotojai.each { |message| skirstytuvas_ractor.send({type: :data, data: message}) }

  # Pabaigos žinutė, jog darbą galima baigti siunčiama skirstytuvui
  # skirstytuvas_ractor.send({type: :done})

  # Laukiama kol pabaigs darbą aktoriai

  kaupiklis_ractor.take
  darbininkas_ractors.each(&:take)
  skirstytuvas_ractor.take

  # print_darbuotojai(darbuotojai,result_file_path)
end
# Laukiama main aktoriaus pabaigos
main_ractor.take