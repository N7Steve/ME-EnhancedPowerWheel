# LE3 GFxValue: vida de temporales, candidato v1.10.4

01-10-2026, Europe/Madrid. Investigación y candidato de corrección a partir del informe adjunto del bloqueo de PID 48956. No es un checkpoint aceptado en juego. El repositorio estaba limpio al empezar; no se modificó LE2 ni se creó commit/push.

## Evidencia y límites

El informe suministrado registra 7.812.475 wrappers en GObjects, casi todos con dos películas de rueda como Outer. Una rueda estaba lógicamente cerrada. Son entradas de la tabla, no un censo de objetos necesariamente vivos. El hilo principal estaba retirando/destruyendo objetos en una captura y progresó entre muestras: no demuestra un deadlock ni una excepción. La atribución por función y la comparación A/B siguen pendientes.

Confirmado localmente: el SFXGame instalado tiene SHA256 `E3CDC5134D941CD67C4965CB7A1CF8DCF649D727B037EC617F706BFBB0EC21BB`, igual al informe, antes y después de investigación/build/export. Su decompilación selectiva exportó 110 clases/funciones sin fallos a `research/local/LE3/GFxLifetime/Installed/`. Las fuentes EPW conservaban búsquedas repetidas tanto cerradas como visibles. GFxMovie declara RegisterGFxValue/UnregisterGFxValue; GFxValue es `within GFxMovie`, y ASValue solo contiene valores escalares, sin referencia UObject.

Se leyó offline el volcado ya existente en el workspace DTW, sin acceder a ningún proceso vivo. El material propietario, resultados y utilidades exploratorias permanecen ignorados bajo `research/local/LE3/GFxLifetime/`; no se copiaron dumps ni paquetes al repositorio público.

La rutina nativa en RVA `0x93c0b0` resuelve un miembro por nombre y, si existe, usa el Outer del receptor para llamar a la fábrica `0x937050` en `0x93c119`. Es coherente con GetObject y con wrappers hermanos cuyo Outer es la película, no el wrapper padre. La identificación nominal de esta rutina es una inferencia por firma/flujo; no se dispone de símbolos oficiales. La fábrica/registro documentados en el informe crean un UObject y registran su puntero, sin reutilizar el wrapper de una ruta anterior.

La ruta `0x90fb60 -> 0x9484c0 -> 0x2e1b60` retira por identidad de puntero de la colección `movie+0xb8` y devuelve si retiró una entrada. No llama a destrucción del objeto ni a descarga de la película. Su correspondencia con UnregisterGFxValue es inferencia por firma, colección y proximidad al thunk de RegisterGFxValue. Estos RVA solo aplican al ejecutable SHA256 `72047E65A819878397C25650CCD9C1DC646DB6B2517F88A69ACACDC6215B9EC7` del informe. No se ha observado en juego el retorno de cada retirada ni la supervivencia de filtros tras GC.

## Corrección

- `PowerWheel.Update` conserva primero `Super.Update(fDeltaT)` y sale antes del trabajo EPW si `m_bVisible` es false. Conserva el marcador `P`, `EPWOpeningPending`, disponibilidad nativa y la reconstrucción síncrona del roster. Los helpers PC también comprueban visibilidad/modo antes de buscar objetos.
- Los outlines rojo/verde se dibujan cuando falta su marca Flash `EPWCreated`. Sus frames posteriores, salida suave del combo y limpieza de hover usan rutas escalares de alfa, visibilidad y estado. El fade sigue limitado a poderes/mapping; no incluye rueda, overlay, vignette o retratos.
- NotSuggested usa metadatos escalares para sus sustitutos; solo solicita el loader al cambiar de sustituto. Las ayudas comparan selección, textos y glyphs antes de buscar wrappers; vuelven a empaquetar si un callback nativo revela textos aunque el contenido no cambie. La limpieza/restauración se conserva en cierre/transición de modo.
- Las etiquetas PC leen las asignaciones existentes con accesores escalares y solo solicitan wrappers al cambiar el texto. Cerrar llama explícitamente a su limpieza, incluso si el flag de visibilidad todavía no refleja la transición. No cambia bindings ni lógica de quickslots.
- `EPWTraceHelp` consulta su intervalo mediante un escalar antes de buscar la rueda. Mantiene los cuatro registros más recientes, una vez por segundo visible.
- Las búsquedas/creaciones restantes de funciones del manifest se registran en un array **local por invocación** mediante `EPWTempValue`. `EPWReleaseTemps` retira esos wrappers después de su último uso, incluidos retornos anticipados. Verifica `Outer == Self`, evita duplicados y no recibe iconos/paneles persistentes. Cada callback anidado tiene su propio array. No hay campos nuevos en clases nativas ni caché global.

Hipótesis de corrección: eliminar las raíces de propiedad de temporales permite al GC normal recogerlos, y convertir las rutas dominantes a escalares reduce también la producción. Desregistrar no borra de inmediato GObjects ni equivale a destruir el objeto Flash; las referencias Flash de hijos/filtros deberían conservarse por separado. Esa última propiedad y la eficacia total necesitan verificación en juego. No se fuerza GC ni se altera su frecuencia.

Hay producción residual: PC consulta Flash Key con un temporal por tick visible; el hit-test del drag solicita wrappers de MouseZone; reconstrucciones, ayudas cambiantes y métodos Flash usan temporales. No se promete cero allocations, un límite absoluto de GObjects ni compatibilidad arbitraria. El puente HUD existente despacha las implementaciones EPW heredadas; sus fuentes no requieren modificación. El comportamiento combinado y cualquier trabajo nativo/HUD heredado requieren medición.

## Validación realizada

`python scripts/Audit-Le3GFxLifetime.py` pasa para las 29 funciones del manifest, con fixtures negativos para detectar búsquedas sin scope y retornos sin retirada. Es un lint de fuente, no una prueba completa de flujo/vida ni una medición.

Las 29 funciones compilan contra el paquete instalado y el paquete LE3 de referencia local de LegendaryExplorer. Sin warnings/fallos; propiedades nativas sin cambios, solo exports de clases autorizadas modificados, herencia virtual 110/110 y 17 helpers finales/no virtuales. `git diff --check` pasa. Esto comprueba estructura/bytecode, no el resultado visual o de memoria.

Reproducir: audit anterior; `scripts/Build-Le3.ps1` con las herramientas fijadas y paths locales; `scripts/Export-Le3Folder.ps1`. El hash serializado depende del contenido exacto del export.

## Export e instalación de prueba

Carpeta: `dist/EnhancedPowerWheel-LE3-GFxLifetime-v1.10.4-A6DDDA367DAF/`.

M3M SHA256: `A6DDDA367DAF953E98B68DB54BD538C7EBDB90A13F3ED9A69C321A1003A2BC2A`.

Build/export no instalaron nada. La instalación del propietario mediante Mod Manager cambia únicamente `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`, clases PowerWheel y PCPowerWheel. Antes: identificar backup de basegame gestionado y ruta de restauración, registrar mods instalados y respaldar la partida. Desinstalar restaurando ese backup y reaplicando mods deseados; restaurar la partida respaldada para revertir orden guardado. Este export no incluye un puente HUD nuevo; mantener el existente para aislar EPW.

## A/B pendiente

Mantener partida, escena, input, FPS y mods constantes. Comparar EPW anterior y v1.10.4 con el mismo DTW v0.17 y HUD/bridge; después repetir sin DTW manteniendo HUD/bridge compatibles. El Advance suplementario de DTW puede amplificar las llamadas; el informe no respalda atribuir estos wrappers al bloque de retratos. No se modifica ni se acopla DTW.

En sesiones de 10–15 minutos o más, medir memoria privada y GFxValue por Outer al inicio y a intervalos iguales; distinguir registrados/pendientes de GC cuando sea posible, y registrar duración de pausas de limpieza. Cubrir ruedas cerradas, aperturas/cierres repetidos, holds largos, mando y PC con película inactiva, armas, páginas/R3/Espacio, LB y drag move/swap/cancel, cooldown/Nova/ammo, badges, outlines rojo/verde, cierre a mitad de fade/drag, cambio de dispositivo, pérdida de foco, nivel y guardar/salir/cargar. Verificar que textos/glyphs y filtros sobreviven a la limpieza normal.

Aceptar por tendencia acotada y regresiones visuales/controles intactos, no solo por sobrevivir dos minutos. Una nueva lectura de memoria de un proceso vivo necesita autorización para ese contexto; esta iteración solo usó el volcado offline existente. No se realizó A/B ni instalación en esta sesión.
