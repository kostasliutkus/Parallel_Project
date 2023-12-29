require_relative 'Spausdintojas'
def add_and_sort(results, item)
  index = 0
  while index < results.length && item.hourly <= results[index].hourly
    index += 1
  end
  results.insert(index, item)
end
def kaupiklis
  #gaunama nuoroda į skirstytuvą
  skirstytuvas_ractor = Ractor.receive
  results=[]
  loop do
    # Priemą žinutę iš skirstytuvo
    message = Ractor.receive
    case message[:type]
    when :result
      data = message[:result]
      add_and_sort(results,data)
    when :request
      # Skirstytuvo rezultatų prašymo žinutė gauta, siunčiami rezultatai
      skirstytuvas_ractor.send({type: :results, results: results})
      return
    end
  end
end