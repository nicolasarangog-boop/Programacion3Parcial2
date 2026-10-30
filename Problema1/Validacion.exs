defmodule Validacion do
 @moduledoc """
  Módulo encargado de validar la estructura del edificio y los parámetros
  necesarios para ejecutar el proceso de rescate.

  - Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL V3
  """

@doc """
  Valida recursivamente el edificio y los parámetros del rescate.

  ## Parámetros
  - lineas: lista de cadenas de texto que representan las filas del edificio.
  - terrenos: mapa que relaciona los símbolos con los terrenos válidos.
  - bateria: cantidad de energía disponible para el robot.

  ## Ejemplo
      iex> Validacion.validar_edificio_recursivo([], %{}, 10)
      {:error, ["Error: El archivo del edificio está vacío."]}
  """

  def validar_edificio_recursivo(lineas, terrenos, bateria) do
    errores = []
    errores = if bateria <= 0, do: ["Error: La batería debe ser un entero positivo."] ++ errores, else: errores

    if lineas == [] do
      {:error, ["Error: El archivo del edificio está vacío."] ++ errores}
    else
      primera_linea = hd(lineas)
      ancho_esperado = length(String.split(primera_linea, " ", trim: true))

      {errores_matriz, _filas, cantidad_inicios, cantidad_metas} =
        validar_lineas_rec(lineas, terrenos, 0, ancho_esperado, 0, 0, [])

      todos_los_errores = errores ++ errores_matriz
      todos_los_errores = if cantidad_inicios != 1, do: ["Error: Debe existir exactamente un inicio 'S' (encontrados: #{cantidad_inicios})."] ++ todos_los_errores, else: todos_los_errores
      todos_los_errores = if cantidad_metas != 1, do: ["Error: Debe existir exactamente una meta 'M' (encontradas: #{cantidad_metas})."] ++ todos_los_errores, else: todos_los_errores

      if todos_los_errores == [], do: :ok, else: {:error, Enum.reverse(todos_los_errores)}
    end
  end

  defp validar_lineas_rec([], _terrenos, indice_fila, _ancho, cant_s, cant_m, errores), do: {errores, indice_fila, cant_s, cant_m}
  defp validar_lineas_rec([linea_actual | resto_lineas], terrenos, indice_fila, ancho_esperado, cant_s, cant_m, errores) do
    simbolos = String.split(linea_actual, " ", trim: true)
    ancho_actual = length(simbolos)

    errores = if ancho_actual != ancho_esperado, do: ["Línea #{indice_fila}: Fila con ancho incorrecto."] ++ errores, else: errores
    {errores_simbolos, inc_s, inc_m} = validar_simbolos_rec(simbolos, terrenos, indice_fila, 0, ancho_esperado - 1, errores)

    validar_lineas_rec(resto_lineas, terrenos, indice_fila + 1, ancho_esperado, cant_s + inc_s, cant_m + inc_m, errores_simbolos)
  end

  defp validar_simbolos_rec([], _terrenos, _fila, _columna, _max_col, errores), do: {errores, 0, 0}
  defp validar_simbolos_rec([simbolo | resto_simbolos], terrenos, fila, columna, max_col, errores) do
    errores = if not Map.has_key?(terrenos, simbolo), do: ["Coordenada (#{fila},#{columna}): Símbolo desconocido '#{simbolo}'."] ++ errores, else: errores
    errores = if (fila == 0 or columna == 0 or columna == max_col) and simbolo != "X", do: ["Coordenada (#{fila},#{columna}): El borde debe ser 'X'."] ++ errores, else: errores

    s_count = if simbolo == "S", do: 1, else: 0
    m_count = if simbolo == "M", do: 1, else: 0

    {errores_restantes, s_restante, m_restante} = validar_simbolos_rec(resto_simbolos, terrenos, fila, columna + 1, max_col, errores)
    {errores_restantes, s_count + s_restante, m_count + m_restante}
  end
end
