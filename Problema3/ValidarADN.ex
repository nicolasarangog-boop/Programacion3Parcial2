defmodule Validacion_ADN do
  @moduledoc """
  Modulo que valida los datos de entrada.
  - Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL V3
  """

  @doc """
  Funcion que coordina validación de muestras y datos, recopilando todos los errores
  ##Parámetros
  - muestras: Mapa con datos de las muestras de ADN y secuencias sin encabezado
  - motivos: lista de mapas con motivos ADN
  """
  def validar_datos(muestras, motivos) do
    errores = []
    errores = validar_sin_encabezado(muestras.secuencias_sin_encabezado, errores)
    errores = validar_muestras(muestras.muestras, [], errores)
    errores = validar_motivos(motivos, errores)
    invertir_lista(errores, [])
  end

  # Caso base
  defp validar_sin_encabezado([], errores) do
    errores
  end

  # Caso recursivo
  defp validar_sin_encabezado([linea | cola], errores) do
    mensaje = "Error: Secuencia sin encabezado en linea #{linea.numero_linea}"
    validar_sin_encabezado(cola, [mensaje | errores])
  end

  # Caso base
  defp validar_muestras([], _identificadores_vistos, errores) do
    errores
  end

  # Caso recursivo
  defp validar_muestras([muestra | cola], identificadores_vistos, errores) do
    identificador = muestra.identificador

    {identificadores_vistos, errores} =
      cond do
        identificador == "" ->
          mensaje = "Error: Identificador vacio en linea #{muestra.linea_encabezado}"
          {identificadores_vistos, [mensaje | errores]}

        identificador in identificadores_vistos ->
          mensaje =
            "Error: Identificador repetido #{identificador} en linea #{muestra.linea_encabezado}"

          {identificadores_vistos, [mensaje | errores]}

        true ->
          {[identificador | identificadores_vistos], errores}
      end

    errores =
      if muestra.secuencia == "" do
        mensaje = "Error: La muestra #{identificador} no contiene bases de ADN"
        [mensaje | errores]
      else
        errores
      end

    errores = validar_fragmentos(muestra.fragmentos, identificador, errores)

    validar_muestras(cola, identificadores_vistos, errores)
  end

  # Caso base
  defp validar_fragmentos([], _identificador, errores) do
    errores
  end

  # Caso recursivo
  defp validar_fragmentos([fragmento | cola], identificador, errores) do
    bases = String.graphemes(fragmento.contenido)
    errores = validar_bases(bases, 0, fragmento.numero_linea, identificador, :muestra, errores)
    validar_fragmentos(cola, identificador, errores)
  end

  # Caso base
  defp validar_bases([], _posicion, _linea, _identificador, _tipo, errores) do
    errores
  end

  # Caso recursivo
  defp validar_bases([base | cola], posicion, linea, identificador, tipo, errores) do
    errores =
      if base in ["A", "C", "G", "T"] do
        errores
      else
        mensaje =
          case tipo do
            :muestra ->
              "Error: Base invalida #{base} en muestra #{identificador} en linea #{linea} y posicion #{posicion}"

            :motivo ->
              "Error: Base invalida #{base} en motivo #{identificador} en linea #{linea} y posicion #{posicion}"
          end

        [mensaje | errores]
      end

    validar_bases(cola, posicion + 1, linea, identificador, tipo, errores)
  end

  # Caso base
  defp validar_motivos([], errores) do
    errores
  end

  # Caso recursivo
  defp validar_motivos([motivo | cola], errores) do
    errores =
      if motivo.secuencia == "" do
        mensaje = "Error: Motivo vacio en linea #{motivo.linea}"
        [mensaje | errores]
      else
        validar_bases(
          String.graphemes(motivo.secuencia),
          0,
          motivo.linea,
          motivo.secuencia,
          :motivo,
          errores
        )
      end

    validar_motivos(cola, errores)
  end

  # Caso base
  defp invertir_lista([], lista_invertida) do
    lista_invertida
  end

  # Caso recursivo
  defp invertir_lista([elemento | cola], lista_invertida) do
    invertir_lista(cola, [elemento | lista_invertida])
  end
end
