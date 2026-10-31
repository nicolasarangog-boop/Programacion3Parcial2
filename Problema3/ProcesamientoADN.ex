defmodule Procesamiento_ADN do
  @moduledoc """
  Modulo que realiza el procesamiento de las secuencias ADN
  - Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL V3
  """
  @doc """
  Función para construir las reversas complementarias de los motivos
  ## Parámetros
  - motivos: lista mapas que contienen la secuencia y linea de cada motivo
  """
  def construir_reversas(motivos) do
    construir_reversas(motivos, [])
  end

  # Caso base
  defp construir_reversas([], reversas) do
    Enum.reverse(reversas)
  end

  # Caso recursivo
  def construir_reversas([motivo | cola], reversas) do
    reversa = reversa_complementaria(motivo.secuencia)

    motivo_con_reversa = %{
      secuencia: motivo.secuencia,
      linea: motivo.linea,
      reversa: reversa
    }

    construir_reversas(cola, [motivo_con_reversa | reversas])
  end

  @doc """
  FUncion para construir la reversa complementaria de una secuencia
  ## Parametros
  - secuencia: cadena ADN que se desea transformar
  """
  def reversa_complementaria(secuencia) do
    bases = String.graphemes(secuencia)
    reversa_complementaria(bases, "")
  end

  # Caso base
  defp reversa_complementaria([], resultado) do
    resultado
  end

  # Caso recursivo
  defp reversa_complementaria([base | cola], resultado) do
    complemento =
      case base do
        "A" -> "T"
        "T" -> "A"
        "C" -> "G"
        "G" -> "C"
      end

    reversa_complementaria(cola, complemento <> resultado)
  end

  @doc """
  Funcion genera ventanas de secuencias muestras segun longitud de cada motivo
  ## Parametros
  - muestras: Mapa muestras organizadas
  - motivos: lista mapas motivos ADN
  """
  def generar_ventanas(muestras, motivos) do
    generar_ventanas(muestras.muestras, motivos, [])
  end

  # Caso base
  defp generar_ventanas([], _motivos, ventanas) do
    Enum.reverse(ventanas)
  end

  # Caso Recursivo
  defp generar_ventanas([muestra | cola], motivos, ventanas) do
    nuevas_ventanas = generar_ventanas_motivos(muestra, motivos, [])
    generar_ventanas(cola, motivos, Enum.reverse(nuevas_ventanas) ++ ventanas)
  end

  # Caso base
  defp generar_ventanas_motivos(_muestra, [], ventanas) do
    Enum.reverse(ventanas)
  end

  # Caso recursivo
  defp generar_ventanas_motivos(muestra, [motivo | cola], ventanas) do
    longitud = String.length(motivo.secuencia)

    nuevas_ventanas =
      generar_ventana_secuencia(
        muestra.secuencia,
        muestra.identificador,
        motivo.secuencia,
        longitud,
        0,
        []
      )

    generar_ventanas_motivos(
      muestra,
      cola,
      Enum.reverse(nuevas_ventanas) ++ ventanas
    )
  end

  # Caso Base: no hay suficientes bases para otra ventana
  defp generar_ventana_secuencia(secuencia, _identificador, _motivo, longitud, inicio, ventanas)
       when inicio + longitud > String.length(secuencia) do
    Enum.reverse(ventanas)
  end

  # Caso Recursivo
  defp generar_ventana_secuencia(
         secuencia,
         identificador,
         motivo,
         longitud,
         inicio,
         ventanas
       ) do
    ventana = String.slice(secuencia, inicio, longitud)

    nueva_ventana = %{
      muestra: identificador,
      motivo: motivo,
      secuencia: ventana,
      inicio: inicio,
      fin: inicio + longitud - 1
    }

    generar_ventana_secuencia(
      secuencia,
      identificador,
      motivo,
      longitud,
      inicio + 1,
      [nueva_ventana | ventanas]
    )
  end

  @doc """
  Funcion busca coincidencias entre motivos y ventanas, orientacion directa, hasta con un error
  ## Parámetros
  - muestras: mapa muestras organizadas
  - motivos: lista motivos ADN
  - ventanas: Lista ventanas generadas
  """
  def buscar_directas(_muestras, motivos, ventanas) do
    buscar_coincidencias(motivos, ventanas, "+", [])
  end

  @doc """
  Funcion  busca coincidencias entre reversas complementarias y ventanas, orientacion reversa
  ## Parámetros
  - muestras: mapa muestras organizadas
  - reversas: lista motivos reversas complementarias
  - ventanas: lista ventanas generadas
  """
  def buscar_reversas(_muestras, reversas, ventanas) do
    buscar_coincidencias(reversas, ventanas, "-", [])
  end

  # Caso base
  defp buscar_coincidencias([], _ventanas, _orientacion, coincidencias) do
    Enum.reverse(coincidencias)
  end

  # Caso recursivo
  defp buscar_coincidencias([motivo | cola], ventanas, orientacion, coincidencias) do
    secuencia_motivo =
      if orientacion == "+" do
        motivo.secuencia
      else
        motivo.reversa
      end

    nuevas_coincidencias =
      comparar_ventanas(secuencia_motivo, motivo.secuencia, ventanas, orientacion, [])

    buscar_coincidencias(
      cola,
      ventanas,
      orientacion,
      Enum.reverse(nuevas_coincidencias) ++ coincidencias
    )
  end

  # Caso base
  defp comparar_ventanas(_motivo, _motivo_original, [], _orientacion, coincidencias) do
    Enum.reverse(coincidencias)
  end

  # Caso recursivo
  defp comparar_ventanas(motivo, motivo_original, [ventana | cola], orientacion, coincidencias) do
    if ventana.motivo == motivo_original do
      diferencias = contar_diferencias(motivo, ventana.secuencia)

      nuevas_coincidencias =
        if diferencias <= 1 do
          coincidencia = %{
            muestra: ventana.muestra,
            motivo: motivo_original,
            orientacion: orientacion,
            inicio: ventana.inicio,
            fin: ventana.fin,
            diferencias: diferencias
          }

          [coincidencia | coincidencias]
        else
          coincidencias
        end

      comparar_ventanas(
        motivo,
        motivo_original,
        cola,
        orientacion,
        nuevas_coincidencias
      )
    else
      comparar_ventanas(
        motivo,
        motivo_original,
        cola,
        orientacion,
        coincidencias
      )
    end
  end

  @doc """
  Funcion cuenta diferencias entre dos secuencias igual longitud.
  ## Parámetros
  - motivo: secuencia motivo que se desea comparar
  - ventana: fragmento muestra que se compara con motivo
  """
  def contar_diferencias(motivo, ventana) do
    bases_motivo = String.graphemes(motivo)
    bases_ventana = String.graphemes(ventana)

    contar_diferencias(bases_motivo, bases_ventana, 0)
  end

  # Caso Base
  defp contar_diferencias([], [], diferencias) do
    diferencias
  end

  # Caso Recursivo
  defp contar_diferencias([base_motivo | cola_motivo], [base_ventana | cola_ventana], diferencias) do
    nuevas_diferencias =
      if base_motivo == base_ventana do
        diferencias
      else
        diferencias + 1
      end

    if nuevas_diferencias > 1 do
      nuevas_diferencias
    else
      contar_diferencias(cola_motivo, cola_ventana, nuevas_diferencias)
    end
  end

  @doc """
  Funcion calcula cantidad coincidencias encontradas por muestra.
  ## Parámetros
  - muestras: mapa muestras organizadas
  - coincidencias: lista coincidencias registradas.
  """
  def calcular_muestras(muestras, coincidencias) do
    calcular_resumen_muestras(
      Enum.map(muestras.muestras, fn muestra -> muestra.identificador end),
      coincidencias,
      []
    )
  end

  # Caso base
  defp calcular_resumen_muestras([], _coincidencias, resumen) do
    Enum.reverse(resumen)
  end

  # Caso recursivo
  defp calcular_resumen_muestras([muestra | cola], coincidencias, resumen) do
    cantidad =
      Enum.count(coincidencias, fn coincidencia ->
        coincidencia.muestra == muestra
      end)

    registro = %{
      muestra: muestra,
      coincidencias: cantidad
    }

    calcular_resumen_muestras(cola, coincidencias, [registro | resumen])
  end

  @doc """
  Funcion calcula cantidad coincidencias encontradas por motivo.
  ## Parámetros
  - coincidencias: lista coincidencias registradas
  - motivos: lista completa motivos originales
  """
  def calcular_motivos(coincidencias, motivos) do
    calcular_resumen_motivos(motivos, coincidencias, [])
  end

  # Caso base
  defp calcular_resumen_motivos([], _coincidencias, resumen) do
    Enum.reverse(resumen)
  end

  # Caso recursivo
  defp calcular_resumen_motivos([motivo | cola], coincidencias, resumen) do
    cantidad =
      Enum.count(coincidencias, fn coincidencia ->
        coincidencia.motivo == motivo.secuencia
      end)

    registro = %{
      motivo: motivo.secuencia,
      coincidencias: cantidad
    }

    calcular_resumen_motivos(cola, coincidencias, [registro | resumen])
  end

  @doc """
  Funcion identifica motivos que no tuvieron coincidencias
  ## Parámetros
  - resumen_motivos: lista resumen coincidencias por motivo
  """
  def identificar_no_encontrados(resumen_motivos) do
    identificar_no_encontrados(resumen_motivos, [])
  end

  # Caso Base
  defp identificar_no_encontrados([], no_encontrados) do
    Enum.reverse(no_encontrados)
  end

  # Caso Recursivo
  defp identificar_no_encontrados([motivo | cola], no_encontrados) do
    if motivo.coincidencias == 0 do
      identificar_no_encontrados(cola, [motivo.motivo | no_encontrados])
    else
      identificar_no_encontrados(cola, no_encontrados)
    end
  end
end
