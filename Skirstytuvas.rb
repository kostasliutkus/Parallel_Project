def skirstytuvas(darbininkas_ractors,kaupiklis_ractor,data_count,spausdintojas_ractor,zurnalas_ractor)
  #indeksas paskirstymui
  index=0
  # skaičiavimas pabaigai
  sent_to_worker=0
  # Pradinis nusiuntimas skirstytuvo nuorodos visiem aktualiems aktoriams
  darbininkas_ractors.each { |ractor| ractor.send(Ractor.current) }
  kaupiklis_ractor.send(Ractor.current)
  spausdintojas_ractor.send(Ractor.current)
  # Duomenų buferis
  data_queue = Queue.new
  loop do
    message = Ractor.receive
    case message[:type]
      when :data
        index,sent_to_worker = handle_worker_data(message,darbininkas_ractors,zurnalas_ractor,index,sent_to_worker,data_count)
    when :results
        # duomenys gauti iš rezultatų kaupiklio
        data=message[:results]

        # Veiksmas įrašomas žurnale
        log_action(zurnalas_ractor,log = "Skirstytuvas <- Rezultatu kaupiklis | #{data} ")

        # duomenys persiunčiami spausdintojui
        spausdintojas_ractor.send(data)

        # Veiksmas įrašomas žurnale
        log_action(zurnalas_ractor,"Skirstytuvas -> Spausdintojas | #{data} ")


    when :results_printed
        # Veiksmas įrašomas žurnale
        log_last_action(zurnalas_ractor,"Skirstytuvas <- Spausdintojas | Duomenys sėkmingai atspausdinti galima baigti darbą ")
        return
      when :processed
        # Žinutė
        proc = message[:processed]
        # darbininko numeris
        worker_number = message[:sender]

        # Veiksmas įrašomas žurnale
        log_action(zurnalas_ractor,"Skirstytuvas <- Darbininkas #{worker_number} | #{proc} ")

        #Rezultatų kaupikliui siunčiamas atfiltruotas įrašas
        kaupiklis_ractor.send({type: :result, result: proc})

        # Veiksmas įrašomas žurnale
        log_action(zurnalas_ractor,"Skirstytuvas -> Rezultatų kaupiklis | #{proc} ")
      when :done
        data=message[:done]

        log_action(zurnalas_ractor,"Skirstytuvas <- Main | Pabaigimo žinutė #{data} ")

        # Siunčią duomenų prašymo žinutę kaupikliui
        kaupiklis_ractor.send({type: :request})

        log_action(zurnalas_ractor,"Skirstytuvas -> Rezultatų kaupiklis | Rikiuotu duomenų prašymas #{data} ")
    end
  end
end
def handle_worker_data(message,darbininkas_ractors,zurnalas_ractor,index,sent_to_worker,data_count)
  data = message[:data]
  # veiksmas įrašomas žurnale
  log_action(zurnalas_ractor,"Skirstytuvas <- Main | #{data}")

  # Siunčia duomenis darbininkams
  darbininkas_ractors[index].send({type: :data, data: data})

  # veiksmas įrašomas žurnale
  log_action(zurnalas_ractor,"Skirstytuvas -> Darbininkas #{index+1} | #{data}")

  # kol indeksas mažesnis už darbininkų kiekį indeksas didinamas, kai tampa lygus nustatomas į nulį
  index = (index + 1) % darbininkas_ractors.length
  sent_to_worker+=1

  if sent_to_worker == data_count
    send_done_signals_to_workers(darbininkas_ractors,zurnalas_ractor)
  end
  [index, sent_to_worker]
end
def send_done_signals_to_workers(darbininkas_ractors, zurnalas_ractor)
  worker_index=0

  # Siunčią pabaigos žinutę darbininkams
  darbininkas_ractors.each do |ractor|

    ractor.send({type: :done})

    # veiksmas įrašomas žurnale
    log_action(zurnalas_ractor,"Skirstytuvas -> Darbininkas #{worker_index+1} | Pabaigos pranešimas")

    worker_index+=1
  end
end

def log_last_action(zurnalas_ractor,log)
  zurnalas_ractor.send({type: :last_log, log: log})
end
def log_action(zurnalas_ractor,log)
  zurnalas_ractor.send({type: :log, log: log})
end