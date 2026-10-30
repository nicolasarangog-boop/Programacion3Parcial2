defmodule Expansion do
  @moduledoc """
  Modulo para generar la expansion de energia en una matriz
  utilizando un proceso de relajacion hasta alcanzar un estado estable
  - Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL V3
  """

  @doc """
  Funcion para generar un stream de energia a partir de una posicion inicial
  hasta determinar si una meta es alcanzable y detectar cuando el estado se estabiliza

  ## Parametros
  - Matriz: Mapa que representa la matriz y contiene la informacion de cada terreno
  - Inicio: Posicion inicial desde donde comienza la expansion de energia
  - Meta: Posicion que se desea determinar si es alcanzable
  - Bateria: Cantidad maxima de energia disponible
  - Filas: Cantidad de filas de la matriz
  - Cols: Cantidad de columnas de la matriz

  ## Ejemplo
  iex> Expansion.generar_stream_energia(matriz, {0, 0}, {2, 2}, 20, 3, 3)
  {true, pasos, indice_estabilizacion}
  """
  def generar_stream_energia(matriz, inicio, meta, bateria, filas, cols) do
    estado_inicial = %{inicio => 0}

    pasos_stream = Stream.iterate(estado_inicial, fn estado_actual ->
      calcular_paso_relajacion(estado_actual, matriz, bateria, filas, cols)
    end)

    {pasos, indice_estabilizacion} = detectar_estabilizacion(pasos_stream)
    estado_final = List.last(pasos)
    meta_alcanzable = Map.has_key?(estado_final, meta)

    {meta_alcanzable, pasos, indice_estabilizacion}
  end

  defp calcular_paso_relajacion(estado_actual, matriz, bateria, filas, cols) do
    Enum.reduce(0..(filas - 1), estado_actual, fn fila, acc_f ->
      Enum.reduce(0..(cols - 1), acc_f, fn col, acc_c ->
        posicion = {fila, col}
        terreno = Map.get(matriz, posicion)

        if terreno && terreno.transitable do
          vecinos = obtener_vecinos(posicion, filas, cols)
          costos_vecinos = Enum.map(vecinos, &Map.get(acc_c, &1)) |> Enum.reject(&is_nil/1)

          if costos_vecinos != [] do
            min_costo = Enum.min(costos_vecinos)
            nuevo_costo = min_costo + terreno.costo

            if nuevo_costo <= bateria do
              costo_previo = Map.get(acc_c, posicion, :infinity)
              if nuevo_costo < costo_previo, do: Map.put(acc_c, posicion, nuevo_costo), else: acc_c
            else
              acc_c
            end
          else
            acc_c
          end
        else
          acc_c
        end
      end)
    end)
  end

  defp detectar_estabilizacion(stream) do
    stream
    |> Stream.transform(nil, fn
      elemento, nil -> {[{elemento, 0}], {elemento, 0}}
      elemento, {anterior, idx} ->
        if elemento == anterior do
          {:halt, {anterior, idx}}
        else
          {[{elemento, idx + 1}], {elemento, idx + 1}}
        end
    end)
    |> Enum.to_list()
    |> then(fn lista ->
      pasos = Enum.map(lista, &elem(&1, 0))
      {_, ult_idx} = List.last(lista)
      {pasos, ult_idx}
    end)
  end

  defp obtener_vecinos({fila, col}, filas, cols) do
    [{fila - 1, col}, {fila, col + 1}, {fila + 1, col}, {fila, col - 1}]
    |> Enum.filter(fn {f, c} -> f >= 0 and f < filas and c >= 0 and c < cols end)
  end
end
