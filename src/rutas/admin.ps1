# =====================================================================
# src\rutas\admin.ps1 - Página de administración protegida (H-02 corregido)
# =====================================================================

$ClaveAdmin = if ($env:DATAHUNT_ADMIN_KEY) { $env:DATAHUNT_ADMIN_KEY } else { "AdminMida2026!" }

function Formulario-Admin([string]$mensaje = "") {
    $html = ""
    if ($mensaje) { $html += "<p class='mensaje'>$(Escapar $mensaje)</p>" }
    $html += "<form method='post' action='/admin'>"
    $html += "<label>Clave de administración <input type='password' name='clave_admin' required></label>"
    $html += "<button>Ingresar a administración</button></form>"
    return $html
}

$Rutas["/admin"] = {
    param($ctx)

    $autorizado = $false

    if ($ctx.Request.HttpMethod -eq "POST") {
        $form = Leer-Formulario $ctx
        if ($form["clave_admin"] -eq $ClaveAdmin) {
            $autorizado = $true
        }
        else {
            Registrar-Acceso $ctx "admin" "admin_login" $false
            Enviar $ctx (Nueva-Pagina "Administración" (Formulario-Admin "Clave de administración incorrecta.")) 401
            return
        }
    }
    elseif ($ctx.Request.Headers["X-Admin-Key"] -eq $ClaveAdmin) {
        $autorizado = $true
    }

    if (-not $autorizado) {
        Enviar $ctx (Nueva-Pagina "Administración" (Formulario-Admin)) 401
        return
    }

    Registrar-Acceso $ctx "admin" "admin_panel" $true

    $usuariosSinHash = @(Leer-Csv $ArchivoUsuarios) | Select-Object * -ExcludeProperty password
    $accesos         = @(Leer-Csv $ArchivoAccesos)
    [array]::Reverse($accesos)

    $contenido  = "<p><a href='/arco'>Ir al portal de derechos ARCO</a></p>"
    $contenido += "<h2>Clientes ($($usuariosSinHash.Count))</h2>" + (Tabla-Html $usuariosSinHash)
    $contenido += "<h2>Bitácora de accesos</h2>" + (Tabla-Html $accesos)
    Enviar $ctx (Nueva-Pagina "Administración" $contenido)
}