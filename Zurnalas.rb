def get_current_time_formatted
  current_time =Time.now
  formatted_time=current_time.strftime("%Y-%m-%d %H:%M:%S")
end
def zurnalas(file_path)
  File.open(file_path,'w') do |file|
    loop do
      message=Ractor.receive
      if message[:type] == :last_log
        log = message[:last_log]
        formatted_time=get_current_time_formatted
        file.puts "[#{formatted_time}] #{log}"
        return
      end
      log = message[:log]
      formatted_time=get_current_time_formatted
      file.puts "[#{formatted_time}] #{log}"
    end

  end

end