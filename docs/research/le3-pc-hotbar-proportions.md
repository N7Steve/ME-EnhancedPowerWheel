# LE3 PC: proporciones de la hotbar

Investigación de solo lectura, 30-09-2026. El propietario informa de un bug vanilla: al asignar un poder a los slots 3 y 4 de la hotbar PC superior izquierda, los iconos se expanden y quedan desproporcionados. Se refiere a la barra durante el juego, no a los iconos de la rueda abierta. No se ha reproducido aquí en ejecución ni instalado un arreglo.

## Fuentes locales y comprobaciones

- Instalación: `E:\Mass Effect Legendary Edition\Game\ME3\BioGame\CookedPCConsole`. `SFXGame.pcc` SHA256 `5D98CE05E96E04A0865D3866F9E67B91C93F76F3855783D2C9AF337264EFEF65`; `Startup.pcc` SHA256 `BD083D5A3CB9EFE864350F7EFA13084FFC4DBD6D77FD628C8FB57F8D59A44962`. El primero contiene otros mods; no se considera una instalación limpia.
- Referencia: paquetes LE3 del checkout local de LegendaryExplorer, `Testing/testdata/packages/PC/LE3/BioGame/CookedPCConsole`. Esta es una referencia independiente de EPW, no una certificación de una instalación vanilla reproducida en juego. Su `SFXGame.pcc` tiene SHA256 `38BA0E72B8FF0C90AC7D105EF589301057350B726DBBFAB1B982BD4C0D77B4AF`.
- Se decompilaron 40 exports de `SFXSFHandler_PCPowerWheel` y `SFXGUIValue_QuickSlotPowerIcon` en cada paquete. Ningún fallo; los 40 archivos de fuente resultantes son idénticos entre instalación y referencia.
- Se extrajo `GUI_SF_PC_ME2_PowerWheel.PC_ME2_PowerWheel` de ambos `Startup.pcc`. Los dos SWF son idénticos: 121136 bytes, SHA256 `9094B4D96ED111EE6B7B0DAF5D0542C1B709624AB3ACEFB81A510A546819A8CF`.
- PackageResearch realizó las lecturas; JPEXS 26.3 exportó XML y ActionScript para inspección. Los originales no se guardaron desde estas herramientas. Fuente decompilada y SWF permanecen ignorados en `research/local/LE3/HotbarInvestigation/`.

## Hechos confirmados en los paquetes

La barra usa `mainContent.QuickSlots.Keys.keymapMC1` hasta `keymapMC8`, gestionados por `SFXSFHandler_PCPowerWheel`. El nombre de la clase incluye PowerWheel aunque también contenga la hotbar que permanece durante el juego.

Los ocho slots instancian el mismo símbolo SWF, sprite 326, con la misma escala inicial X/Y `1.149231`. Su hijo `iconMC` también comparte la definición y su transformación inicial, aproximadamente X `0.7464905`, Y `0.74687195`. No hay un tamaño inicial especial de los slots 3 y 4. Las posiciones horizontales no son perfectamente uniformes, pero esto no demuestra una causa de deformación al asignar poderes.

La asignación y buena parte del refresco son nativos: `NewSetQuickSlotPower`, `MoveQuickSlotPowerByName`, `SetupQuickSlotPowers`, `SFXGUIValue_PowerIcon.SetPower/UpdateDisplay` y `SFXGUIValue_QuickSlotPowerIcon.SetStateDisplay`. Sus declaraciones UnrealScript no permiten verificar qué transformaciones escriben durante la asignación.

La carga del recurso gráfico pasa por `PowerIconLoader`, `IconResourceLoader` y `ResourceLoader`. Este último calcula tamaño y posición a partir del recurso, el tamaño objetivo y la escala inversa; eso proporciona otro lugar posible de cambio de dimensiones en ejecución. No se ha demostrado que falle ni que explique una diferencia por número de slot.

`GFxValue.GetDisplayInfo/SetDisplayInfo` permite leer y modificar XScale/YScale desde UnrealScript. Por tanto, una corrección visual mediante Merge Mod es técnicamente accesible sin reemplazar el SWF completo. La disponibilidad de estas funciones no demuestra que fijar la escala resuelva este bug.

## Inferencia y límite de la conclusión

El síntoma informado es compatible con una transformación o con un cálculo de dimensiones del recurso en ejecución. La inspección estática no identifica todavía el clip que se deforma: contenedor del slot, hijo `iconMC`, recurso cargado o barra completa. No se atribuye el bug a EPW y tampoco se presenta una causa nativa concreta como confirmada.

Todavía no puede calificarse el arreglo de fácil o validado. La opción más pequeña sería restaurar únicamente la transformación que resulte incorrecta, preservando asignaciones, cooldown, textos, posición y escala global del HUD. Evitar un parche que fuerce tamaños por fotograma sin identificar primero qué objeto cambia.

## Siguiente comprobación necesaria

Obtener una captura de la hotbar normal y otra tras asignar el mismo poder a 3 y 4; comparar también ese poder en 1 o 2. Esto distingue la deformación del glifo, la caja y el conjunto de la barra. Si no basta, un diagnóstico local deberá registrar escala/dimensiones de contenedor, `iconMC` y recurso antes y después de la asignación, con la rueda cerrada.

Si la transformación incorrecta se confirma, preparar un POC aislado de presentación y validar su Merge Mod en memoria contra LE3 antes de exportarlo. La prueba en juego debe cubrir asignar, mover, intercambiar, vaciar, cooldown, cierre/apertura y recarga de partida. No se ha creado un POC ni exportado un mod en esta investigación. Cualquier despliegue posterior necesita lista de archivos, backup y desinstalación documentados.
