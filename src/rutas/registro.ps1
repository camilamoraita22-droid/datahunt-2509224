# =====================================================================
# src\rutas\registro.ps1 - Alta de clientes
# Corrección H-01 (hash PBKDF2 con salt) y H-03 (sin debug en consola)
# =====================================================================

function Hashear-Password([string]$password) {
    $saltBytes = New-Object byte[] 16
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($saltBytes)

    $pbkdf2 = [System.Security.Cryptography.Rfc2898DeriveBytes]::new(
        $password,
        $saltBytes,
        100000,
        [System.Security.Cryptography.HashAlgorithmName]::SHA256
    )
    try {
        $hashBytes = $pbkdf2.GetBytes(32)
    }
    finally {
        $pbkdf2.Dispose()
    }

    $saltB64 = [Convert]::ToBase64String($saltBytes)
    $hashB64 = [Convert]::ToBase64String($hashBytes)
    return "pbkdf2_sha256`$100000`$$saltB64`$$hashB64"
}

function Formulario-Registro([string]$mensaje = "") {
    $html = ""
    if ($mensaje) { $html += "<p class='mensaje'>$(Escapar $mensaje)</p>" }

    # HALLAZGO H-07: el formulario no muestra aviso de privacidad ni pide consentimiento
    $html += "<form method='post' action='/registro'>"
    $html += "<label>Correo electrónico <input type='email' name='email' required></label>"
    $html += "<label>Contraseña <input type='password' name='password' required minlength='8'></label>"
    foreach ($campo in $Campos) {
        $html += "<label>$(Escapar $campo.Etiqueta) <input type='$($campo.Tipo)' name='$($campo.Nombre)' required></label>"
    }
    $html += "<button>Crear cuenta</button></form>"
    return $html
}

$Rutas["/registro"] = {
    param($ctx)
    $peticion = $ctx.Request

    if ($peticion.HttpMethod -ne "POST") {
        Enviar $ctx (Nueva-Pagina "Crear cuenta" (Formulario-Registro))
        return
    }

    $form = Leer-Formulario $ctx

    # H-03 corregido: no se imprimen datos personales ni contraseñas en la consola

    if (-not $form["email"] -or -not $form["password"]) {
        Enviar $ctx (Nueva-Pagina "Crear cuenta" (Formulario-Registro "El correo y la contraseña son obligatorios."))
        return
    }
    if (Leer-Csv $ArchivoUsuarios | Where-Object { $_.email -eq $form["email"] }) {
        Enviar $ctx (Nueva-Pagina "Crear cuenta" (Formulario-Registro "Ese correo ya está registrado."))
        return
    }

    $registro = [ordered]@{}
    $registro["email"] = $form["email"]
    # H-01 corregido: se almacena el hash PBKDF2-HMAC-SHA-256 con salt aleatoria
    $registro["password"] = Hashear-Password $form["password"]
    foreach ($campo in $Campos) {
        $registro[$campo.Nombre] = $form[$campo.Nombre]
    }

    # HALLAZGO H-05: datos que el cliente nunca escribió y que ningún aviso declara
    $registro["ip"]             = $peticion.RemoteEndPoint.Address.ToString()
    $registro["navegador"]      = $peticion.UserAgent
    $registro["idioma"]         = $peticion.Headers["Accept-Language"]
    $registro["fecha_registro"] = Ahora

    # HALLAZGO H-06: el archivo users.csv se guarda sin cifrar
    Agregar-Csv $ArchivoUsuarios $registro

    Enviar $ctx (Nueva-Pagina "Cuenta creada" "<p>Tu cuenta se creó correctamente. Ya puedes <a href='/login'>iniciar sesión</a>.</p>")
}
