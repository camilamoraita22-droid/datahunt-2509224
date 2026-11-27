# Estado de hallazgos — Aeropuerto Internacional de Mérida (Registro de pasajeros)

- **H-01 (Contraseñas en texto plano):** **Corregido** en Fase 6 mediante hash `PBKDF2-HMAC-SHA-256` (100,000 iteraciones) con `salt` aleatoria de 16 bytes y verificación en tiempo constante.
- **H-02 (Panel `/admin` sin autenticación):** **Corregido** en Fase 7 exigiendo clave de administración (`DATAHUNT_ADMIN_KEY` o cabecera `X-Admin-Key`) y ocultando el hash de contraseña en la vista.
- **H-03 (Logs `[DEBUG]` con datos/credenciales):** **Corregido** en Fase 6 eliminando impresiones en consola de contraseñas y datos de registro.
- **H-04 (Tráfico por HTTP sin cifrado en tránsito):** **Mitigado en entorno local (`localhost`)** y documentado para despliegue/exposición en red con reverso TLS/HTTPS en Fase 11.
- **H-05 (Metadatos técnicos no informados):** **Atendido** en Fase 8 declarando `ip`, `navegador`, `idioma` y `fecha_registro` en `/aviso` con finalidad de seguridad y operación.
- **H-06 (CSV sin cifrado en reposo):** **Corregido** en Fase 9 cifrando en reposo con `AES-GCM` (`enc_aesgcm_v1`) los archivos CSV en `datos\` y excluyendo `datos\` y claves en `.gitignore`.
- **H-07 (Sin aviso de privacidad ni consentimiento):** **Corregido** en Fase 8 incorporando `/aviso` y casilla obligatoria de consentimiento en `/registro`, complementado en Fase 10 con atención de derechos ARCO en `/arco`.
