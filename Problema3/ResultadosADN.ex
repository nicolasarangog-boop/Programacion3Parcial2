defmodule Resultados_ADN do
  @moduledoc """
   Modulo que organiza y genera los resultados del procesamiento ADN
  - Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
    - Fecha: Octubre del 2026
    - Licencia: GNU GPL V3
  """
  @doc """
  Funcion reune coincidencias directas y reversas

  ## Parámetros
  - directas: lista coincidencias orientacion directa
  - reversas: lista coincidencias orientacion reversa
  """
  def registrar_coincidencias(directas, reversas) do
    directas ++ reversas
  end

  @doc """
  Funcion ordena coincidencias por muestra, motivo, posicion inicial y orientacion

  ## Parámetros
  - coincidencias: lista coincidencias registradas
  """
  def ordenar_coincidencias(coincidencias) do
    Enum.sort_by(coincidencias, fn coincidencia ->
      orden_orientacion =
        if coincidencia.orientacion == "-" do
          0
        else
          1
        end

      {
        coincidencia.muestra,
        coincidencia.motivo,
        coincidencia.inicio,
        orden_orientacion
      }
    end)
  end

  @doc """
  Funcion escribe coincidencias en archivo CSV

  ## Parámetros
  - coincidencias: lista coincidencias ordenadas
  """
  def escribir_coincidencias(coincidencias) do
    case File.open("coincidencias_adn.csv", [:write]) do
      {:ok, archivo} ->
        IO.write(archivo, "muestra;motivo;orientacion;inicio;fin;diferencias\n")
        escribir_filas(coincidencias, archivo)
        File.close(archivo)

      {:error, razon} ->
        IO.puts("Error al crear coincidencias_adn.csv: #{:file.format_error(razon)}")
    end
  end

  # Caso base
  defp escribir_filas([], archivo) do
    archivo
  end

  # Caso recursivo
  defp escribir_filas([coincidencia | cola], archivo) do
    fila =
      "#{coincidencia.muestra};#{coincidencia.motivo};#{coincidencia.orientacion};#{coincidencia.inicio};#{coincidencia.fin};#{coincidencia.diferencias}\n"

    IO.write(archivo, fila)

    escribir_filas(cola, archivo)
  end

  @doc """
  Funcion genera resumen coincidencias por muestra y motivo, identifica motivos no encontrados y muestra resultados

  ## Parámetros
  - resumen_muestras: lista coincidencias por muestra
  - resumen_motivos: lista coincidencias por motivo
  - motivos_no_encontrados: lista motivos sin coincidencias
  """
  def generar_resumen(resumen_muestras, resumen_motivos, motivos_no_encontrados) do
    case File.open("resumen_adn.txt", [:write]) do
      {:ok, archivo} ->
        IO.write(archivo, "RESUMEN DE BUSQUEDA DE MOTIVOS ADN\n\n")
        IO.puts("RESUMEN DE BUSQUEDA DE MOTIVOS ADN\n")

        escribir_resumen_muestras(resumen_muestras, archivo)
        imprimir_resumen_muestras(resumen_muestras)

        escribir_resumen_motivos(resumen_motivos, archivo)
        imprimir_resumen_motivos(resumen_motivos)

        escribir_no_encontrados(motivos_no_encontrados, archivo)
        imprimir_no_encontrados(motivos_no_encontrados)

        File.close(archivo)

      {:error, razon} ->
        IO.puts("Error al crear resumen_adn.txt: #{:file.format_error(razon)}")
    end
  end

  # Caso base
  defp escribir_resumen_muestras([], archivo) do
    IO.write(archivo, "COINCIDENCIAS POR MUESTRA\nNo hay muestras registradas.\n\n")
  end

  # Caso recursivo
  defp escribir_resumen_muestras(resumen, archivo) do
    IO.write(archivo, "COINCIDENCIAS POR MUESTRA\n")

    escribir_registros_muestras(resumen, archivo)
  end

  # Caso baase
  defp escribir_registros_muestras([], archivo) do
    IO.write(archivo, "\n")
  end

  # Caso recursivo
  defp escribir_registros_muestras([muestra | cola], archivo) do
    IO.write(
      archivo,
      "#{muestra.muestra}: #{muestra.coincidencias} coincidencias\n"
    )

    escribir_registros_muestras(cola, archivo)
  end

  # Caso base
  defp imprimir_resumen_muestras([]) do
    IO.puts("COINCIDENCIAS POR MUESTRA\nNo hay muestras registradas.\n")
  end

  # Caso recursivvo
  defp imprimir_resumen_muestras(resumen) do
    IO.puts("COINCIDENCIAS POR MUESTRA")

    imprimir_registros_muestras(resumen)
    IO.puts("")
  end

  # Caso base
  defp imprimir_registros_muestras([]) do
    :ok
  end

  # Caso recursivo
  defp imprimir_registros_muestras([muestra | cola]) do
    IO.puts("#{muestra.muestra}: #{muestra.coincidencias} coincidencias")
    imprimir_registros_muestras(cola)
  end

  # Caso baase
  defp escribir_resumen_motivos([], archivo) do
    IO.write(archivo, "COINCIDENCIAS POR MOTIVO\nNo hay motivos registrados.\n\n")
  end

  # Caso recursivo
  defp escribir_resumen_motivos(resumen, archivo) do
    IO.write(archivo, "COINCIDENCIAS POR MOTIVO\n")

    escribir_registros_motivos(resumen, archivo)
  end

  # Caso base
  defp escribir_registros_motivos([], archivo) do
    IO.write(archivo, "\n")
  end

  # Caso recursivo
  defp escribir_registros_motivos([motivo | cola], archivo) do
    IO.write(
      archivo,
      "#{motivo.motivo}: #{motivo.coincidencias} coincidencias\n"
    )

    escribir_registros_motivos(cola, archivo)
  end

  # Caso base
  defp imprimir_resumen_motivos([]) do
    IO.puts("COINCIDENCIAS POR MOTIVO\nNo hay motivos registrados.\n")
  end

  # Caso recursivo
  defp imprimir_resumen_motivos(resumen) do
    IO.puts("COINCIDENCIAS POR MOTIVO")

    imprimir_registros_motivos(resumen)
    IO.puts("")
  end

  # Caso base
  defp imprimir_registros_motivos([]) do
    :ok
  end

  # Caso recursivo
  defp imprimir_registros_motivos([motivo | cola]) do
    IO.puts("#{motivo.motivo}: #{motivo.coincidencias} coincidencias")
    imprimir_registros_motivos(cola)
  end

  # Caso base
  defp escribir_no_encontrados([], archivo) do
    IO.write(archivo, "MOTIVOS NO ENCONTRADOS\nNinguno\n")
  end

  # Caso recursivo
  defp escribir_no_encontrados(motivos, archivo) do
    IO.write(archivo, "MOTIVOS NO ENCONTRADOS\n")

    escribir_lista_no_encontrados(motivos, archivo)
  end

  # Caso base
  defp escribir_lista_no_encontrados([], archivo) do
    archivo
  end

  # Caso recursivo
  defp escribir_lista_no_encontrados([motivo | cola], archivo) do
    IO.write(archivo, "#{motivo}\n")
    escribir_lista_no_encontrados(cola, archivo)
  end

  # Caso base
  defp imprimir_no_encontrados([]) do
    IO.puts("MOTIVOS NO ENCONTRADOS\nNinguno")
  end

  # Caso recursivo
  defp imprimir_no_encontrados(motivos) do
    IO.puts("MOTIVOS NO ENCONTRADOS")
    imprimir_lista_no_encontrados(motivos)
  end

  # Caso base
  defp imprimir_lista_no_encontrados([]) do
    :ok
  end

  # Caso recursivo
  defp imprimir_lista_no_encontrados([motivo | cola]) do
    IO.puts(motivo)
    imprimir_lista_no_encontrados(cola)
  end

  @doc """
  Funcion escribe errores de validacion en un archivo

  ## Parámetros
  - errores: lista mensajes de error encontrados
  """
  def escribir_errores(errores) do
    case File.open("validacion_adn.txt", [:write]) do
      {:ok, archivo} ->
        escribir_lista_errores(errores, archivo)
        File.close(archivo)

      {:error, razon} ->
        IO.puts("Error al crear validacion_adn.txt: #{:file.format_error(razon)}")
    end
  end

  # Caso base
  defp escribir_lista_errores([], archivo) do
    archivo
  end

  # Caso recursivo
  defp escribir_lista_errores([error | cola], archivo) do
    IO.write(archivo, "#{error}\n")
    escribir_lista_errores(cola, archivo)
  end
end
