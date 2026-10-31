defmodule Archivos_ADN do
  @moduledoc """
  Modulo que procesa inicialmente los archivos de entrada.
  - Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL V3
  """

  @doc """
  Función que devuelve un flujo de líneas de un archivo y conserva número linea
  ## Parámetros
  - archivo: recibe una ruta de archivo y evita cargar todo su contenido
  """
  def leer_datos(archivo) do
    File.stream!(archivo)
    |> Stream.with_index(1)
    |> Stream.map(fn {linea, numero} ->
      %{
        numero_linea: numero,
        contenido: String.trim(linea)
      }
    end)
  end

  @doc """
  Función que elimina líneas vacias y comentarios, conservando ">"
  ## Parámetros
  - lineas: Flujo de mapas de lineas del archivo de muestras
  """
  def limpiar_muestras(lineas) do
    lineas
    |> Stream.reject(fn linea ->
      linea.contenido == "" or String.starts_with?(linea.contenido, "#")
    end)
  end

  @doc """
  Función que realiza el mismo proceso de limpiar_muestras al archivo motivos y lo convierte a mayúsculas
  ## Parámetros
  - lineas: Flujo de mapas de lineas del archivo de motivos
  """
  def limpiar_motivos(lineas) do
    limpiar_muestras(lineas)
    |> Stream.map(fn linea ->
      %{
        secuencia: String.upcase(linea.contenido),
        linea: linea.numero_linea
      }
    end)
  end

  @doc """
  Función que mediante recursividad elimina motivos duplicados y respetando el orden inicial

  ## Parámetros
  - motivos: Flujo de mapas de motivos ADN que se desea eliminar duplicados
  """
  def eliminar_duplicados(motivos) do
    Enum.to_list(motivos)
    |> eliminar_duplicados([], [])
  end

  # Caso Base
  defp eliminar_duplicados([], motivos_unicos, _motivos_vistos) do
    Enum.reverse(motivos_unicos)
  end

  # Caso Recursivo
  defp eliminar_duplicados([motivo | cola], motivos_unicos, motivos_vistos) do
    case motivo.secuencia in motivos_vistos do
      true ->
        eliminar_duplicados(cola, motivos_unicos, motivos_vistos)

      false ->
        eliminar_duplicados(cola, [motivo | motivos_unicos], [motivo.secuencia | motivos_vistos])
    end
  end

  @doc """
  Funcióm que organiza lineas de archivo muestras, agrupando fragmentos a cada identificador y consevando informacion original
  ## Parámetros
  - lineas: Flujo de mapas de lineas del archivo muestras
  """
  def organizar_muestras(lineas) do
    estado = Enum.reduce(lineas, %{
          muestras_reves: [],
          actual: nil,
          secuencias_sin_encabezado_reves: []
        },fn linea, estado ->
          if String.starts_with?(linea.contenido, ">") do
            estado = cerrar_muestra(estado)

            identificador =
              linea.contenido
              |> String.replace_prefix(">", "")
              |> String.trim()

            actual= %{
              identificador: identificador,
              linea_encabezado: linea.numero_linea,
              fragmentos_reves: []
            }

            %{estado | actual: actual}
          else
            case estado.actual do
              nil ->
                %{estado | secuencias_sin_encabezado_reves: [linea | estado.secuencias_sin_encabezado_reves]}

              muestra ->
                fragmento= %{
                  numero_linea: linea.numero_linea,
                  contenido: linea.contenido
                }

                actual= %{muestra | fragmentos_reves: [fragmento | muestra.fragmentos_reves]}

                %{estado | actual: actual}
            end
          end
        end
      )

    estado = cerrar_muestra(estado)

    %{
      muestras: Enum.reverse(estado.muestras_reves),
      secuencias_sin_encabezado: Enum.reverse(estado.secuencias_sin_encabezado_reves)
    }
  end

  defp cerrar_muestra(%{actual: nil} = estado) do
    estado
  end

  # Función que finaliza organización de muestra, recupera orden original, concatena secuencias
  defp cerrar_muestra(estado) do
    fragmentos = Enum.reverse(estado.actual.fragmentos_reves)
    secuencia = Enum.map_join(fragmentos, fn fragmento -> fragmento.contenido end)

    muestra = %{
      identificador: estado.actual.identificador,
      secuencia: secuencia,
      linea_encabezado: estado.actual.linea_encabezado,
      fragmentos: fragmentos
    }

    %{estado | muestras_reves: [muestra | estado.muestras_reves], actual: nil}
  end
end
