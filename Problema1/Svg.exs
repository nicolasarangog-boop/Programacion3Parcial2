defmodule Svg do
   @moduledoc """
  Módulo encargado de guardar los resultados del proceso de rescate
  en archivos de texto, CSV y SVG.

  - Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL V3
  """

   @doc """
  Guarda los errores encontrados durante la validación en un archivo.

  ## Parámetros
  - ruta: nombre o ubicación del archivo donde se guardarán los errores.
  - errores: lista de mensajes que describen los errores encontrados.

  ## Ejemplo
      iex> Svg.guardar_errores("errores.txt", ["Error en la matriz", "Batería inválida"])
      :ok
  """
  def guardar_errores(ruta, errores) do
    contenido = Enum.join(errores, "\n")
    File.write!(ruta, contenido <> "\n")
  end

  @doc """
  Guarda en un archivo los pasos de expansión de energía calculados y Ordena las posiciones de cada mapa de expansión y convierte
  sus coordenadas y costos en texto.

  ## Parámetros
  - ruta: nombre o ubicación del archivo de salida.
  - pasos: lista de mapas que contienen los costos de energía correspondientes a cada paso de expansión.
  - indice_est: índice en el que se detectó la estabilización.

  ## Ejemplo
      iex> Svg.guardar_expansion("expansion.txt", [%{{0, 0} => 0, {0, 1} => 2}], 1)
      :ok
  """
  def guardar_expansion(ruta, pasos, indice_est) do
    lineas =
      pasos
      |> Enum.with_index()
      |> Enum.map(fn {mapa_paso, paso} ->
        costos =
          mapa_paso
          |> Enum.sort()
          |> Enum.map(fn {{f, c}, costo} -> "(#{f},#{c}):#{costo}" end)
          |> Enum.join(" ")

        "Paso #{paso}: #{costos}"
      end)

    header = "Índice de estabilización: #{indice_est}\n\n"
    File.write!(ruta, header <> Enum.join(lineas, "\n") <> "\n")
  end

  @doc """
  Exporta los recorridos encontrados a un archivo CSV.

  ## Parámetros
  - ruta: nombre o ubicación del archivo CSV.
  - recorridos: lista de estructuras que contienen las posiciones, la energía consumida y los movimientos realizados.

  ## Ejemplo
      iex> recorrido = %Recorrido{
      ...>   posiciones: [{0, 0}, {0, 1}, {1, 1}],
      ...>   energia_consumida: 5,
      ...>   cantidad_movimientos: 2
      ...> }
      iex> Svg.guardar_csv_recorridos("recorridos.csv", [recorrido])
      :ok
  """

def guardar_csv_recorridos(ruta, recorridos) do
    lineas =
      recorridos
      |> Enum.with_index(1)
      |> Enum.map(fn {r, id} ->
        movs =
          r.posiciones
          |> Enum.chunk_every(2, 1, :discard)
          |> Enum.map(fn [{f1, c1}, {f2, c2}] ->
            cond do
              f2 == f1 - 1 -> "U"
              f2 == f1 + 1 -> "D"
              c2 == c1 - 1 -> "L"
              c2 == c1 + 1 -> "R"
              true -> ""
            end
          end)
          |> Enum.join("")

        pos = Enum.map(r.posiciones, fn {f, c} -> "(#{f},#{c})" end) |> Enum.join("->")
        "#{id};#{movs};#{r.energia_consumida};#{pos}"
      end)

    header = "id;movimientos;energia;posiciones\n"
    File.write!(ruta, header <> Enum.join(lineas, "\n") <> "\n")
  end

 @doc """
  Genera un resumen estadístico de los recorridos encontrados.

  ## Parámetros
  - ruta: nombre o ubicación del archivo donde se guardará el resumen.
  - recorridos: lista de estructuras `%Recorrido{}` que se analizarán.

  ## Ejemplo
      iex> Svg.generar_resumen("resumen.txt", [])
      Total de recorridos: 0
      No existe recorrido válido.
      :ok
  """
  def generar_resumen(ruta, recorridos) do
    total = length(recorridos)

    contenido =
      if total == 0 do
        "Total recorridos: 0\nNo existe recorrido válido.\n"
      else

        min_movs = Enum.map(recorridos, & &1.cantidad_movimientos) |> Enum.min()
        min_energ = Enum.map(recorridos, & &1.energia_consumida) |> Enum.min()

        mejores_movs = Enum.filter(recorridos, &(&1.cantidad_movimientos == min_movs))
        mejores_energ = Enum.filter(recorridos, &(&1.energia_consumida == min_energ))

        """
        Total de recorridos: #{total}
        Recorridos con menos movimientos (#{min_movs} pasos): #{length(mejores_movs)}
        Recorridos con menor consumo (#{min_energ} energía): #{length(mejores_energ)}
        """
      end

    File.write!(ruta, contenido)
    IO.puts(contenido)
  end
@doc """
  Construye una imagen SVG del edificio y representa la ruta óptima del robot cuando existe un recorrido válido.

  ## Parámetros
  - ruta: nombre o ubicación del archivo SVG que se generará.
  - matriz: mapa que relaciona las coordenadas con sus estructuras correspondientes.
  - filas: cantidad de filas del edificio.
  - cols: cantidad de columnas del edificio.
  - ruta_optima: estructura con las posiciones de la ruta seleccionada, o `nil` si no se proporciona una ruta.
  - sin_ruta?: valor booleano que indica si debe mostrarse el mensaje de ausencia de recorrido.

  ## Ejemplo
      iex> matriz = %{
      ...>   {0, 0} => %Terreno{simbolo: "S"},
      ...>   {0, 1} => %Terreno{simbolo: "M"}
      ...> }
      iex> Svg.construir_svg("edificio.svg", matriz, 1, 2, nil, true)
      :ok
  """
  def construir_svg(ruta, matriz, filas, cols, ruta_optima, sin_ruta?) do
    tam = 40
    ancho = cols * tam
    alto = filas * tam

    celdas_svg =
      for f <- 0..(filas - 1), c <- 0..(cols - 1) do
        terreno = Map.get(matriz, {f, c})
        color = obtener_color(terreno)
        x = c * tam
        y = f * tam

        """
        <rect x="#{x}" y="#{y}" width="#{tam}" height="#{tam}" fill="#{color}" stroke="#ccc" stroke-width="1"/>
        <text x="#{x + 20}" y="#{y + 25}" font-size="16" text-anchor="middle" fill="#000">#{terreno.simbolo}</text>
        """
      end

    lineas_ruta =
      if not sin_ruta? and ruta_optima != nil do
        puntos =
          ruta_optima.posiciones
          |> Enum.map(fn {f, c} -> "#{c * tam + 20},#{f * tam + 20}" end)
          |> Enum.join(" ")

        """
        <polyline points="#{puntos}" fill="none" stroke="red" stroke-width="4" stroke-dasharray="5,5"/>
        """
      else
        if sin_ruta? do
          """
          <text x="#{ancho / 2}" y="#{alto / 2}" font-size="24" text-anchor="middle" fill="red" font-weight="bold">sin recorrido</text>
          """
        else
          ""
        end
      end

    svg_completo = """
    <svg xmlns="http://www.w3.org/2000/svg" width="#{ancho}" height="#{alto}">
      #{Enum.join(celdas_svg, "\n")}
      #{lineas_ruta}
    </svg>
    """

    File.write!(ruta, svg_completo)
  end

  defp obtener_color(%Terreno{simbolo: "X"}), do: "#333333"
  defp obtener_color(%Terreno{simbolo: "S"}), do: "#4CAF50"
  defp obtener_color(%Terreno{simbolo: "M"}), do: "#F44336"
  defp obtener_color(%Terreno{simbolo: "L"}), do: "#795548"
  defp obtener_color(_), do: "#FFFFFF"
end
