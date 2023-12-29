def skirstytuvas(darbininkas_ractors,kaupiklis_ractor,data_count,spausdintojas_ractor,zurnalas_ractor)
  #indeksas paskirstymui
  index=0
  # skaičiavimas pabaigai
  end_count=0
  # Pradinis nusiuntimas skirstytuvo nuorodos visiem aktualiems aktoriams
  darbininkas_ractors.each { |ractor| ractor.send(Ractor.current) }
  kaupiklis_ractor.send(Ractor.current)
  spausdintojas_ractor.send(Ractor.current)

  loop do
    message = Ractor.receive
    ## ČIA GAUNAM 39 DUOM
    if end_count == data_count-1
      index=0
      # Siunčią pabaigos žinutę darbininkams
      darbininkas_ractors.each do |ractor|
        ractor.send({type: :done})

        # veiksmas įrašomas žurnale
        log = "Skirstytuvas -> Darbininkas #{index+1} | Pabaigos pranešimas"
        zurnalas_ractor.send({type: :log, log: log})
        index+=1
      end
    end

    case message[:type]
      when :data
        data = message[:data]
        # veiksmas įrašomas žurnale
        log = "Skirstytuvas <- Main | #{data}"
        zurnalas_ractor.send({type: :log, log: log})

        # Dalis paskirstymo algoritmo, iš naujo nustatomas indeksas,
        # kuomet išsiųsta po vieną žinutę kiekvienam darbininkui
        if index == darbininkas_ractors.length
          index=0
        end
        # Siunčia duomenis darbininkams
        darbininkas_ractors[index].send({type: :data, data: data})

        # veiksmas įrašomas žurnale
        log = "Skirstytuvas -> Darbininkas #{index+1} | #{data}"
        zurnalas_ractor.send({type: :log, log: log})

        index+=1
        end_count+=1

      when :results
        # duomenys gauti iš rezultatų kaupiklio
        data=message[:results]

        # Veiksmas įrašomas žurnale
        log = "Skirstytuvas <- Rezultatu kaupiklis | #{data} "
        zurnalas_ractor.send({type: :log, log: log})

        # duomenys persiunčiami spausdintojui
        spausdintojas_ractor.send(data)

        # Veiksmas įrašomas žurnale
        log = "Skirstytuvas -> Spausdintojas | #{data} "
        zurnalas_ractor.send({type: :log, log: log})

      when :results_printed
        # Veiksmas įrašomas žurnale
        log = "Skirstytuvas <- Spausdintojas | Duomenys sėkmingai atspausdinti galima baigti darbą "
        zurnalas_ractor.send({type: :last_log, last_log: log})
        return
      when :processed
        # Žinutė
        proc = message[:processed]

        # darbininko numeris
        worker_number = message[:sender]

        # Veiksmas įrašomas žurnale
        log = "Skirstytuvas <- Darbininkas #{worker_number} | #{proc} "
        zurnalas_ractor.send({type: :log, log: log})

        #Rezultatų kaupikliui siunčiamas atfiltruotas įrašas
        kaupiklis_ractor.send({type: :result, result: proc})

        # Veiksmas įrašomas žurnale
        log = "Skirstytuvas -> Rezultatų kaupiklis | #{proc} "
        zurnalas_ractor.send({type: :log, log: log})
      when :done
        data=message[:done]
        # Veiksmas įrašomas žurnale
        log = "Skirstytuvas <- Main | Pabaigimo žinutė #{data} "
        zurnalas_ractor.send({type: :log, log: log})

        # Siunčią duomenų prašymo žinutę kaupikliui
        kaupiklis_ractor.send({type: :request})

        log = "Skirstytuvas -> Rezultatų kaupiklis | Rikiuotu duomenų prašymas #{data} "
        zurnalas_ractor.send({type: :log, log: log})

    end
  end
end