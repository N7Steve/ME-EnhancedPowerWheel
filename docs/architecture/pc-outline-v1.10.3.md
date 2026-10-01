# LE3 PC — outline de compañeros y retirada de ayuda v1.10.3

01-10-2026. El propietario confirma que v1.10.2 funciona bien y pide completar el outline verde de compañeros y eliminar por completo el tooltip de Espacio. La aceptación confirma el arreglo general del arrastre; no aporta una matriz separada de guardar/salir/cargar.

## Cambios y evidencia

La lectura del código confirma que el hit-test PC ya usa `_visible` y resuelve los slots físicos, mientras que la selección de outlines seguía usando `bVisible` y las listas nativas de compañeros. No se ha capturado en ejecución la discrepancia de flags como causa exacta del borde ausente.

`SFXSFHandler_PowerWheel.Update` utiliza ahora `_visible` para la selección y visibilidad de outlines en modo PC. Los destinos de compañeros se identifican por el prefijo físico del ID (`Icon10` o `Icon20`), igual que el drop PC. Se conserva el borde verde existente, su geometría y estados: marca el origen seleccionado y el destino compatible bajo el cursor, incluidos huecos. Otro compañero o Shepard no se consideran destinos compatibles para un poder de compañero. Al soltar/cancelar, el flujo existente limpia la selección. Las condiciones de mando, `Super.Update`, el reveal de apertura, fade y comportamiento de combos se mantienen.

`EPWPCPresentation` elimina toda la creación, textos, geometría, posicionamiento y localización del indicador `EPWPCSwitch`. Solo oculta ese clip y `EPWPCHelp` si quedan de una versión anterior. No se crea keycap ni texto Space / Swap bar. Se conservan el cambio de página con Espacio y los badges de asignación nativos.

## Validación

Las 27 funciones compilan contra la instalación actual y la referencia LE3 local. Pasan las comprobaciones de propiedades nativas, clases modificadas limitadas al manifest, herencia virtual 110/110 y los 15 helpers finales/no virtuales. Se revisó el diff de esta iteración contra copias locales previas. `git diff --check` pasa. Se preservaron todos los cambios locales anteriores de LE2/LE3; no se creó commit.

El paquete instalado conserva SHA256 `1D8F7ACB6F28E78030982C9F2D935CDDEC16877272ABA314CE1C21DFF5ED2D18` antes y después del trabajo. Las copias y logs locales permanecen ignorados bajo `research/local/LE3/PCOutline/`.

Pendiente en juego: borde verde del origen y destino en ambos compañeros, entre slots ocupados y huecos; ausencia de borde sobre otro personaje; limpieza al soltar/cancelar/cerrar; ausencia completa del indicador Espacio al abrir y alternar barras; regresión del borde de Shepard y controles de mando. Compilar no confirma el resultado visual.

## Export e instalación

Carpeta: `dist/EnhancedPowerWheel-LE3-PCOutline-v1.10.3-4602D5BE18E9/`.

M3M SHA256: `4602D5BE18E901AAB221C4650FEB41FB05C6843616D5585E0B7948BC59C78B18`.

Reproducir con `scripts/Build-Le3.ps1` y `scripts/Export-Le3Folder.ps1` usando las herramientas locales fijadas. Build/export no instalan; el export verifica el hash de la copia.

Instalación mediante Mod Manager: cambia únicamente `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`, clases `SFXSFHandler_PowerWheel` y `SFXSFHandler_PCPowerWheel`. Conservar el backup de basegame gestionado por Mod Manager, registrar mods instalados y respaldar la partida. Desinstalar restaurando ese backup y reaplicando los mods deseados; restaurar la partida respaldada para revertir el orden guardado. No se distribuyen PCC/SWF extraídos ni se modifica el juego durante el build.
