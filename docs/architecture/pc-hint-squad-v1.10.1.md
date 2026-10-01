# LE3 PC — indicador centrado y orden de compañeros v1.10.1

01-10-2026. El propietario informa que v1.10.0 «funciona muy bien» y pide retirar la ayuda larga, añadir un indicador de Espacio centrado sobre los poderes y hacer reordenables los poderes de compañeros. Esa aceptación general no equivale a confirmar todos los casos de la matriz anterior ni guardar/salir/cargar.

## Cambios

- `EPWPCPresentation` oculta el antiguo `EPWPCHelp` y crea una sola fila: tecla `Space` + `Swap bar`, o `Espacio` + `Alternar barra` según el idioma del perfil. No muestra instrucciones de clic/arrastre ni contador de páginas.
- La tecla es un keycap vectorial redondeado, con texto AeroLight Shared azul, construido mediante GFx. Las texturas PC inspeccionadas en `Startup.pcc` proporcionan botones de ratón; no se encontró allí una textura independiente de Espacio. No se reemplaza ni distribuye un SWF.
- La fila se centra usando los límites combinados de los ocho `MouseZone` de Shepard, convirtiendo sus posiciones y dimensiones a coordenadas del dashboard. La posición vertical deja ocho píxeles entre el keycap de 28 píxeles y el límite superior de los poderes. Se mide la anchura real de la etiqueta para centrar tecla, separación y texto como un único conjunto.
- Los límites se cachean antes del hover para evitar desplazamientos por animación. El indicador hereda el posicionamiento/escala del dashboard y su visibilidad sigue la barra abierta. Los badges de asignación existentes no cambian.
- `EPWPCFinishDrag` aplica los drops de compañeros directamente a `EPWSquadLayout` usando el origen capturado y el destino del mismo compañero. Reutiliza el almacenamiento y reconstrucción existentes de mando; refresca presentación/hover y reproduce el sonido de colocación. El drop de Shepard conserva la ruta anterior. No se transfieren poderes entre personajes ni se modifican sus poderes reales.

## Evidencia y validación

Confirmado mediante lectura local: la instalación actual contiene el merge PC de v1.10.0 y el `SFXGame.pcc` tiene SHA256 `68D78BF29C09CFD54EA33EE633E9B7CE4BFC230FB1FFF8418AC12A37BFAA09B5`. Ese hash permanece igual tras el trabajo. Se revisaron las APIs de bloqueo, los callbacks PC y la geometría de los mouse zones. `IsPawnBlocked(None)` devuelve FALSE en la fuente instalada; no se atribuye a ese caso un fallo de arrastre.

La versión previa ya intentaba ordenar compañeros mediante la selección LB compartida. Este cambio conecta el drop PC directamente con la rutina persistente. Sin captura de ejecución del intento anterior, no se establece una causa de fallo nativa como confirmada.

Informe posterior del propietario: en v1.10.1 el icono del compañero sigue al cursor, pero al soltar no se reordena. Por tanto, el arrastre sí empieza y esta versión no resuelve el drop de compañeros. La siguiente revisión se registra en `pc-drop-fix-v1.10.2.md`.

Las 27 funciones compilan contra la instalación y la referencia local LE3 de LegendaryExplorer. Pasan las comprobaciones de propiedades nativas, herencia virtual 110/110 y los 15 helpers finales/no virtuales. `git diff --check` pasa. Lecturas, extracción de PC Shared Assets y logs permanecen ignorados bajo `research/local/LE3/PCPolish/`.

Pendiente en juego: comprobar el centrado y legibilidad en la escala de HUD del propietario; mover/intercambiar en los cinco slots de cada compañero, incluido un hueco; cancelar sobre otro personaje; cerrar/reabrir y Espacio ida/vuelta; persistencia al guardar/salir/cargar. Retestar Shepard entre páginas y mapping nativo. La nueva fila y la ruta directa de compañeros no se presentan como validadas por el informe de v1.10.0.

## Export

Carpeta: `dist/EnhancedPowerWheel-LE3-PCPolish-v1.10.1-3E746BD1FADA/`.

M3M SHA256: `3E746BD1FADA34FBE4DDA85A1B1557B31DCEB420C21B470ACE4A563E744F7F7E`.

Reproducir con `scripts/Build-Le3.ps1` y `scripts/Export-Le3Folder.ps1` usando la configuración local de herramientas fijadas. La compilación valida antes de serializar y el export comprueba la copia del M3M por hash.

Instalar únicamente mediante Mod Manager: el merge cambia LE3 `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc` en las clases base/PC. No cambia `Startup.pcc`, Coalesced o bindings. Conservar el backup de basegame gestionado por Mod Manager, registrar los mods instalados y respaldar la partida. Desinstalar restaurando ese backup y reaplicando los mods deseados; restaurar el respaldo de partida revierte el orden guardado. Build/export no instalan. No se ha creado un commit ni modificado el juego.
