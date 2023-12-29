class Stopwatch
  def initialize
    @start_time = nil
    @end_time = nil
  end

  def start
    @start_time = Time.now
    puts "Laikrodis pradėtas!"
  end

  def stop
    if @start_time
      @end_time = Time.now
      elapsed_time = @end_time - @start_time
      puts "Užtruko #{elapsed_time} sekundžių."
    else
      puts "Laikmatis nebuvo pradėtas"
    end
  end
end
