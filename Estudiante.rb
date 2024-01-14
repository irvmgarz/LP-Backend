class Estudiante
    attr_accessor :nombre, :correo, :nombre_usuario, :contrasena

    def initialize(nombre, correo, nombre_usuario, contrasena)
        @nombre = nombre
        @correo = correo
        @nombre_usuario = nombre_usuario
        @contrasena = contrasena
    end
    
end