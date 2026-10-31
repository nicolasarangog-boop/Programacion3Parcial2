defmodule Busqueda_ADN do
  @moduledoc """
  Modulo que busca motivos de ADN con hasta un error.
  Coordina la lectura, limpieza y validación de archivos, realiza varios procesos acordes para finalmente generar resultados.
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
      datos_muestras = Archivos_ADN.leer_datos(@muestras)
      datos_motivos = Archivos_ADN.leer_datos(@motivos)

      lineas_muestras = Archivos_ADN.limpiar_muestras(datos_muestras)
      lineas_motivos = Archivos_ADN.limpiar_motivos(datos_motivos)

      muestras_organizadas = Archivos_ADN.organizar_muestras(lineas_muestras)

      motivos_unicos = Archivos_ADN.eliminar_duplicados(lineas_motivos)

      errores = Validacion_ADN.validar_datos(muestras_organizadas, motivos_unicos)

      if errores == [] do
        reversas_complementarias = Procesamiento_ADN.construir_reversas(motivos_unicos)
        ventanas = Procesamiento_ADN.generar_ventanas(muestras_organizadas, motivos_unicos)

        coincidencias_directas = Procesamiento_ADN.buscar_directas(muestras_organizadas, motivos_unicos, ventanas)
        coincidencias_reversas = Procesamiento_ADN.buscar_reversas(muestras_organizadas, reversas_complementarias,ventanas)
        coincidencias = Resultados_ADN.registrar_coincidencias(coincidencias_directas, coincidencias_reversas)
        coincidencias_ordenadas = Resultados_ADN.ordenar_coincidencias(coincidencias)

        resultado_csv = Resultados_ADN.escribir_coincidencias(coincidencias_ordenadas)

        resumen_muestras = Procesamiento_ADN.calcular_muestras(muestras_organizadas, coincidencias_ordenadas)
        resumen_motivos = Procesamiento_ADN.calcular_motivos(coincidencias_ordenadas, motivos_unicos)

        motivos_no_encontrados = Procesamiento_ADN.identificar_no_encontrados(resumen_motivos)

        resultado_resumen = Resultados_ADN.generar_resumen(resumen_muestras, resumen_motivos, motivos_no_encontrados)

        if resultado_csv == :ok and resultado_resumen == :ok do
          IO.puts("Proceso Finalizado Correctamente")
        else
          IO.puts("Error: No se pudieron generar todos los archivos de resultados")
        end
      else
        resultado_validacion = Resultados_ADN.escribir_errores(errores)

        if resultado_validacion == :ok do
          IO.puts("Existen Errores de Validación. Consulte validacion_adn.txt")
        else
          IO.puts("Existen Errores de Validación, pero no se pudo crear validacion_adn.txt")
        end
      end
    else
      IO.puts("Error, No Existen todos los Archivos de Entrada")
    end
  end
end

Busqueda_ADN.main()
