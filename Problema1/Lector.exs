defmodule Lector do
   @moduledoc """
  Modulo encargado de leer y cargar la informacion de los archivos
  relacionados con los terrenos, la bateria y las lineas del edificio
  - Autores: Briyith Sanchez Alonso y Nicolás Arango Gutiérrez
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL V3
  """
  @doc """
  Funcion para cargar los terrenos desde un archivo

  ## Parametros
  - Ruta_archivo: Ruta del archivo que contiene la informacion de los terrenos

  ## Ejemplo
  iex> Lector.cargar_terrenos("terrenos.txt")
  %{"A" => %Terreno{simbolo: "A", nombre: "...", transitable: true, costo: 1}}
  """
  def cargar_terrenos(ruta_archivo) do
    File.stream!(ruta_archivo)
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(String.starts_with?(&1, "#") or &1 == ""))
    |> Stream.map(fn linea ->
      [simbolo, nombre, transitable, costo] = String.split(linea, ",", trim: true)
      terreno = %Terreno{
        simbolo: String.trim(simbolo),
        nombre: String.trim(nombre),
        transitable: String.trim(transitable) == "si",
        costo: String.to_integer(String.trim(costo))
      }

      {terreno.simbolo, terreno}
    end)
    |> Enum.into(%{})
  end

 @doc """
  Funcion para cargar la cantidad de bateria desde un archivo

  ## Parametros
  - Ruta_archivo: Ruta del archivo que contiene la cantidad de bateria

  ## Ejemplo
  iex> Lector.cargar_bateria("bateria.txt")
  100
  """
  def cargar_bateria(ruta_archivo) do
    File.stream!(ruta_archivo)
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(String.starts_with?(&1, "#") or &1 == ""))
    |> Enum.at(0)
    |> String.to_integer()
  end

 @doc """
  Funcion para leer las lineas de informacion de un edificio desde un archivo

  ## Parametros
  - Ruta_archivo: Ruta del archivo que contiene la informacion del edificio

  ## Ejemplo
  iex> Lector.leer_lineas_edificio("edificio.txt")
  ["linea 1", "linea 2", "linea 3"]
  """
def leer_lineas_edificio(ruta_archivo) do
  File.stream!(ruta_archivo)
  |> Stream.map(&String.trim/1)
  |> Stream.reject(&(String.starts_with?(&1, "#") or &1 == ""))
  |> Enum.to_list()
end
end
