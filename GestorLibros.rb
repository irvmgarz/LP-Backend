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

# En main.rb

# Ruta para buscar libros por título
get '/api/libros/buscar/titulo/:titulo' do
  titulo = params['titulo']
  gestor.read_data_from_csv
  resultados = gestor.libros.select { |libro| libro['titulo'].include?(titulo) }
  resultados.to_json
end

# Ruta para buscar libros por autor
get '/api/libros/buscar/autor/:autor' do
  autor = params['autor']
  gestor.read_data_from_csv
  resultados = gestor.libros.select { |libro| libro['autor'].include?(autor) }
  resultados.to_json
end

# Ruta para buscar libros por tema
get '/api/libros/buscar/tema/:tema' do
  tema = params['tema']
  gestor.read_data_from_csv
  resultados = gestor.libros.select { |libro| libro['tema'].include?(tema) }
  resultados.to_json
end

# Ruta para obtener reseñas de un libro
get '/api/libros/:titulo/reseñas' do
  titulo = params['titulo']
  gestor.read_data_from_csv
  libro = gestor.libros.find { |libro| libro['titulo'] == titulo }

  if libro
    libro['reseñas'].to_json
  else
    status 404
    {"error" => "Libro no encontrado"}.to_json
  end
end

# Ruta para agregar reseña a un libro
post '/api/libros/:titulo/reseñas' do
  titulo = params['titulo']
  gestor.read_data_from_csv
  libro = gestor.libros.find { |libro| libro['titulo'] == titulo }

  if libro
    request_body = JSON.parse(request.body.read)
    libro.agregar_reseña(request_body['reseña'])
    gestor.write_data_to_csv()
    status 201
    {"agregado" => "Reseña a #{titulo}"}.to_json
  else
    status 404
    {"error" => "Libro no encontrado"}.to_json
  end
end
