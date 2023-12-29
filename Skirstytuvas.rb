def skirstytuvas(darbininkas_ractors,kaupiklis_ractor)
  #indeksas paskirstymui
  count=0
  # Pradinis nusiuntimas skirstytuvo nuorodos visiem darbininkam
  darbininkas_ractors.each { |ractor| ractor.send(Ractor.current) }
  loop do
    message = Ractor.receive
    case message[:type]
    when :data
      if count == darbininkas_ractors.length
            count=0
      end
      # Siunčia duomenis darbininkams
      puts "Skirstytuvas gavo iš main"
      data = message[:data]
      darbininkas_ractors[count].send({type: :data, data: data})
      count+=1
    when :result
    when :log
    when :processed
      proc = message[:processed]
      kaupiklis_ractor.send({type: :result, result: proc})
    when :done

      # Siunčią pabaigos žinutę darbininkams
      darbininkas_ractors.each do |ractor|
        ractor.send({type: :done})
        # Siunčią pabaigos žinutę kaupikliui
      kaupiklis_ractor.send({type: :done})
      end
    end
  end
end