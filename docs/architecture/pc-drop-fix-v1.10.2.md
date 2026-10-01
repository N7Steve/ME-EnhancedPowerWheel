# LE3 PC — drop de compañeros e indicador lateral v1.10.2

01-10-2026. El propietario informa que los poderes de compañeros siguen al cursor en v1.10.1, pero no se reordenan al soltar. Pide además un indicador de Espacio mucho menor, a la derecha del último poder de Shepard y a su misma altura.

## Hechos e inferencias

- Confirmado por el propietario: el arrastre empieza y el ghost sigue al cursor; no se observa el intercambio al soltar. No hay todavía una captura de ejecución del drop fallido.
- Confirmado por lectura del paquete instalado: los defaults PC incluyen cinco índices por compañero, `aHench1=(8,9,10,11,12)` y `aHench2=(13,14,15,16,17)`. El helper compartido exige exactamente cinco índices. Los cinco clips físicos de cada lado son `Icon101..105` e `Icon201..205`. No se ha confirmado que las listas cambien de longitud en ejecución.
- Confirmado por lectura del SWF PC: sus callbacks consultan `mcIcon._visible`. La versión previa del hit-test consultaba el flag nativo `bVisible`; la reconstrucción de compañeros usa `ClearIcon` y `MadeVisible` sin restaurar explícitamente `SetVisible`.
- Hipótesis: la visibilidad del clip y el flag nativo pueden diferir tras la reconstrucción. Se alinea la selección de destino con la condición del SWF y se preserva la visibilidad durante el rebuild. No se atribuye el fallo a un internals nativo confirmado.
- Confirmado por geometría local: la numeración de Shepard alterna izquierda/derecha. El clip más a la derecha es `Icon007`, no `Icon008`. Se utiliza el límite derecho máximo de los `MouseZone`, en coordenadas del dashboard.

## Cambios

- `EPWPCDropTarget` comprueba `_visible` antes del hit-test del `MouseZone`.
- `EPWPCFinishDrag` identifica el lado mediante el ID del origen capturado. Mantiene los índices nativos si describen los cinco slots y contienen origen/destino; en caso contrario los resuelve por los cinco IDs físicos. Solo admite origen y destino dentro del mismo compañero y reutiliza `EPWSquadLayout`.
- `EPWSquadLayout` puede resolver los cinco slots físicos en modo PC si recibe una lista incompleta. Guarda la visibilidad real de cada clip y la restaura con `SetVisible` antes de su actualización. El fallback y la restauración explícita se limitan a PC. No se cambian managers, display indices, bancos de persistencia o controles de mando.
- El indicador `EPWPCSwitch` se escala al 60 %: el keycap pasa de 76×28 a 45,6×16,8 unidades del dashboard y el texto de 18 a 10,8. Se coloca ocho unidades después del borde derecho del último poder físico y se centra verticalmente en su `MouseZone`. Los límites se cachean antes del hover.
- Se guarda un único diagnóstico de último drop, `EPW16 INPUT PC drop`, con origen, destino, longitud de índices nativos/resueltos y resultado. Lo recoge el lector de memoria existente con acceso de solo lectura; no crea logs ilimitados ni escrituras/inyección en el proceso.

## Validación y límites

Las 27 funciones del manifest compilan contra el paquete instalado y contra la referencia LE3 local de LegendaryExplorer. Pasan las comprobaciones de propiedades nativas sin cambios, herencia virtual 110/110, los 15 helpers finales/no virtuales y clases modificadas limitadas a las declaradas. `git diff --check` pasa. Se revisó el diff de esta iteración contra la copia previa bajo el directorio ignorado `research/local/LE3/PCDropFix/Before/`; se preservan los cambios locales anteriores de LE2 y LE3.

El SHA256 instalado antes y después del build es `FA818889BF6D1792B832CAED4F9BFE4B7E19BA1C4BEBBD22CD96CC6D6455154A`. El juego no estaba ejecutándose durante esta revisión. La compilación no demuestra que el nuevo drop funcione en juego.

Informe posterior del propietario: v1.10.2 funciona bien; solo queda el outline verde de compañeros y solicita eliminar por completo el indicador de Espacio. Esto confirma el arreglo general del drop de compañeros, sin un informe separado de todos los casos de persistencia o cancelación. La revisión visual siguiente se registra en `pc-outline-v1.10.3.md`.

Pendiente: mover/intercambiar entre poderes y huecos de ambos compañeros; soltar sobre otro personaje o fuera; cerrar/reabrir y alternar páginas; guardar/salir/cargar; retestar Shepard, asignación a quickslots y mando. Comprobar tamaño y posición del indicador en la escala de HUD usada. Si el drop falla, capturar el último `EPW16 INPUT PC drop` y los registros de squad con `scripts/Read-Le3WheelMemory.ps1` mientras la barra siga abierta.

## Export

Carpeta: `dist/EnhancedPowerWheel-LE3-PCDropFix-v1.10.2-75614B20D647/`.

M3M SHA256: `75614B20D6471961C123CF6EF51004ECD4F8B23C15B93717C346B39BD3D2CCD4`.

Reproducir con `scripts/Build-Le3.ps1` y `scripts/Export-Le3Folder.ps1`, usando las herramientas locales fijadas. El export verifica el hash de la copia. No se instala ni se crea commit.

El merge cambia únicamente `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`, en `SFXSFHandler_PowerWheel` y `SFXSFHandler_PCPowerWheel`. No distribuye paquetes ni SWFs extraídos. Instalar mediante Mod Manager conservando su backup de basegame, registrando los mods instalados y respaldando la partida. Desinstalar restaurando ese backup y reaplicando los mods deseados; restaurar el respaldo de partida para deshacer el orden guardado.
