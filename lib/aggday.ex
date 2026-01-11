defmodule Bagg.Aggday do
  defdelegate sum(x), to: Enum

  defdelegate min(x), to: Enum

  defdelegate max(x), to: Enum

  defdelegate first(x), to: List

  defdelegate last(x), to: List

  def truemean(x) do
    sum(x) / length(x)
  end

  def uniqmean(x) do
    truemean(Enum.uniq(x))
  end

  defdelegate mean(x), to: __MODULE__, as: :uniqmean

  def median(x) do
    len = length(x)
    x = Enum.sort(x)

    if rem(len, 2) == 0 do
      (Enum.at(x, floor(len / 2 - 1)) +
         Enum.at(x, floor(len / 2))) /
        2
    else
      Enum.at(x, floor((len - 1) / 2))
    end
  end

  def mode(x) do
    {_tally, _maxtally, maxitem} =
      Enum.reduce(x, {%{}, 0, nil}, fn v, {tally, maxtally, maxitem} ->
        case Map.update(tally, v, 1, &(&1 + 1)) do
          tally = %{^v => count} when count > maxtally ->
            {tally, count, v}

          tally ->
            {tally, maxtally, maxitem}
        end
      end)

    maxitem
  end

  def trimmean(x) do
    len = length(x)
    cut_at = floor(len * 0.1)

    x
    |> Enum.sort()
    |> Enum.slice(cut_at..(len - cut_at - 1))
    |> truemean()
  end

  def binary([]), do: 0
  def binary(_), do: 1

  defdelegate jolly(x), to: __MODULE__, as: :binary

  def nonzero(x) do
    if Enum.any?(x, &(&1 != 0)), do: 1, else: 0
  end

  def triangle(x) do
    summed = sum(x)
    summed * (summed + 1) / 2
  end

  def square(x), do: sum(x) ** 2

  def clocky(x) do
    x
    |> Enum.chunk_every(2, 2, :discard)
    |> Enum.map(fn [from, to] -> to - from end)
    |> sum()
  end

  defdelegate count(x), to: Kernel, as: :length

  def kyshoc(x), do: min(2600, sum(x))
end
