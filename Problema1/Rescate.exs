defmodule Rescate do
  @moduledoc """
Módulo encargado de buscar los recorridos posibles del robot de rescate
- Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
- Fecha: Octubre del 2026
- Licencia: GNU GPL V3
"""
  @doc """
  Funcion para buscar todos los recorridos posibles desde una posicion inicial
  hasta una posicion meta

  ## Parametros
  - Matriz: Mapa que contiene la informacion de los terrenos
  - Inicio: Posicion inicial del recorrido
  - Meta: Posicion final que se desea alcanzar
  - Bateria: Cantidad maxima de energia disponible
  - Filas: Cantidad de filas de la matriz
  - Cols: Cantidad de columnas de la matriz

  ## Ejemplo
  iex> Rescate.buscar_recorridos(matriz, {0, 0}, {2, 2}, 20, 3, 3)
  [%Recorrido{
    posiciones: [{0, 0}, {0, 1}, {1, 1}, {2, 1}, {2, 2}],
    energia_consumida: 10,
    cantidad_movimientos: 4
  }]
  """
  def buscar_recorridos(matriz, inicio, meta, bateria, filas, cols) do
    explorar_recorrido_rec(matriz, inicio, meta, bateria, filas, cols, [inicio], 0)
  end

  defp explorar_recorrido_rec(_matriz, posicion, meta, _bateria, _filas, _cols, camino, energia) when posicion == meta do
    [%Recorrido{
      posiciones: Enum.reverse(camino),
      energia_consumida: energia,
      cantidad_movimientos: length(camino) - 1
    }]
  end

  defp explorar_recorrido_rec(matriz, posicion, meta, bateria, filas, cols, camino, energia) do
    obtener_vecinos_ordenados(posicion)
    |> Enum.flat_map(fn vecino ->
      terreno_vecino = Map.get(matriz, vecino)

      cond do
        vecino in camino -> []
        is_nil(terreno_vecino) or not terreno_vecino.transitable -> []
        energia + terreno_vecino.costo > bateria -> []
        true ->
          explorar_recorrido_rec(matriz, vecino, meta, bateria, filas, cols, [vecino | camino], energia + terreno_vecino.costo)
      end
    end)
  end

  defp obtener_vecinos_ordenados({fila, col}) do
    [{fila - 1, col}, {fila, col + 1}, {fila + 1, col}, {fila, col - 1}]
  end
end
