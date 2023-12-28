class Darbuotojas
  # Automatiškai sukuria Getterius ir setterius
  attr_accessor :name, :hours, :hourly
  # Konstruktorius
  def initialize(name, hours, hourly)
    @name = name
    @hours = hours
    @hourly = hourly
  end
end