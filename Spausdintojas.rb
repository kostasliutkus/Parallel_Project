def print_darbuotojai(file_path)
  skirstytuvas_ractor = Ractor.receive
  message = Ractor.receive
  darbuotojai=message
  File.open(file_path,'w') do |file|
    if darbuotojai.length < 1
      file.puts "Nėra darbuotojų tenkinančių sąlygą"
      break
    end
    # Antraštė
    header = "|Nr.  |\tName\t  |\tHours |\tHourly\t|\n"
    file.puts header

    # Indeksas numeracijai sąrašo
    index=1

    # Spausdinimas darbuotojų masyvo
    darbuotojai.each do |darbuotojas|
      file.printf("|%-5d|\t%-10s|\t%-6d|\t%7.2f |\n", index, darbuotojas.name, darbuotojas.hours, darbuotojas.hourly)
      index+=1
    end
  end
  skirstytuvas_ractor.send({type: :results_printed})
end

