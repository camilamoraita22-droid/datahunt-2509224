# =====================================================================
# src\rutas\arco.ps1 - Atención de solicitudes ARCO (Acceso y Eliminación)
# =====================================================================

function Formulario-Arco([string]$mensaje = "") {
    $html = ""
    if ($mensaje) { $html += "<p class='mensaje'>$(Escapar $mensaje)</p>" }

    $html += "<form method='post' action='/arco'>"
    $html += "<label>Correo electrónico registrado <input type='email' name='email' required></label>"
    $html += "<label>Contraseña de tu cuenta <input type='password' name='password' required></label>"
    $html += "<label>Acción ARCO <select name='accion' required>"
    $html += "<option value='acceso'>Acceso (consultar mis datos registrados)</option>"
    $html += "<option value='eliminar'>Cancelación / Eliminación (borrar mi cuenta y datos)</option>"
    $html += "</select></label>"
    $html += "<button>Enviar solicitud ARCO</button></form>"
    return $html
}

$Rutas["/arco"] = {
    param($ctx)

    if ($ctx.Request.HttpMethod -ne "POST") {
        Enviar $ctx (Nueva-Pagina "Derechos ARCO" (Formulario-Arco))
        return
    }

    $form     = Leer-Formulario $ctx
    $email    = $form["email"]
    $password = $form["password"]
    $accion   = $form["accion"]

    $todos = @(Leer-Csv $ArchivoUsuarios)
    $coincide = $todos | Where-Object {
        $_.email -eq $email -and (Verificar-Password $password $_.password)
    }

    if (-not $coincide) {
        Registrar-Acceso $ctx $email "arco_$accion" $false
        Enviar $ctx (Nueva-Pagina "Derechos ARCO" (Formulario-Arco "No se pudo validar tu identidad con ese correo y contraseña.")) 401
        return
    }

    Registrar-Acceso $ctx $email "arco_$accion" $true

    if ($accion -eq "acceso") {
        $datosSinHash = $coincide | Select-Object * -ExcludeProperty password
        $html = "<p>Datos registrados para <strong>$(Escapar $email)</strong> (se excluye el hash de contraseña):</p>" + (Tabla-Html $datosSinHash)
        Enviar $ctx (Nueva-Pagina "Consulta ARCO (Acceso)" $html)
        return
    }

    if ($accion -eq "eliminar") {
        $restantes = @($todos | Where-Object { $_.email -ne $email })
        Guardar-CsvCifrado $ArchivoUsuarios $restantes
        Enviar $ctx (Nueva-Pagina "Eliminación ARCO completada" "<p>Tu cuenta y datos de registro asociados a <strong>$(Escapar $email)</strong> han sido eliminados del almacenamiento cifrado.</p>")
        return
    }

    Enviar $ctx (Nueva-Pagina "Derechos ARCO" (Formulario-Arco "Acción ARCO no reconocida.")) 400
}