# =====================================================================
# src\rutas\aviso.ps1 - Aviso de privacidad (H-05 y H-07 corregidos)
# =====================================================================

function Obtener-TextoAviso() {
    $camposHtml = ""
    foreach ($campo in $Campos) {
        $camposHtml += "<li><strong>$(Escapar $campo.Etiqueta)</strong> (<code>$(Escapar $campo.Nombre)</code>): $(Escapar $campo.Finalidad).</li>"
    }

    return @"
<div class='aviso'>
  <p><strong>Responsable:</strong> $(Escapar $Organizacion) — Área: $(Escapar $Departamento).</p>
  <p><strong>Servicio:</strong> $(Escapar $Servicio).</p>
  <p><strong>Finalidades del tratamiento de datos personales:</strong></p>
  <ul>
    <li><strong>Correo electrónico</strong> (<code>email</code>): Gestionar la cuenta del pasajero y enviar confirmaciones del servicio.</li>
    <li><strong>Contraseña</strong> (<code>password</code>): Autenticar el acceso del titular (almacenada mediante hash PBKDF2-HMAC-SHA-256 con salt).</li>
    $camposHtml
    <li><strong>Bitácora técnica de seguridad y operación</strong> (<code>ip</code>, <code>navegador</code>, <code>idioma</code>, <code>fecha_registro</code>): Prevenir accesos no autorizados, diagnosticar incidencias técnicas y mantener trazabilidad del servicio.</li>
  </ul>
  <p>Puedes consultar tus derechos de acceso, rectificación, cancelación y oposición (ARCO) ante el área responsable de $(Escapar $Organizacion).</p>
</div>
"@
}

$Rutas["/aviso"] = {
    param($ctx)
    Enviar $ctx (Nueva-Pagina "Aviso de privacidad" (Obtener-TextoAviso))
}
