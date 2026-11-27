# =====================================================================
# config.ps1 - Configuración de Data Hunt
# Adapta estos valores a la organización del caso de tu salón.
# =====================================================================

$Organizacion = "Aeropuerto Internacional de Mérida"
$Servicio     = "Registro de pasajeros"
$Departamento = "Atención a pasajeros"

$Direccion = "localhost"
$Puerto    = 5000

# --- Campos del formulario (Fase 3) ---------------------------------
# Copia aquí los campos de docs\campos.md. Cada campo DEBE tener finalidad.
# Tipo puede ser: text, email, tel, date o number.
# El correo y la contraseña ya están incluidos; no los repitas aquí.
$Campos = @(
    @{ Nombre = "nombre";           Etiqueta = "Nombre completo";     Tipo = "text"; Finalidad = "Identificar al pasajero en su reservación" }
    @{ Nombre = "telefono";         Etiqueta = "Teléfono celular";    Tipo = "tel";  Finalidad = "Avisar cambios de puerta, retrasos o cancelaciones" }
    @{ Nombre = "fecha_nacimiento"; Etiqueta = "Fecha de nacimiento"; Tipo = "date"; Finalidad = "Verificar si el pasajero es menor de edad" }
)
