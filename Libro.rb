class Libro
    attr_accessor :titulo, :autor, :edicion, :disponibilidad
  
    def initialize(titulo, autor, edicion, disponibilidad)
      @titulo = titulo
      @autor = autor
      @edicion = edicion
      @disponibilidad = disponibilidad
    end
  end