require 'csv'
require 'sinatra'
require 'json'
ARCHIVO = 'libros.csv'

class GestorLibros
  attr_accessor :libros

    def initialize(data)
      @libros = data
    end
  
    def write_data_to_csv()      
      CSV.open(ARCHIVO, 'w') do |csv|
          csv << ["titulo", "autor", "edicion", "disponibilidad"]
          libros.each {|row| csv << row.values}
        end
    end
  
    def read_data_from_csv
      data = []
      CSV.foreach(ARCHIVO, headers: true) do |row|
        data << row.to_h
      end
      @libros = data
      end
end
# Habilitar CORS para todas las libros

gestor = GestorLibros.new([])
  
  get '/api/libros' do
    content_type :json
    gestor.read_data_from_csv
    gestor.libros.to_json
end
  
post '/api/libros' do
    request_body = JSON.parse(request.body.read)
    gestor.read_data_from_csv
    gestor.libros << request_body
    gestor.write_data_to_csv()
    status 201
    request_body.to_json
end

put '/api/libros/:titulo' do
  nombreRuta = params['titulo']
  request_body = JSON.parse(request.body.read)
  gestor.read_data_from_csv
  gestor.libros.each_with_index do |ruta, index|
    if ruta['titulo'] == nombreRuta
      gestor.libros[index] = request_body
    end
  end
  gestor.write_data_to_csv()
  status 200
  {"UPDATED" => nombreRuta}.to_json
end

delete '/api/libros/:titulo' do
    nombreRuta = params['titulo']
    gestor.read_data_from_csv
    gestor.libros.each_with_index do |ruta, index|
      if ruta['titulo'] == nombreRuta
        gestor.libros.delete_at(index)
      end
    end
    gestor.write_data_to_csv()
    status 200
    {"DELETED" => nombreRuta}.to_json
end