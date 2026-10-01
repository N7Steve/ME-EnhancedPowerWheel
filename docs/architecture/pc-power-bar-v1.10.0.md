# LE3 PC power bar — v1.10.0 POC

Implementación del 01-10-2026, pendiente de validación en juego. Añade la interfaz de teclado/ratón al estado local LE3 v1.9.30; conserva los cambios locales de LE2 y el trabajo anterior de mando. No se ha creado un commit, instalado el mod ni modificado una partida.

Informe posterior: el propietario dice que v1.10.0 funciona muy bien. Pide un indicador de Espacio centrado y reordenación de compañeros; se prepara [v1.10.1](pc-hint-squad-v1.10.1.md). No hay un informe detallado de todos los casos de la matriz siguiente.

## Hechos confirmados mediante lectura local

- El `SFXGame.pcc` instalado tiene SHA256 `10617B94C77422D9E884FDC1A5476BCB3C12B78764526941477463B7FAA66F9F`, idéntico antes y después de investigación/build/export. Es una instalación con mods, no una referencia vanilla.
- `SFXSFHandler_PCPowerWheel` hereda de `SFXSFHandler_PowerWheel`. Su modo `PWM_PC` muestra simultáneamente poderes y armas. El código anterior de EPW excluía ese modo de apertura personalizada, reconstrucción y efectos.
- Sus descriptores contienen ocho clips de Shepard y cinco por compañero bajo `mainContent.DashMain.Dash`. Los ocho quickslots bajo `mainContent.QuickSlots` son un conjunto separado. Los descriptores PC tienen rutas de mapping de mando vacías.
- La lectura del SWF instalado produce 121136 bytes y SHA256 `9094B4D96ED111EE6B7B0DAF5D0542C1B709624AB3ACEFB81A510A546819A8CF`, idéntico al SWF de la investigación anterior y a su referencia local. Por eso se reutiliza su XML/ActionScript de investigación para inspección, sin editar el recurso.
- Los clips PC conservan `powerIconMC.sub`, los ocho estados y `MouseZone`. Las formas normales/seleccionadas tienen coordenadas compatibles con el trazado EPW existente: límites aproximados X −44.25..16.65, Y −8.65..33.55 píxeles. Esto permite reutilizar los bordes sin reemplazar el SWF; su resultado visual sigue pendiente de prueba.
- `SetupMouseEventsForIcon` registra hover/down/up. Al salir borra `bDown`; al entrar en otro slot no registra una nueva pulsación. Por tanto, el callback de mouse-up del destino no es suficiente para completar una reordenación.
- El `GetDropTarget` vanilla solo comprueba los quickslots. `BeginDragging`/`StopDragging` usan el ghost compartido `DragPower`.
- La clase ofrece `NewSetQuickSlotPower`, `m_fDragStartThreshold` (3 píxeles) y el ghost `m_oDragPowerIcon`. `StartHandlingKeyPresses`, `HasFocus`, GFx `Invoke` y el evento `BIOGUI_EVENT_MOUSE_BUTTON_LEFT_RELEASE` existen en LE3. La presencia de estas APIs no demuestra su entrega/orden en ejecución.

Decompilaciones, SWF, XML y logs quedan ignorados en `research/local/LE3/PCPort/` y `research/local/LE3/HotbarInvestigation/`. No se distribuyen paquetes o recursos extraídos.

## Comportamiento implementado

- Dos páginas de ocho slots de Shepard. Abrir solicita `P`, reconstruye el orden de la partida y revela mediante `EPWOpeningPending`. La segunda página oculta poderes de compañeros como la versión de mando.
- Espacio alterna las páginas con el fade de iconos. Se lee `Key.isDown(32)` por GFx y se acepta un flanco por pulsación. La apertura memoriza el estado actual de la tecla para evitar alternar por mantenerla desde antes. La captura de teclas se restaura al cerrar.
- Clic conserva la activación vanilla, protegida por `EPWHasPower` para los vacíos. Arrastrar más allá del umbral captura la identidad original en el ghost, marca el origen/destinos en verde y usa los mouse zones como destinos, incluidos los vacíos.
- Soltar en un slot del mismo personaje reutiliza la lógica compartida de colocar/intercambiar y guardar. Shepard puede cruzar páginas manteniendo el arrastre mientras pulsa Espacio; debe esperar al fin del fade para soltar. Cada compañero se mantiene en sus cinco slots de la página 0.
- Soltar fuera, sobre otro personaje o durante el fade cancela. Cerrar o perder foco cancela. El arrastre suprime la activación accidental al soltar. Alternar durante una pulsación que aún no ha iniciado arrastre cancela esa pulsación.
- Al soltar sobre un quickslot superior se llama al setter nativo de asignación. Si el origen físico ahora muestra la otra página, sus referencias `pPower`, `pPawn` y `nmPowerName` reciben temporalmente la identidad del ghost y se restauran sincrónicamente tras el setter. Los gestos iniciados en quickslots y la selección de armas conservan sus callbacks nativos. No se cambia la cantidad, escala ni configuración de los quickslots.
- La ayuda PC muestra Espacio, página 1/2 o 2/2, arrastre y clic, anclada al dashboard. Los indicadores de asignación leen las etiquetas de las ocho teclas existentes; no crean bindings. El idioma sigue el perfil de texto.
- Comparte persistencia, filtrado de hasta 16 poderes, cooldown nativo, presentación de NotSuggested y bordes de combos con mando. Los plots de Shepard y compañeros no cambian. El guardado en disco sigue dependiendo de guardar la partida.
- Conserva `Super.Update(fDeltaT)` en ambas clases. Los eventos PC ajenos a las solicitudes internas pasan a `SFXGUIMovie`; no se consumen Escape o mouse durante el fade. Con la barra cerrada el handler PC tampoco inicializa el orden desde eventos del HUD.
- `EPW16 INPUT PC` retiene un registro de estado/tecla/arrastre/hover una vez por segundo. El lector de memoria existente encuentra ese prefijo con acceso de solo lectura; los resultados siguen ignorados.

## Validación y límites

Las 27 funciones del manifiesto compilan contra el paquete instalado y la referencia local de LegendaryExplorer (`Testing/testdata/packages/PC/LE3/BioGame/CookedPCConsole/SFXGame.pcc`, SHA256 `38BA0E72B8FF0C90AC7D105EF589301057350B726DBBFAB1B982BD4C0D77B4AF`). La herramienta comprueba que solo las clases enumeradas cambian, conserva las declaraciones de propiedades nativas de ambas clases y valida herencia virtual 110/110. Los 15 helpers EPW (11 compartidos y cuatro PC) son finales y no virtuales. La herramienta se recompiló con el SDK y Core fijados en `tools/toolchain.lock.json`.

Inferencia pendiente de prueba: el movie debe recibir Espacio en Flash y el evento global de soltar ratón aunque el callback SWF del destino no se emita. También requieren prueba la carga del ghost, el setter nativo con identidad temporal, las etiquetas de teclas, la posición de ayuda y los efectos bajo distintas escalas de HUD. Los internos nativos no se han desensamblado. Compilar y verificar estructura no confirma jugabilidad ni compatibilidad general con otros handlers/HUDs modificados.

La prueba mínima de aceptación es abrir sin hover; Espacio pulsado/mantenido; usar/vacíos; mover a hueco e intercambiar en ambas páginas; cruzar páginas arrastrando; cancelar fuera/en otro personaje; ambos compañeros; abrir en cooldown con Nova/ammo; asignación nativa y badges en ambas páginas; armas; cerrar durante fade/arrastre; perder foco; reabrir; guardar/salir/cargar; alternar a mando y repetir R3/LB/apertura personalizada. La matriz de persistencia histórica sigue sin confirmación explícita.

## Export y despliegue

Export: `dist/EnhancedPowerWheel-LE3-PC-v1.10.0-96A90A7F5610/`.

M3M SHA256: `96A90A7F5610782FCE3B05B3C6EEB6FDF1D2CF2D3C2CAFBF584125CDDB61F335`.

Reproducir: `scripts/Build-ResearchTool.ps1`, `scripts/Build-Le3.ps1` y `scripts/Export-Le3Folder.ps1`, con las rutas locales fijadas. La validación de referencia usa `PackageResearch validate` con ese paquete y el mismo manifiesto. El export contiene descriptor, instrucciones de instalación y M3M; la copia se compara por SHA256.

Archivo instalado que cambiaría: únicamente LE3 `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`, mediante Merge Mod de Mod Manager en las clases base/PC. No hay cambios a `Startup.pcc`, SWFs o Coalesced. Antes de instalar, conservar el backup de basegame gestionado por Mod Manager, registrar los mods instalados y respaldar la partida de prueba. Desinstalar restaurando ese backup y reaplicando los mods deseados; restaurar la partida respaldada revierte la disposición guardada. Build/export no hacen esa instalación. El propietario valida desde la carpeta exportada.
