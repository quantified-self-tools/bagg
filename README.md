# Bagg

An Elixir implementation of [Beeminder](https://www.beeminder.com/)'s aggregation logic.

It will take into account `odom`, `kyoom`, and all `aggday` values other than `skatesum`.

## Installation

Add `bagg` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bagg, git: "https://github.com/quantified-self-tools/bagg.git"}
  ]
end
```

## Usage

### Library

The core entrypoint is `Bagg.aggregate_goal/1`, which should be called with the results of Beeminder's goal API on a goal invoked with `datapoints=true`:

```elixir
auth_token = System.fetch_env!("BEEMINDER_AUTH_TOKEN")

%{status: 200, body: goal_data} =
  Req.get!("https://www.beeminder.com/api/v1/users/me/goals/goalname.json",
    params: [auth_token: auth_token, datapoints: true]
  )

{:ok, aggregated_datapoints} = Bagg.aggregate_goal(goal_data)
```

Each aggregated datapoint is a `Bagg.Datapoint` struct with:
- `date` - the date for this aggregated value
- `value` - the aggregated value for the day
- `hashtags` - merged set of hashtags from all datapoints that day

### HTTP API

Bagg is also available at https://altbee.aeonc.com/api/bagg, which enriches API results from the Beeminder API with an `agg_data` field containing the aggregated datapoints.

#### Example

```bash
curl -s \
  https://www.beeminder.com/api/v1/users/me/goals/$GOAL.json?auth_token=$AUTH_TOKEN\&datapoints=true |
  curl https://altbee.aeonc.com/api/bagg \
    -H 'Content-Type: application/json' --data @-
```

This pipes your goal data directly to the aggregation API and returns the original goal data with an additional `agg_data` field.
