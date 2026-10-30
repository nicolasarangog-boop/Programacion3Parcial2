defmodule RobotRescate do
  
@moduledoc """
Modulo Principal donde se coordinan los demás modulos
- Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
- Fecha: Octubre del 2026
- Licencia: GNU GPL V3
"""

  def main do
    archivo_edificio = "edificio.txt"
    archivo_terrenos = "terrenos.csv"
    archivo_bateria = "bateria.txt"

    terrenos = Lector.cargar_terrenos(archivo_terrenos)
    bateria = Lector.cargar_bateria(archivo_bateria)
    lineas_edificio = Lector.leer_lineas_edificio(archivo_edificio)

    case Validacion.validar_edificio_recursivo(lineas_edificio, terrenos, bateria) do
      {:error, errores} ->
        Svg.guardar_errores("validacion_edificio.txt", errores)
        IO.puts("Se encontraron errores de validación. Revisa 'validacion_edificio.txt'.")

      :ok ->
        File.write!("validacion_edificio.txt", "OK: Edificio y parámetros válidos.\n")
        {matriz, inicio, meta, filas, cols} = parsear_matriz(lineas_edificio, terrenos)

        {alcanzable, pasos_expansion, indice_est} =
          Expansion.generar_stream_energia(matriz, inicio, meta, bateria, filas, cols)

        Svg.guardar_expansion("expansion_energia.txt", pasos_expansion, indice_est)

        if not alcanzable do
          IO.puts("La meta no es alcanzable dentro del presupuesto de batería.")
          Svg.construir_svg("ruta_optima.svg", matriz, filas, cols, nil, true)
          File.write!("resumen_rescate.txt", "No existe recorrido válido.\n")
          File.write!("recorridos_rescate.csv", "id;movimientos;energia;posiciones\n")
        else
          recorridos = Rescate.buscar_recorridos(matriz, inicio, meta, bateria, filas, cols)

          Svg.guardar_csv_recorridos("recorridos_rescate.csv", recorridos)
          Svg.generar_resumen("resumen_rescate.txt", recorridos)

          ruta_optima = seleccionar_ruta_optima(recorridos)
          Svg.construir_svg("ruta_optima.svg", matriz, filas, cols, ruta_optima, false)

          IO.puts("Proceso completado exitosamente.")
        end
    end
  end

  defp parsear_matriz(lineas, terrenos) do
    filas = length(lineas)
    cols = length(String.split(hd(lineas), " ", trim: true))

    {matriz, inicio, meta} =
      lineas
      |> Enum.with_index()
      |> Enum.reduce({%{}, nil, nil}, fn {linea, fila}, {acc_m, acc_i, acc_mta} ->
        simbolos = String.split(linea, " ", trim: true)
        simbolos
        |> Enum.with_index()
        |> Enum.reduce({acc_m, acc_i, acc_mta}, fn {simbolo, col}, {m_acc, i_acc, mta_acc} ->
          terreno = Map.get(terrenos, simbolo)
          nuevo_mapa = Map.put(m_acc, {fila, col}, terreno)
          nuevo_inicio = if simbolo == "S", do: {fila, col}, else: i_acc
          nueva_meta = if simbolo == "M", do: {fila, col}, else: mta_acc
          {nuevo_mapa, nuevo_inicio, nueva_meta}
        end)
      end)

    {matriz, inicio, meta, filas, cols}
  end

  defp seleccionar_ruta_optima([]), do: nil
  defp seleccionar_ruta_optima(recorridos) do
    min_energia = Enum.map(recorridos, & &1.energia_consumida) |> Enum.min()
    Enum.find(recorridos, &(&1.energia_consumida == min_energia))
  end
end
