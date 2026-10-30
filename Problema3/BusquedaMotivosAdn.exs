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
      datos_muestras = ArchivosADN.leer_datos(@muestras)
      datos_motivos = ArchivosADN.leer_datos(@motivos)

      datos_muestras = ArchivosADN.limpiar_muestras(datos_muestras)
      datos_motivos = ArchivosADN.limpiar_motivos(datos_motivos)

      errores = ValidacionADN.validar_datos(datos_muestras, datos_motivos)

      if errores == [] do
        motivos_unicos = ArchivosADN.eliminar_duplicados(datos_motivos)

        reversa_complementaria = ProcesamientoADN.construir_reversa(motivos_unicos)
        ventanas = ProcesamientoADN.generar_ventanas(datos_muestras, motivos_unicos)

        coincidencias_directas =
          ProcesamientoADN.buscar_directas(datos_muestras, motivos_unicos, ventanas)

        coincidencias_reversas =
          ProcesamientoADN.buscar_reversas(datos_muestras, reversa_complementaria, ventanas)

        coincidencias =
          ResultadosADN.registrar_coincidencias(coincidencias_directas, coincidencias_reversas)

        coincidencias_ordenadas = ResultadosADN.ordenar_coincidencias(coincidencias)
        ResultadosADN.escribir_coincidencias(coincidencias_ordenadas)

        resumen_muestras = ProcesamientoADN.calcular_muestras(coincidencias_ordenadas)

        resumen_motivos =
          ProcesamientoADN.calcular_motivos(coincidencias_ordenadas, motivos_unicos)

        motivos_no_encontrados = ProcesamientoADN.identificar_no_encontrados(resumen_motivos)

        ResultadosADN.generar_resumen(resumen_muestras, resumen_motivos, motivos_no_encontrados)
        IO.puts("Proceso Finalizado Correctamente")
      else
        ResultadosADN.escribir_errores(errores)
        IO.puts("Existen Errores de Validación")
      end
    else
      IO.puts("Error, No Existen todos los Archivos de Entrada")
    end
  end
end

Busqueda_ADN.main()
