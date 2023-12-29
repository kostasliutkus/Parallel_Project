def skirstytuvas(darbininkas_ractors,kaupiklis_ractor,data_count,spausdintojas_ractor)
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
      puts " end - #{end_count}"
      puts " data - #{data_count}"
      # Siunčią pabaigos žinutę darbininkams
      darbininkas_ractors.each do |ractor|
        ractor.send({type: :done})
      end
    end

    case message[:type]
      when :data
        if index == darbininkas_ractors.length
          index=0
        end
        # Siunčia duomenis darbininkams
        puts "Skirstytuvas siunčia darbininkui"
        data = message[:data]
        darbininkas_ractors[index].send({type: :data, data: data})
        index+=1
        end_count+=1

      when :results
        data=message[:results]
        puts "skirstytuvas gavo filtruotus duomenis"
        spausdintojas_ractor.send(data)

      when :results_printed
        return
      when :processed
        proc = message[:processed]
        kaupiklis_ractor.send({type: :result, result: proc})
      when :done
        # Siunčią duomenų prašymo žinutę kaupikliui
        kaupiklis_ractor.send({type: :request})
    end
  end
end