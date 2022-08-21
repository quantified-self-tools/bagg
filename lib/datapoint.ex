defmodule Bagg.Datapoint do
  defstruct [:date, :value, :hashtags]
  @hashtag_regex ~r/(?:^|\s)(#[a-zA-Z]\w+)(?=$|\s)/

  @type t() :: %__MODULE__{date: Date.t(), value: number(), hashtags: MapSet.t()}

  @spec new(%{required(String.t()) => term()}) :: t()
  def new(%{"comment" => c, "daystamp" => d, "value" => v})
      when is_number(v) and is_binary(c) and is_binary(d) do
    %Date{} = date = Timex.to_date(Timex.parse!(d, "{YYYY}{0M}{0D}"))

    hashtags =
      Regex.scan(@hashtag_regex, c, capture: :all_but_first)
      |> List.flatten()
      |> MapSet.new()

    %__MODULE__{date: date, value: v, hashtags: hashtags}
  end
end
