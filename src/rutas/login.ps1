# =====================================================================
# src\rutas\login.ps1 - Inicio de sesión y bitácora de accesos
# Corrección H-01 (verificación PBKDF2) y H-03 (sin debug en consola)
# =====================================================================

function Formulario-Login([string]$mensaje = "") {
    $html = ""
    if ($mensaje) { $html += "<p class='mensaje'>$(Escapar $mensaje)</p>" }
    $html += "<form method='post' action='/login'>"
    $html += "<label>Correo electrónico <input type='email' name='email' required></label>"
    $html += "<label>Contraseña <input type='password' name='password' required></label>"
    $html += "<button>Entrar</button></form>"
    return $html
}

function Verificar-Password([string]$password, [string]$almacenado) {
    if (-not $password -or -not $almacenado) { return $false }

    $partes = $almacenado -split '\$'
    if ($partes.Count -ne 4 -or $partes[0] -ne "pbkdf2_sha256") {
        return $false
    }

    $iteraciones = [int]$partes[1]
    $saltBytes   = [Convert]::FromBase64String($partes[2])
    $hashEsperado = [Convert]::FromBase64String($partes[3])

    $pbkdf2 = [System.Security.Cryptography.Rfc2898DeriveBytes]::new(
        $password,
        $saltBytes,
        $iteraciones,
        [System.Security.Cryptography.HashAlgorithmName]::SHA256
    )
    try {
        $hashCalculado = $pbkdf2.GetBytes($hashEsperado.Length)
    }
    finally {
        $pbkdf2.Dispose()
    }

    return [System.Security.Cryptography.CryptographicOperations]::FixedTimeEquals($hashCalculado, $hashEsperado)
}

function Registrar-Acceso($ctx, [string]$email, [string]$evento, [bool]$exito) {
    Agregar-Csv $ArchivoAccesos ([ordered]@{
        fecha     = Ahora
        email     = $email
        evento    = $evento
        exito     = [int]$exito
        ip        = $ctx.Request.RemoteEndPoint.Address.ToString()
        navegador = $ctx.Request.UserAgent
    })
}

$Rutas["/login"] = {
    param($ctx)

    if ($ctx.Request.HttpMethod -ne "POST") {
        Enviar $ctx (Nueva-Pagina "Iniciar sesión" (Formulario-Login))
        return
    }

    $form = Leer-Formulario $ctx

    # H-03 corregido: no se imprime la contraseña en la consola

    $usuario = Leer-Csv $ArchivoUsuarios | Where-Object {
        $_.email -eq $form["email"] -and (Verificar-Password $form["password"] $_.password)
    }

    Registrar-Acceso $ctx $form["email"] "login" ([bool]$usuario)

    if ($usuario) {
        Enviar $ctx (Nueva-Pagina "Bienvenido" "<p>Iniciaste sesión como $(Escapar $form['email']).</p>")
    }
    else {
        Enviar $ctx (Nueva-Pagina "Iniciar sesión" (Formulario-Login "Correo o contraseña incorrectos."))
    }
}
