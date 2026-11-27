# Validación Final y Guía de Defensa — Data Hunt (E-PDD-1)

- **Alumna:** Camila Alexandra Moraita Medina (2509224)
- **Caso de estudio:** Aeropuerto Internacional de Mérida — Registro de pasajeros

## Lista de comprobación final

1. **Sin errores de sintaxis en scripts:** Verificar que todos los `.ps1` parsean limpio en PowerShell 7.
2. **Privacidad y consentimiento (`/aviso` y `/registro`):** Confirmar que se muestra el aviso antes del alta, se exige la casilla de aceptación y se declaran los metadatos técnicos (`ip`, `navegador`, `idioma`, `fecha_registro`).
3. **Credenciales y bitácora (`/login`):** Comprobar que las contraseñas se almacenan como `pbkdf2_sha256$100000$...` y que los intentos quedan registrados en la bitácora.
4. **Administración protegida (`/admin`):** Verificar que sin clave devuelve `401` y con clave válida muestra clientes (sin hash de contraseña) y bitácora.
5. **Derechos ARCO (`/arco`):** Comprobar consulta (`Acceso`) y eliminación (`Cancelación / Eliminación`) previa validación de correo y contraseña.
6. **Cifrado en reposo y Git limpio (`datos\`):** Verificar que los archivos CSV en disco tienen prefijo `enc_aesgcm_v1:` y que ni `datos\` ni archivos de clave se suben al repositorio.