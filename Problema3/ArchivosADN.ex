defmodule Archivos_ADN do
  @moduledoc """
  Modulo que procesa inicialmente los archivos de entrada.
  - Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL V3
  """

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

  @doc """
  Función que mediante recursividad elimina motivos duplicados y respetando el orden inicial

  ## Parámetros
  - motivo: Lista de motivos ADN que se desea eliminar duplicados
  """
  def eliminar_duplicados(motivos) do
    eliminar_duplicados(motivos, [], [])
  end

  # Caso Base
  defp eliminar_duplicados([], motivos_unicos, _motivos_vistos) do
    Enum.reverse(motivos_unicos)
  end

  # Caso Recursivo
  defp eliminar_duplicados([motivo | cola], motivos_unicos, motivos_vistos) do
    case motivo in motivos_vistos do
      true ->
        eliminar_duplicados(cola, motivos_unicos, motivos_vistos)

      false ->
        eliminar_duplicados(cola, [motivo | motivos_unicos], [motivo | motivos_vistos])
    end
  end
end
