defmodule Busqueda_ADN do
@moduledoc """
Modulo que busca motivos de ADN con hasta un error.
Valida Datos, Cuenta Diferencias, Registra Coincidencias y Genera Resumen.
- Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
- Fecha: Octubre del 2026
- Licencia: GNU GPL V3
"""
@muestras "Muestras.fa"
@motivos "Motivos.txt"

@doc """
Función Principal Encargada de coordinar todas las acciones que realiza el modulo
"""
def main do
  if File.exists?(@muestras) and File.exists?(@motivos) do
    datos_muestras= leer_datos(@muestras)
    datos_motivos= leer_datos(@motivos)

    datos_muestras= limpiar_muestras(datos_muestras)
    datos_motivos= limpiar_motivos(datos_motivos)

    errores= validar_datos(datos_muestras, datos_motivos)

    if errores == [] do
      motivos_unicos= eliminar_duplicados(datos_motivos)

      reversa_complementaria= construir_reversa(motivos_unicos)
      ventanas= generar_ventanas(datos_muestras, motivos_unicos)

      coincidencias_directas= buscar_coincidencias_directas(datos_muestras, motivos_unicos, ventanas)
      coincidencias_reversas= buscar_coincidencias_reversas(datos_muestras, reversa_complementaria, ventanas)

      coincidencias= registrar_coincidencias(coincidencias_directas, coincidencias_reversas)
      coincidencias_ordenadas= ordenar_coincidencias(coincidencias)
      escribir_coincidencias(coincidencias_ordenadas)

      resumen_muestras= calcular_muestras(coincidencias_ordenadas)
      resumen_motivos= calcular_motivos(coincidencias_ordenadas, motivos_unicos)
      motivos_no_encontrados= identificar_motivos_no_encontrados()

      generar_resumen(resumen_muestras, resumen_motivos, motivos_no_encontrados)
      IO.puts("Proceso Finalizado Correctamente")
    else
      escribir_errores(errores)
      IO.puts("Existen Errores de Validación")
    end
  else
    IO.puts("Error, No Existen todos los Archivos de Entrada")
  end
end

@doc """
Función que devuelve un flujo de líneas de un archivo
## Parámetros
- archivo: recibe una ruta de archivo y evita cargar todo su contenido
"""
def leer_datos(archivo) do
  File.stream!(archivo)
end

@doc """
Función que elimina líneas vacias y comentarios, conservando ">"
## Parámetros
- lineas: Flujo de lineas del archivo de muestras
"""
def limpiar_muestras(lineas) do
  lineas
  |> Stream.map(fn linea -> String.trim(linea) end)
  |> Stream.reject(fn linea -> linea == "" or String.starts_with?(linea, "#") end)
end

@doc """
Función que realiza el mismo proceso de limpiar_muestras al archivo motivos y lo convierte a mayúsculas
## Parámetros
- lineas: Flujo de lineas del archivo de motivos
"""
def limpiar_motivos(lineas) do
  limpiar_muestras(lineas)
  |> Stream.map(fn linea -> String.upcase(linea) end)
end


end

Busqueda_ADN.main()
