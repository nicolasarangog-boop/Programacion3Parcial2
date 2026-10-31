defmodule Terreno do
  @moduledoc """
  Representa un terreno dentro del edificio donde se desplaza
  el robot de rescate.

  Contiene la información necesaria para identificar el terreno,
  determinar si es transitable y conocer su costo de energía.
  """
  defstruct [
    :simbolo,
    :nombre,
    :transitable,
    :costo
  ]
end

defmodule Recorrido do
  @moduledoc """
  Representa un recorrido realizado por el robot de rescate
  desde una posición inicial hasta una posición objetivo.

  Almacena las posiciones visitadas, la energía consumida
  y la cantidad de movimientos realizados.
  """
  defstruct [
    :posiciones,
    :energia_consumida,
    :cantidad_movimientos
  ]
end
