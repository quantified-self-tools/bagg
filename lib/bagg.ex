defmodule Bagg do
  alias Bagg.{Aggday, Datapoint}

  @valid_aggdays for {name, 1} <- Aggday.__info__(:functions), do: Atom.to_string(name)

  @type aggregate_opt() ::
          {:aggday, atom() | String.t()}
          | {:kyoom, boolean()}
          | {:odom, boolean()}

  @type aggregate_error() :: {:invalid_aggday, any()} | :no_datapoints

  @spec aggregate_goal(map()) ::
          {:ok, [%Datapoint{}]}
          | {:error, aggregate_error()}

  def aggregate_goal(%{
        "datapoints" => datapoints,
        "odom" => odom,
        "kyoom" => kyoom,
        "aggday" => aggday
      })
      when is_list(datapoints) do
    datapoints =
      datapoints
      |> Enum.sort_by(fn %{"timestamp" => t, "daystamp" => d} -> {d, t} end)
      |> Enum.map(&Datapoint.new/1)

    aggregate(datapoints,
      odom: odom,
      kyoom: kyoom,
      aggday: aggday
    )
  end

  def aggregate_goal(%{"odom" => _, "kyoom" => _, "aggday" => _}) do
    {:error, :no_datapoints}
  end

  @spec aggregate([%Datapoint{}], [aggregate_opt()]) ::
          {:ok, [%Datapoint{}]}
          | {:error, aggregate_error()}

  def aggregate(data, opts \\ []) do
    kyoom = Keyword.get(opts, :kyoom, false)
    odom = Keyword.get(opts, :odom, false)
    aggday = to_string(Keyword.get(opts, :aggday, if(kyoom, do: :sum, else: :last)))

    cond do
      Enum.empty?(data) ->
        {:error, :no_datapoints}

      aggday not in @valid_aggdays ->
        {:error, {:invalid_aggday, aggday}}

      true ->
        aggday = String.to_existing_atom(aggday)

        data = if odom, do: odomify(data), else: data

        data =
          data
          |> Enum.group_by(& &1.date)
          |> Enum.map(fn {date, datapoints} ->
            aggregate_day(date, datapoints, aggday)
          end)
          |> Enum.sort(&compare_dates/2)

        data = if kyoom, do: kyoomify(data), else: data

        {:ok, data}
    end
  end

  defp aggregate_day(date, datapoints, aggday) do
    values = Enum.map(datapoints, & &1.value)
    aggregated = apply(Aggday, aggday, [values])

    hashtags =
      Enum.reduce(datapoints, MapSet.new(), fn %{hashtags: hashtags}, acc ->
        MapSet.union(hashtags, acc)
      end)

    %Datapoint{
      date: date,
      value: aggregated,
      hashtags: hashtags
    }
  end

  defp compare_dates(%Datapoint{date: first}, %Datapoint{date: second}) do
    Date.compare(first, second) == :lt
  end

  defp odomify([first | rest]) do
    %{out: out} =
      Enum.reduce(rest, %{out: [first], prev: first, curradd: 0}, fn
        datapoint, %{out: out, prev: prev, curradd: curradd} ->
          curradd = if datapoint.value == 0, do: curradd + prev.value, else: curradd
          new_datapoint = %Datapoint{datapoint | value: datapoint.value + curradd}
          %{curradd: curradd, prev: datapoint, out: [new_datapoint | out]}
      end)

    Enum.reverse(out)
  end

  defp kyoomify(data) do
    %{out: out} =
      Enum.reduce(data, %{pre: 0, out: []}, fn
        datapoint, %{pre: pre, out: out} ->
          datapoint = %Datapoint{datapoint | value: datapoint.value + pre}

          %{pre: datapoint.value, out: [datapoint | out]}
      end)

    Enum.reverse(out)
  end
end
