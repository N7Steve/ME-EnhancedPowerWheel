# HUD Enhancements — conexión PC y mando v0.4

01-10-2026. El propietario informa que con HUD Enhancements no aparecen los slots de poderes en PC y solicita actualizar el compatibility patch. Se conserva EPW v1.10.3 y se actualiza únicamente el DLC de compatibilidad.

## Evidencia y explicación

Confirmado por lectura local: la instalación contiene HUD Enhancements 1.1 y el startup del patch 0.3, SHA256 `79E5D20216CC8EE9E29AAA6C77D5929A88DA2BEE5B20272D9F206199AA97F3FD`. Ese patch sustituye únicamente `ConsolePowerWheel` y contiene solo la conexión de mando. `PowerWheel` sigue registrado con `HUDEnhanced.SFXModHandler_HybridPowerWheel_PC`.

El `Update` de HUD PC mantiene el radar y estado de quickslots y llama directamente al legacy adapter, omitiendo el `Update` de EPW PC. EPW deja los iconos transparentes durante la apertura hasta que su Update reconstruye/revela la página personalizada. El bypass está confirmado en el código y es una explicación consistente del informe; esta revisión no incluye una captura de ejecución que demuestre la cadena causal completa.

El `HandleInputEvent` de HUD PC preserva su control de cámara con botón derecho, pero su ruta por defecto llama directamente al wheel base y omite el handler PC de EPW. Hay que conectar también esa ruta para el release de arrastre y la entrada durante los fades.

Se leyó el SWF PC instalado de HUD Enhancements (121259 bytes). Las 25 instancias relevantes — `mainContent`, `DashMain`, `Dash`, `powerIconMC`, `sub`, `MouseZone`, `DragPower`, ocho slots de Shepard y cinco por compañero — conservan los mismos IDs de sprite propietario y personaje que el SWF PC de referencia local. Esto comprueba la jerarquía utilizada, sin establecer igualdad de geometría o de apariencia. No se reemplaza ni distribuye el SWF.

## Cambio mínimo

Se añade la clase original `EPWHUDCompat.EPWHUDPCWheel`, hija del handler PC de HUD. `Update` ejecuta primero el Update de HUD, conservando sus funciones privadas de radar/quickslots, y después el Update PC de EPW, que incluye el Update base compartido, redraw, reveal, fades, outlines y procesamiento de Space/arrastre.

Ambas rutas invocan el legacy adapter. La función instalada `SFXGUIMovieLegacyAdapter.Update` está vacía; el builder comprueba su cuerpo decompilado y rechaza un adapter con trabajo para evitar ejecutarlo dos veces. Esta es una limitación explícita del puente, no una afirmación de compatibilidad con cualquier mod que sustituya ese adapter.

El input mantiene el handler HUD para botón derecho y modos ajenos a PC. El resto de eventos PC usa explícitamente `SFXSFHandler_PCPowerWheel.HandleInputEvent`. Los callbacks de mouse down/up son finales en la clase PC de EPW, no entradas de su tabla virtual; el builder verifica que existen y que HUD no los redefine. La visibilidad y el resto de comportamiento HUD siguen heredados.

La clase de mando no cambia. El config sustituye exactamente un registro `PowerWheel` y uno `ConsolePowerWheel`, preservando los GFxResource, ZOrder y autoload de HUD. Se registran ambas clases en DynamicLoadMapping y se mantienen el preload de HUD antes del patch, `CombinedStartupReferencer`, mount 5088 y referencias a ambas clases/defaults. Los controles de quickslots no se reescriben.

## Validación

- El helper compila con la toolchain fijada, sin errores ni warnings.
- Compilan ambas clases contra los paquetes instalados; la fuente decompilada conserva los Super explícitos de ambas conexiones PC y la conexión de mando.
- Pasan resolución de imports, despacho virtual de Update/input, herencia final de callbacks de ratón, guard de exports originales y comprobación de adapter vacío.
- El startup guardado se reabre y verifica ambas clases, sus funciones y las cuatro referencias clase/default en el referencer. Contiene 14 exports originales; no contiene código de dependencias ni assets extraídos.
- Pasa la lectura del config serializado, mappings de ambas clases, preload ordenado y simulación de merge con exactamente un registro de cada rueda; el resto de MovieLibrary permanece igual.
- El export comprueba los hashes de todos sus archivos. `git diff --check` pasa. Investigación SWF/config y logs permanecen ignorados bajo `research/local/LE3/HUDPC/`.

Los hashes instalados antes/después permanecen iguales: `SFXGame.pcc` = `EE9C492BFD1443A8FDCC88D054EAEA2DADA4E14DBBEF937685A7B09CC7CCEB96`; startup HUD = `6F2F829EA51B9B6650F72101EAED2C1AAD344485E999B7DD792CA3A594C0323D`; startup del patch instalado 0.3 = hash citado arriba. No se instala ni se crea commit. Se preservan los cambios locales anteriores de LE2/LE3.

Pendiente en juego: aparición inmediata de todos los slots PC; Space ida/vuelta, fades y cierre; drag/move/swap de Shepard y ambos compañeros, huecos y outlines; clic, cancelación y cooldown; botón derecho/cámara y restauración de sensibilidad; radar, estado de quickslots, armas y cambio de dispositivo; regresión RB/R3/LB de mando y guardar/salir/cargar. Mantener las tres opciones de prompts de HUD; no se modifican sus config deltas.

## Artefacto y uso

Export: `dist/EPW-HUDEnhancements-Compatibility-v0.4-9E6E872A9D25/`.

Startup PCC SHA256: `9E6E872A9D25B90F5282D0193601E202E75A80155FDDEB150F9B180412A964CA`.

Es un DLC separado, no un M3M. Todos los hashes y imports están en `build-evidence.json`. Reproducir con `scripts/Build-ResearchTool.ps1`, `scripts/Build-HudCompatibility.ps1` y `scripts/Export-HudCompatibility.ps1`, usando las herramientas fijadas y un directorio de build nuevo. Requiere EPW 1.10.3 y el paquete inspeccionado de HUD Enhancements 1.1; ambos se abren solo para lectura.

Con LE3 cerrado, conservar el backup de basegame de Mod Manager y respaldar la partida y el DLC anterior de compatibilidad. Retirar `DLC_MOD_EPWHUDCompat` 0.3 mediante Mod Manager, importar el nuevo export e instalarlo después de los dos mods requeridos.

Archivos añadidos/reemplazados exclusivamente en `BIOGame/DLC/DLC_MOD_EPWHUDCompat/CookedPCConsole`: `Startup_MOD_EPWHUDCompat_INT.pcc`, `Default_DLC_MOD_EPWHUDCompat.bin`, `Mount.dlc` y los ocho TLK INT/DEU/ESN/FRA/ITA/JPN/POL/RUS. Mod Manager puede mantener sus metadatos/config gestionada. No se sustituyen SFXGame, paquetes HUD, SWFs ni partidas.

Desinstalar con el juego cerrado retirando únicamente este DLC mediante Mod Manager; la configuración HUD original se aplica al siguiente arranque. Para volver a 0.3, restaurar el DLC respaldado. Conservar EPW/HUD si solo se retira el patch. El export incluye `INSTALL.txt` con estas instrucciones.
